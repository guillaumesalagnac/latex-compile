

default: test


##################################################
# Business logic

test: clean diff

compile: transcript.txt

transcript.txt:clean
	@echo creating database with only one bib entry > transcript.txt
	@cat doc.1.bib > doc.bib  
	-@latex-compile doc.tex >> transcript.txt # yields an error because key2 is missing
	@echo adding second entry to database >> transcript.txt ; true
	@cat doc.2.bib >> doc.bib 
	-@latex-compile doc.tex >> transcript.txt ; true # this should call bibtex *and then recompile* (if it doesn't,then this is a bug)

accept learn diff explain: transcript.txt
	@make -f ../Makefile.common $@

##################################################
# Cleanup

clean:
	@rm -f doc.bib
	@ make -f ../Makefile.common clean
