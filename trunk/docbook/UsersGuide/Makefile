# Copy this template to your docbook project directory and rename to Makefile.
# Set the DOC variable to the document name (the prefix of your docbook xml file, exclude the .xml suffix):
DOCDIR=/C/JModelica.org-SDK/src/docbook/UsersGuide
DOC=JModelicaUsersGuide
DOCFILE=$(DOCDIR)/$(DOC).xml
XSLHTMLSTYLE=$(DOCBOOK_HOME)/html/docbook.xsl
XSLXHTMLSTYLE=$(DOCBOOK_HOME)/xhtml.xsl
XSLPDFSTYLE=$(DOCBOOK_HOME)/fo.xsl
XSLHTMLHELPSTYLE=$(DOCBOOK_HOME)/htmlhelp/htmlhelp.xsl

#http://docbook.sourceforge.net/release/xsl/current/doc/html/index.html
$(DOC).xhtml:  $(DOCFILE)
	xsltproc  --xinclude  --output  $@ \
	$(XSLXHTMLSTYLE)  $<

xhtml:  $(DOC).xhtml

$(DOC).html:  $(DOCFILE)
	xsltproc --xinclude  --output  $@ \
	$(XSLHTMLSTYLE)  $<

html:  $(DOC).html

# http://docbook.sourceforge.net/release/xsl/current/doc/fo/index.html
$(DOC).fo:  $(DOCFILE)
	rm -f $(DOC).fo
	xsltproc --xinclude  --output  $@ \
	--stringparam fop1.extensions 1 \
	$(XSLPDFSTYLE)  $<

$(DOC).pdf: $(DOC).fo
	cmd /c "fop -fo $< $@"
	fop -fo $< $@

pdf:  $(DOC).pdf

htmlhelp.hhp: $(DOCFILE)
	xsltproc --xinclude $(XSLHTMLHELPSTYLE) $<

htmlhelp: $(DOC).hhp

$(DOC).chm: htmlhelp.hhp
	-"$(HTMLHELPWORKSHOP_HOME)/hhc" $<
	mv htmlhelp.chm $@

ifeq ($(OS),Windows_NT)
winhelp: $(DOC).chm
else
winhelp:
endif

ifeq ($(OS),Windows_NT)
#all: xhtml html pdf winhelp
all: xhtml pdf
else
all: xhtml html pdf
endif

clean:
	rm -f *.pdf *.xhtml *.html *.fo *.hhp *.hhc *.chm

