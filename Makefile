#
# Makefile for docx2txt
#

NAME = docx2txt
VERSION = 0.2
INSTALLDIR = /usr/local/bin
CP = /usr/bin/cp
CHMOD = /usr/bin/chmod

Dx2TFILES = $(NAME).sh $(NAME).pl
PKGFILES = $(Dx2TFILES) Makefile INSTALL README COPYING ChangeLog ToDo AUTHORS
PKG=$(NAME)-$(VERSION)

install: $(Dx2TFILES)
	$(CP) $+ $(INSTALLDIR)
	(cd $(INSTALLDIR) && $(CHMOD) 755 $+)

dist:
	ln -s . $(PKG)
	tar zcvf $(PKG).tgz $(addprefix $(PKG)/, $(PKGFILES)); \
	rm $(PKG)

.PHONY: install dist
