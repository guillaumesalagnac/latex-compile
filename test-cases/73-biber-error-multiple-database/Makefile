

default: test


##################################################
# Business logic

test: clean diff

compile: transcript.txt

transcript.txt:clean
	@echo test: first compilation, with a syntax error in two.bib > transcript.txt
	@cat two.v1.bib > two.bib  
	-@latex-compile doc.tex >> transcript.txt ; true
	@echo ---------- >> transcript.txt
	@echo test: fixing two.bib, leaving some errors in other files >> transcript.txt
	@cat two.v2.bib > two.bib 
	-@latex-compile doc.tex >> transcript.txt ; true # rerun biber
	@echo test: did latex-compile correctly show the two warnings ? >> transcript.txt

accept learn diff explain: transcript.txt
	@make -s -f ../Makefile.common $@

##################################################
# Cleanup

clean:
	@rm -f doc.bib
	@make -s -f ../Makefile.common clean
