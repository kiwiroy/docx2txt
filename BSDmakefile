#
# BSD makefile for docx2txt
#

INSTALLDIR ?= /usr/local/bin
INSTALL != which install

Dx2TFILES = docx2txt.sh docx2txt.pl

install: $(Dx2TFILES)
	[ -d $(INSTALLDIR) ] || mkdir -p $(INSTALLDIR)
	$(INSTALL) -m 755 $> $(INSTALLDIR)

.PHONY: install
