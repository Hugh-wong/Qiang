PY?=python
PELICAN?=pelican
PELICANOPTS=

BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/content
OUTPUTDIR=$(BASEDIR)/hugh-wong.github.io
CONFFILE=$(BASEDIR)/pelicanconf.py
PUBLISHCONF=$(BASEDIR)/publishconf.py

GITHUB_PAGES_BRANCH=gh-pages

DEBUG ?= 0
ifeq ($(DEBUG), 1)
	PELICANOPTS += -D
endif

help:
	@echo 'Makefile for a pelican Web site                                        '
	@echo '                                                                       '
	@echo 'Usage:                                                                 '
	@echo '   make html                        (re)generate the web site          '
	@echo '   make clean                       remove the generated files         '
	@echo '   make regenerate                  regenerate files upon modification '
	@echo '   make publish                     generate using production settings '
	@echo '   make github                      upload the web site via gh-pages   '
	@echo '                                                                       '
	@echo 'Set the DEBUG variable to 1 to enable debugging, e.g. make DEBUG=1 html'
	@echo '                                                                       '

html:
	@echo "Now generating..."
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

start:
	$(PELICAN) -l -o $(OUTPUTDIR)

test: html start
	
clean:
	[ ! -d $(OUTPUTDIR) ] || find $(OUTPUTDIR) ! -path "*.git" -delete

regenerate:
	$(PELICAN) -r $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

publish:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(PUBLISHCONF) $(PELICANOPTS)

github:
	cd $(OUTPUTDIR) && git status
	cd $(OUTPUTDIR) && git add . && git commit -m "update article" && git push origin master
	

.PHONY: html help clean regenerate publish github
