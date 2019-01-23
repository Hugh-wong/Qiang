#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'齐德隆冬'
SITENAME = u'呛呛呛'
SITEURL = ''

PATH = 'content'

DATE_FORMATS = {
    'zh': '%Y-%m-%d %H:%M:%S'
}

TIMEZONE = 'Asia/Shanghai'

DEFAULT_LANG = u'zh'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# # Blogroll
# LINKS = (('Pelican', 'http://getpelican.com/'),
#          ('Python.org', 'http://python.org/'),
#          ('Jinja2', 'http://jinja.pocoo.org/'))
#          ('You can modify those links in your config file', '#'),)

# # Social widget
# SOCIAL = (('You can add links in your config file', '#'),
#           ('Another social link', '#'),)

DEFAULT_PAGINATION = 20

DISPLAY_PAGES_ON_MENU = True

DELETE_OUTPUT_DIRECTORY = False

THEME = "themes/Casper2Pelican"
# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True
