#
# Makefile for docx2txt
#

BINDIR ?= /usr/local/bin
CONFIGDIR ?= /etc

INSTALL = $(shell which install 2>/dev/null)
ifeq ($(INSTALL),)
$(error "Need 'install' to install docx2txt")
endif

PERL = $(shell which perl 2>/dev/null)
ifeq ($(PERL),)
$(warning "*** Make sure 'perl' is installed and is in your PATH, before running the installed script. ***")
endif

BINFILES = docx2txt.sh docx2txt.pl
CONFIGFILE = docx2txt.config

.PHONY: install installbin installconfig

install: installbin installconfig

installbin: $(BINFILES)
	[ -d $(BINDIR) ] || mkdir -p $(BINDIR)
	$(INSTALL) -m 755 $^ $(BINDIR)

installconfig: $(CONFIGFILE)
	[ -d $(CONFIGDIR) ] || mkdir -p $(CONFIGDIR)
	$(INSTALL) -m 755 $^ $(CONFIGDIR)
