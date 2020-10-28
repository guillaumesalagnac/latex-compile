default: test

compile: transcript.txt

transcript.txt:
	@latex-compile --engine=lualatex doc.tex > $@

test: clean diff

accept learn diff ref explain: transcript.txt
	@make -f ../Makefile.common $@

clean:
	@make -f ../Makefile.common $@
