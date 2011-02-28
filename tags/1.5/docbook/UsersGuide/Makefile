# Copy this template to your docbook project directory and rename to Makefile.
# Set the DOC variable to the document name (the prefix of your docbook xml file, exclude the .xml suffix):
DOCDIR=/C/JModelica.org-SDK/src/docbook/UsersGuide
DOC=JModelicaUsersGuide
DOCFILE=$(DOCDIR)/$(DOC).xml
XSLHTMLSTYLE=$(DOCBOOK_HOME)/modelon-html-IE.xsl
XSLXHTMLSTYLE=$(DOCBOOK_HOME)/modelon-xhtml.xsl
XSLPDFSTYLE=$(DOCBOOK_HOME)/modelon-fo.xsl
XSLHTMLHELPSTYLE=$(DOCBOOK_HOME)/modelon-htmlhelp.xsl

#http://docbook.sourceforge.net/release/xsl/current/doc/html/index.html
$(DOC).xhtml:  $(DOCFILE)
	xsltproc  --xinclude  --output  $@ \
	$(XSLXHTMLSTYLE)  $<
	mv index.html $(DOC).xhtml

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

htmlhelp: $(DOC).chm

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
all: htmlhelp
#all: winhelp xhtml pdf
else
all: xhtml html pdf
endif

clean:
	rm -f *.pdf *.xhtml *.html *.fo *.hhp *.hhc *.chm

