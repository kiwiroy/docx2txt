#
# BSD makefile for docx2txt
#

INSTALLDIR = /usr/local/bin
CP = /bin/cp
CHMOD = /bin/chmod

Dx2TFILES = docx2txt.sh docx2txt.pl

install: $(Dx2TFILES)
	$(CP) $> $(INSTALLDIR)
	(cd $(INSTALLDIR) && $(CHMOD) 755 $>)

.PHONY: install
