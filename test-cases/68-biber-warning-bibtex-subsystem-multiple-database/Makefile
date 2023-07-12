default: test


##################################################
# Business logic

test: clean diff

compile: transcript.txt


transcript.txt:clean
	@python3 -c 'print(10*"-")' >> transcript.txt
	-@latex-compile doc.tex >> transcript.txt 
	@python3 -c 'print(10*"-")' >> transcript.txt
	@echo "test: building document again" >> transcript.txt
	-@latex-compile doc.tex >> transcript.txt ; true 
	@python3 -c 'print(10*"-")' >> transcript.txt
	@echo "test: did latex-compile correctly rerun  biber ?" >> transcript.txt

accept learn diff explain: transcript.txt
	@make -s -f ../Makefile.common $@

##################################################
# Cleanup

clean:
	@make -s -f ../Makefile.common clean
