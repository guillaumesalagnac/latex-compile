default: test

# Note: we take great care in this makefile to generate the transcript
# ourselves, and not  to use the usual Makefile.common  recipe. But we
# bail out for all other targets (clean, learn, explain, etc)
compile: transcript.txt

transcript.txt:
	@echo "test: building document with an malformed .bib file" > transcript.txt
	-@latex-compile doc.tex >> transcript.txt ; true
	@python3 -c 'print(10*"-")' >> transcript.txt
	@echo "test: building document again" >> transcript.txt
	-@latex-compile doc.tex >> transcript.txt ; true 
	@python3 -c 'print(10*"-")' >> transcript.txt
	@echo "test: was the biber warning correctly displayed twice ?" >> transcript.txt

test: clean diff

accept learn diff ref explain: transcript.txt
	@make -s -f ../Makefile.common $@

clean:
	@ make -s -f ../Makefile.common clean
