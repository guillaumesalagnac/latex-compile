
# Warning: no space allowed in these names
DIRS=$(sort $(wildcard [0-9]*-*))

default: test-all

help:
	@echo This is the test suite for latex-compile 
	@echo useful targets: test-all and clean-all

########################################
DIRS_TEST=$(foreach dir,${DIRS}, ${dir}.test)
%.test: %
	+@MAKEFLAGS= ; make -j1 --no-print-directory --output-sync -C $^ test 2>&1
test-all-nocolor: ${DIRS_TEST}
test-all:
	@make -s test-all-nocolor -j8 | grep --color -E '.*: [^0].*|$$'

########################################
DIRS_CLEAN=$(foreach dir,${DIRS}, ${dir}.clean)
%.clean: %
	@cd $^ && make --no-print-directory clean
clean-all: ${DIRS_CLEAN}

########################################
# disable builtin insanity to make `make -d` human-readable
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
