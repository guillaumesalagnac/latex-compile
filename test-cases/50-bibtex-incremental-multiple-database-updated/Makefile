default: test


##################################################
# Business logic

test: clean diff

compile: transcript.txt


transcript.txt:clean
	@cat two.v1.bib > two.bib
	-@latex-compile doc.tex >> transcript.txt 
	@echo ---------- >> transcript.txt
	@echo test: modifying an existing entry in one of several .bib files  >> transcript.txt
	@cat two.v2.bib > two.bib
	-@latex-compile doc.tex >> transcript.txt ; true 
	@echo test: did latex-compile correctly rerun bibtex ? >> transcript.txt

accept learn diff explain: transcript.txt
	@make -s -f ../Makefile.common $@

##################################################
# Cleanup

clean:
	@rm -f two.bib
	@make -s -f ../Makefile.common clean
