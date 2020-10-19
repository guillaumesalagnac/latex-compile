default: test


##################################################
# Business logic

test: clean diff

compile: transcript.txt


transcript.txt:clean
	@python3 -c 'print(10*"=")' >> transcript.txt
	@cat two.v1.bib > two.bib
	-@latex-compile doc.tex >> transcript.txt 
	@python3 -c 'print(10*"=")' >> transcript.txt
	@echo test: changing one of the .bib files >> transcript.txt 
	@cat two.v2.bib > two.bib
	-@latex-compile doc.tex >> transcript.txt ; true 

accept learn diff explain: transcript.txt
	@make -s -f ../Makefile.common $@

##################################################
# Cleanup

clean:
	@rm -f two.bib
	@make -s -f ../Makefile.common clean
