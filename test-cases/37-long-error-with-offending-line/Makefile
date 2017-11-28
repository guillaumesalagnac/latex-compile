
# GS-2015-06-23-17:23
# This test-case uses  a different file name than  all others, because
# it depends  on an  error message spawning  several lines.

# But apart  from the  changed jobname,  this makefile  is copy-pasted
# from ../Makefile.common









# default target must come first
default: test

##################################################
# optionnaly include per-testcase additional rules

-include Makefile.local

##################################################
# Main business logic

test: clean diff

# these are just aliases for "transcript". might vary.
compile pdf: transcript.txt
%.pdf: %.tex compile
	@true

transcript.txt:
	-@latex-compile quitealongfilename.tex > transcript.txt ; true

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
	@test -f quitealongfilename.pdf && cp quitealongfilename.pdf ref ; true
	@cp quitealongfilename.log transcript.txt ref

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
	@rm -f quitealongfilename.{aux,bbl,blg,log,pdf,synctex.gz,toc,run.xml} 
	@rm -f quitealongfilename-blx.bib transcript.txt

