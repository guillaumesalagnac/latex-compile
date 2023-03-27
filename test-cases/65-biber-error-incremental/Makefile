default: test

# Note: we take great care in this makefile to generate the transcript
# ourselves, and not  to use the usual Makefile.common  recipe. But we
# bail out for all other targets (clean, learn, explain, etc)

compile: transcript.txt

transcript.txt:
	@echo "test: building document with an malformed .bib file" > transcript.txt
	@python3 -c 'print(10*"-")' >> transcript.txt
	-@latex-compile doc.tex >> transcript.txt ; true
	@python3 -c 'print(10*"-")' >> transcript.txt
	@echo "test: building document again" >> transcript.txt
	-@latex-compile doc.tex >> transcript.txt ; true 
	@python3 -c 'print(10*"-")' >> transcript.txt
	@echo "test: did latex-compile correctly rerun  biber ?" >> transcript.txt

test: clean diff

accept learn diff ref explain: transcript.txt
	@make -sf ../Makefile.common $@

clean:
	@make -sf ../Makefile.common clean
