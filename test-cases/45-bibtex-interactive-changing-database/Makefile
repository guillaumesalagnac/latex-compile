

default: test


##################################################
# Business logic

test: clean diff

compile: transcript.txt

transcript.txt:clean
	@echo test: creating .bib database with only one entry > transcript.txt
	@cat doc.1.bib > doc.bib  
	-@latex-compile doc.tex >> transcript.txt # yields an error because key2 is missing
	@echo ---------- >> transcript.txt
	@echo test: adding second entry to .bib database >> transcript.txt ; true
	@cat doc.2.bib >> doc.bib 
	-@latex-compile doc.tex >> transcript.txt ; true # this should call bibtex *and then recompile* (if it doesn't,then this is a bug)
	@echo test: did latex-compile correctly rerun bibtex ? >> transcript.txt


accept learn diff explain: transcript.txt
	@make -s -f ../Makefile.common $@

##################################################
# Cleanup

clean:
	@rm -f doc.bib
	@make -s -f ../Makefile.common clean
