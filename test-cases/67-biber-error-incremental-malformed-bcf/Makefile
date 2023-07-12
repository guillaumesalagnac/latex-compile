default: test

# Note: in this makefile we  generate the transcript ourselves, but we
# bail out for all other targets (clean, learn, explain, etc)
compile: transcript.txt

transcript.txt:
	@echo "test: building document with a malformed .bib file" > transcript.txt
	@cat doc.v1.bib > doc.bib
	-@latex-compile doc.tex >> transcript.txt ; true
	@python3 -c 'print(10*"-")' >> transcript.txt
	@echo "test: fixing error in .bib file " >> transcript.txt
	@cat doc.v2.bib > doc.bib
	-@latex-compile doc.tex >> transcript.txt ; true 
	@python3 -c 'print(10*"-")' >> transcript.txt
	@echo "test: was the malformed .bcf correcly deleted, and did everything go well after that ?" >> transcript.txt

test: clean diff

accept learn diff ref explain: transcript.txt
	@make -s -f ../Makefile.common $@

clean:
	@make -s -f ../Makefile.common clean
