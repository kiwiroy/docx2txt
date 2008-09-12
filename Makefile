#
# Makefile for docx2txt
#

INSTALLDIR = /usr/local/bin
CP = /usr/bin/cp
CHMOD = /usr/bin/chmod

Dx2TFILES = docx2txt.sh docx2txt.pl

install: $(Dx2TFILES)
	$(CP) $+ $(INSTALLDIR)
	(cd $(INSTALLDIR) && $(CHMOD) 755 $+)

.PHONY: install
