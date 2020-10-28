default: test

# Note: we take great care in this makefile to generate the transcript
# ourselves, and not  to use the usual Makefile.common  recipe. But we
# bail out for all other targets (clean, learn, explain, etc)

compile: transcript.txt

transcript.txt:
	@echo test: building document with only one citation > transcript.txt
	@cat doc.in.tex | sed 's/.*key2.*//' > doc.tex
	-@latex-compile doc.tex >> transcript.txt ; true
	@echo test: counting lines in the .bbl':' $$(cat doc.bbl | wc -l)>> transcript.txt
	@python3 -c 'print(10*"-")' >> transcript.txt
	@echo test: rebuilding document with a second citation added >> transcript.txt
	@cat doc.in.tex | sed 's/.*key2.*/\\cite{key2}/' > doc.tex
	-@latex-compile doc.tex >> transcript.txt ; true 
	@echo test: counting lines in the .bbl':' $$(cat doc.bbl | wc -l)>> transcript.txt

test: clean diff

accept learn diff ref explain: transcript.txt
	@make -f ../Makefile.common $@

clean:
	@rm -f doc.tex
	@ make -f ../Makefile.common clean
