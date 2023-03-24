

default: test


##################################################
# Business logic

test: clean diff

compile: transcript.txt

transcript.txt:clean 
	-@latex-compile doc.tex >> transcript.txt
	@echo ---------- >> transcript.txt
	@echo test: deleting '.aux' file >> transcript.txt
	@rm doc.aux
	-@latex-compile doc.tex >> transcript.txt
	@echo test: did latex-compile run correctly or did it crash  ? >> transcript.txt

accept learn diff explain: transcript.txt
	@make -s -f ../Makefile.common $@

##################################################
# Cleanup

clean:
	@make -s -f ../Makefile.common $@
