.PHONY: all clean clean-all install dist-all dist install-dist

VERSION=0.2.20
DISTUSER=sojka
DISTHOST=aisa
DISTDIR=/www/lemma/projekty/download
DISTNAME=fithesis2-v$(VERSION)
DISTFILES=$(DISTNAME).zip $(DISTNAME).pdf
CLASSFILES=fit1[012].clo fithesis.cls fithesis2.cls
AUXFILES=example.aux example.log example.out example.toc example.lot example.lof fithesis.aux fithesis.log fithesis.toc fithesis.ind fithesis.idx fithesis.out fithesis.ilg fithesis.gls fithesis.glo fi-logo600.514pk fi-logo600.600pk fi-logo600.tfm
PDFFILES=fithesis.pdf example.pdf
LOGOFILES=loga/phil-logo.eps loga/med-logo.pdf loga/ped-logo.pdf loga/med-logo.eps loga/sci-logo.eps loga/fsps-logo.pdf loga/fss-logo.pdf loga/fsps-logo.eps loga/law-logo.eps loga/ped-logo.eps loga/sci-logo.pdf loga/law-logo.pdf loga/fss-logo.eps loga/econ-logo.eps loga/econ-logo.pdf loga/phil-logo.pdf
SOURCEFILE=fithesis.dtx
FILOGOFILES=fi-logo.mf fi-logo600.mf
OTHERFILES=csquot.sty $(FILOGOFILES) example.tex fithesis.ins Makefile tutorial.pdf
INSTALLFILES=$(CLASSFILES) $(LOGOFILES) $(PDFFILES) $(SOURCEFILE) $(OTHERFILES)
TEXLIVEFILES=$(CLASSFILES) $(LOGOFILES)

# Tento pseudocíl vytvoří soubory třídy, příklad,
# dokumentaci a následně odstraní pomocné soubory.
all: fithesis2.cls $(PDFFILES) clean

# Tento cíl vytvoří soubory třídy.
fithesis2.cls: fithesis.ins fithesis.dtx
	tex $<

# Tento cíl vysází dokumentaci.
fithesis.pdf: fithesis.dtx
	pdflatex $<
	makeindex -s gind.ist fithesis
	makeindex -s gglo.ist -o fithesis.gls fithesis.glo
	pdflatex $<
#	pdflatex $<

# Tento cíl vysází příklad.
example.pdf: example.tex fithesis2.cls
	pdflatex $<
	pdflatex $<

# Tento pseudocíl instaluje veškeré nepomocné soubory
# do adresáře určeného parametrem "to".
install:
	@if [ -z "$(to)" ]; then echo "Usage: make to=DIRECTORY install"; exit 1; fi
	mkdir --parents "$(to)/fithesis2"
	cp --parents --verbose $(INSTALLFILES) "$(to)/fithesis2"

# Tento pseudocíl instaluje soubory tříd a technickou
# dokumentaci do adresářové struktury balíku TeXLive,
# jejíž kořenový adresář je určen parametrem "to".
install-texlive:
	# See <http://tug.ctan.org/tds/tds.html#Top_002dlevel-directories>
	@if [ -z "$(to)" ]; then echo "Usage: make to=DIRECTORY install-texlive"; exit 1; fi
	# Class and logo files
	mkdir --parents "$(to)/tex/latex/fithesis2"
	cp --parents --verbose $(TEXLIVEFILES) "$(to)/tex/latex/fithesis2"
	# Manual file
	mkdir --parents "$(to)/doc/latex/fithesis2"
	cp fithesis.pdf "$(to)/doc/latex/fithesis2/manual.pdf"
	# Source file
	mkdir --parents "$(to)/source/latex/fithesis2"
	cp $(SOURCEFILE) "$(to)/source/latex/fithesis2/$(SOURCEFILE)"
	# Metafont logo
	mkdir --parents "$(to)/fonts/source/filogo"
	cp $(FILOGOFILES) "$(to)/fonts/source/filogo"
	# Rebuild the cache
	texhash

# Tento pseudocíl odstaní pomocné soubory.
clean:
	rm -f $(AUXFILES)

# Tento pseudocíl odstraní veškeré vytvořitelné soubory.
clean-all: clean
	rm -f $(PDFFILES) $(CLASSFILES)

# Tento pseudocíl připraví distribuci, zveřejní ji
# a smaže lokální soubory distribuce.
dist-all: dist install-dist dist-clean

# Tento pseudocíl připraví distribuci.
dist: $(DISTFILES)

$(DISTNAME).zip: $(INSTALLFILES)
	zip -r -v $(DISTNAME).zip $(INSTALLFILES)

$(DISTNAME).pdf: fithesis.pdf
	cp fithesis.pdf $(DISTNAME).pdf

# Tento pseudocíl uveřejní distribuci verze $(VERSION)
install-dist: $(DISTFILES)
	scp $(DISTNAME).pdf $(DISTNAME).zip $(DISTUSER)@$(DISTHOST):$(DISTDIR)
	ssh $(DISTUSER)@$(DISTHOST) cd $(DISTDIR) '&&' \
		rm fithesis2-current.zip '&&' \
		rm fithesis2-current.pdf '&&' \
		ln -s $(DISTNAME).zip fithesis2-current.zip '&&' \
		ln -s $(DISTNAME).pdf fithesis2-current.pdf

# Tento pseudocíl odstraní lokální soubory distribuce
dist-clean:
	rm -f $(DISTFILES)
