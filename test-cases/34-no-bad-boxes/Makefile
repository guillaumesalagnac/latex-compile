# -*- mode: Makefile -*-

# default target must come first
default: test

##################################################
# Main business logic

test: clean diff

transcript.txt:
	-@echo no option: > transcript.txt ; true
	-@latex-compile doc.tex >> transcript.txt ; true
	-@echo --nobadboxes option: >> transcript.txt ; true
	-@latex-compile --nobadboxes doc.tex >> transcript.txt ; true

diff: ref/transcript.txt transcript.txt
	@echo -n $(notdir $(realpath .)) 
	@echo -n ': '
	@diff transcript.txt ref/transcript.txt | wc -l

##################################################
# Learn reference output

ref/transcript.txt:
	@echo  $(notdir $(realpath .)) ': ' please type 'make learn' before testing ; exit 1

learn: transcript.txt
	@if [ -d ref ] ; then echo  please remove ref directory before learning ; exit 1 ; fi
	@mkdir -p ref
	@date > ref/date.txt
	@cp *.pdf doc.log transcript.txt ref

explain: transcript.txt
	@echo  $(notdir $(realpath .)) 
	@echo "================ Reference output =================="
	@cat ref/transcript.txt
	@echo "================ Test output ================"
	@cat transcript.txt
	@echo "================ Difference  ================"
	@-diff -y ref/transcript.txt transcript.txt

accept: transcript.txt
	@rm -rf ref
	@make -s learn

##################################################
# Cleanup

clean:
	@rm -f doc.{aux,bbl,blg,log,pdf,synctex.gz,toc,run.xml} 
	@rm -f doc-blx.bib transcript.txt

