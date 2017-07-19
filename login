#!/usr/bin/env python
# -*- coding: utf-8 -*-
# -*- mode: python; -*- 

from __future__ import print_function
from urlparse import urlparse
import os, sys
import urllib, urllib2, httplib
import getpass


def debug(*args):
	#print('[debug]', *args)
	pass
		
def verified(proxy):
	conn = httplib.HTTPConnection(urlparse(proxy).netloc)
	conn.request('GET', 'http://www.baidu.com/')
	response = conn.getresponse()
	conn.close()
	if response.status == 302:
		location = dict(response.getheaders()).get('location')
		return urlparse(location).path == '/disable/disable.htm'
	if response.status == 200:
		return True
			
def authentication_url(proxy):
	conn = httplib.HTTPConnection(urlparse(proxy).netloc)
	conn.request('GET', urlparse(proxy).path)
	response = conn.getresponse()
	conn.close()
	if response.status == 302:
		return authentication_url(dict(response.getheaders()).get('location'))
	if response.status == 200:
		auth_url = {
			'/redirect/': lambda proxy: 'http://%s' % urlparse(proxy).netloc,
			'/ac_portal/proxy.html': lambda proxy: 'http://%s/ac_portal/login.php' % urlparse(proxy).netloc}
		return auth_url.get(urlparse(proxy).path)(proxy)

def login(proxy, username, password):
	debug(proxy)
	logged = verified(proxy)
	if not logged:
		auth_url = authentication_url(proxy)
		login_param = {
			'opr': 'pwdLogin',
			'userName': username,
			'pwd': password, 
			'rememberPwd': '0',
			'lang': 'chs'
			}
		confirm_param = {
			'opr': 'noAuthlogin',
			}
			
		headers = {
			'Accept': '*/*',
			#'Accept-Language': 'zh-CN',
			'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
			#'Host': '10.3.76.102',
			#'Referer': 'http://10.3.76.102/ac_portal/zte_webauth/pc.html',
			'X-Requested-With': 'XMLHttpRequest'}
		conn = httplib.HTTPConnection(urlparse(auth_url).netloc)

		# get cookie
		debug('connect')
		conn.request('GET', '/ac_portal/zte_webauth/pc.html')
		response = conn.getresponse()
		if response.status == 200:
			headers['Cookie'] = dict(response.getheaders())['set-cookie'].split('; ')[0]
			pass

		# login
		debug('login')
		conn.request('POST', '/ac_portal/login.php', urllib.urlencode(login_param), headers)
		response = conn.getresponse()
	
		logged = verified(proxy)
		if not logged:
			# confirm
			debug('confirm')
			conn.request('POST', '/ac_portal/login.php', urllib.urlencode(confirm_param), headers)
			response = conn.getresponse()
			
		conn.close()

		logged = verified(proxy)
	return logged

def is_encode(s):
	return len(s) % 8 == 0 and all(map(lambda index: s[index * 8: index * 8 + 2] == '00', range(len(s) / 8))) 
	
if __name__ == "__main__":
	argv = sys.argv
	username = None
	password = None
	server = 'proxy'
	echo = None


	if len(argv) > 1:
		server = argv[1]
	if len(argv) > 2:
		username = argv[2]
	if len(argv) > 3:
		password = argv[3]
	
	if not username:
		username = raw_input('username: ')
	if username and not password:
		password = getpass.getpass('password: ')

	if 'http_proxy' in os.environ:
		del os.environ['http_proxy']

	server_url = 'http://%s.zte.com.cn' % server
	if username and password and login(server_url, username, password):
		print('OK')
	else:
		print('ERROR')

	#verified(server_url)





