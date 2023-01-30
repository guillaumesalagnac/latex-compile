default: test


##################################################
# Business logic

test: clean diff

compile: transcript.txt

transcript.txt:clean
	@./run-test.sh

accept learn diff explain: transcript.txt
	@make -s -f ../Makefile.common $@

##################################################
# Cleanup

clean:
	@rm -f two.bib pdflatex*.fls
	@make -s -f ../Makefile.common clean
