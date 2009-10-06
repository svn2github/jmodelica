DOC=JModelica-UG
DOCBOOKVERSION=1.75.2
DOCBOOKDIR=docbook-xsl-$(DOCBOOKVERSION)
URL=http://downloads.sourceforge.net/project/docbook/docbook-xsl/$(DOCBOOKVERSION)/$(DOCBOOKDIR).tar.gz
XSLHTMLSTYLE=$(DOCBOOKDIR)/html/docbook.xsl
XSLPDFSTYLE=$(DOCBOOKDIR)/fo/docbook.xsl
XSLHTMLHELPSTYLE=$(DOCBOOKDIR)/htmlhelp/htmlhelp.xsl
$(DOC).html:  $(DOC).xml 
	xsltproc  --output  $@  $(XSLHTMLSTYLE)  $<

html:  $(DOC).html

$(DOC).fo:  $(DOC).xml 
	xsltproc  --output  $@ \
	--stringparam paper.type A4 \
	--stringparam fop1.extensions 1 \
	$(XSLPDFSTYLE)  $<

$(DOC).pdf: $(DOC).fo
ifeq ($(OS),Windows_NT)
	cmd /c "fop -fo $< $@"
else
	fop -fo $< $@
endif

pdf:  $(DOC).pdf

$(DOC).hhp: $(DOC).xml
	xsltproc $(XSLHTMLHELPSTYLE) $<

htmlhelp: $(DOC).hhp


$(DOCBOOKDIR) :
	wget $(URL)
	tar -xzf $(DOCBOOKDIR).tar.gz
	rm -f $(DOCBOOKDIR).tar.gz

docbook: $(DOCBOOKDIR)

all: html pdf htmlhelp

clean:
	rm -f *.pdf *.html *.fo *.hhp *.hhc

