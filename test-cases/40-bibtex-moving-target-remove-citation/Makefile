default: test

# Note: we take great care in this makefile to generate the transcript
# ourselves, and not  to use the usual Makefile.common  recipe. But we
# bail out for all other targets (clean, learn, explain, etc)

compile: transcript.txt

transcript.txt:
	@echo building document with two citations > transcript.txt
	@cat doc.in.tex > doc.tex
	-@latex-compile doc.tex >> transcript.txt ; true
	@echo counting lines in the .bbl':' $$(cat doc.bbl | wc -l)>> transcript.txt
	@echo rebuilding document with the second citation removed >> transcript.txt
	@cat doc.in.tex | sed 's/.*key2.*//' > doc.tex
	-@latex-compile doc.tex >> transcript.txt ; true 
	@echo counting lines in the .bbl':' $$(cat doc.bbl | wc -l)>> transcript.txt

test: clean diff

learn diff ref explain: transcript.txt
	@make -f ../Makefile.common $@

clean:
	@rm -f doc.tex
	@ make -f ../Makefile.common clean
