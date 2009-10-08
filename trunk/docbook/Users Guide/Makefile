# Copy this template to your docbook project directory and rename to Makefile.
# Set the DOC variable to the document name (the prefix of your docbook xml file, exclude the .xml suffix):
DOC=JModelicaUsersGuide
XSLHTMLSTYLE=$(DOCBOOK_HOME)/html/docbook.xsl
XSLPDFSTYLE=$(DOCBOOK_HOME)/fo/docbook.xsl
XSLHTMLHELPSTYLE=$(DOCBOOK_HOME)/htmlhelp/htmlhelp.xsl
$(DOC).html:  $(DOC).xml 
	xsltproc  --output  $@  $(XSLHTMLSTYLE)  $<

html:  $(DOC).html

$(DOC).fo:  $(DOC).xml 
	xsltproc  --output  $@ \
	--stringparam paper.type A4 \
	--stringparam fop1.extensions 1 \
	$(XSLPDFSTYLE)  $<

$(DOC).pdf: $(DOC).fo
	rm -f $(DOC).fo
ifeq ($(OS),Windows_NT)
	cmd /c "fop -fo $< $@"
else
	fop -fo $< $@
endif

pdf:  $(DOC).pdf

htmlhelp.hhp: $(DOC).xml
	xsltproc $(XSLHTMLHELPSTYLE) $<

htmlhelp: $(DOC).hhp

$(DOC).chm: htmlhelp.hhp
ifneq ($(OS),Windows_NT)
	@echo "The winhelp target is only available on Windows platform"
	false
endif
	@echo $(HTMLHELPWORKSHOP_HOME)
	-"$(HTMLHELPWORKSHOP_HOME)/hhc" $<
	mv htmlhelp.chm $@

winhelp: $(DOC).chm

all: html pdf htmlhelp

clean:
	rm -f *.pdf *.html *.fo *.hhp *.hhc *.chm

