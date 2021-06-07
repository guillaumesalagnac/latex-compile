default: test


##################################################
# Business logic

test: clean diff

transcript.txt:clean
	-@latex-compile doc.tex > transcript.txt ; true
	@echo test: invoking latex-clean >> transcript.txt
	-@latex-clean >> transcript.txt ; true

accept diff explain: transcript.txt
	@make -s -f ../Makefile.common $@

learn:
	@if [ -d ref ] ; then echo  please remove ref directory before learning ; exit 1 ; fi
	@mkdir -p ref
	@date > ref/date.txt
	@cp transcript.txt ref

##################################################
# Cleanup

clean:
	@rm -f *.log *.dpth *.pdf *.md5 *.auxlock
	@make -s -f ../Makefile.common $@

