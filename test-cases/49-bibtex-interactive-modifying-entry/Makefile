

default: test


##################################################
# Business logic

test: clean diff

compile: transcript.txt

transcript.txt:clean
	@echo test: creating initial bibtex database >> transcript.txt
	@cat doc.1.bib > doc.bib  
	-@latex-compile doc.tex >> transcript.txt
	@echo test: modifying one entry in the bibtex database  >> transcript.txt
	@cat doc.2.bib > doc.bib 
	-@latex-compile doc.tex >> transcript.txt ; true # this should rerun bibtex
	@echo test: did latex-compile correctly rerun bibtex ? >> transcript.txt

accept learn diff explain: transcript.txt
	@make -s -f ../Makefile.common $@

##################################################
# Cleanup

clean:
	@rm -f doc.bib
	@make -s -f ../Makefile.common clean
