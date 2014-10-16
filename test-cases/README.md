latex-compile regression test suite
===================================

## Introduction

Each  individual   test-case  is   in  a  separate   directory,  named
`NN-test-case-name`, with NN an increasing (but otherwise meaningless)
two-digit number.  The test-case number  is used in the  script source
code to refer to some specific features, or to some specific bugs.

Each directory  is expected to  contain a Makefile with  the following
targets:

### `compile`

Typing  `make  compile` calls  `latex-compile`  on  the document,  and
redirects console output to a file named `transcript.txt`.

Some  examples  are more  complicated  (e.g.  #22, #31...)  than  just
compiling the documennt. But In  any case, the transcript will contain
enough information to undersand what happened during compilation.

### `learn`

When  you are  convinced that  `latex-compile` does  the correct  job,
running  `make learn`  creates a  `ref` subdirectory,  and copies  the
reference transcipt there (as well as  other secondary files to aid in
later debugging: the .log file, the pdf, etc)

### `test`

Typing `make test`  compiles the test-case and compares  the output to
the  reference transcript.txt  with the  `diff` program.  If they  are
identical, the makefile says something in the lines of:

    % make test
    02-undefined-control-sequence: 0
    
### `explain`

If  the test  fails (i.e.  if the  test transcript  and the  reference
transcript differ)  then type  `make explain` to  print both  files as
well as a side-by-side diff.

## Makefile.common 

Because  most test-cases  have a  similar  structure, the  individual
Makefile   in   each   directory   is  often   just   a   symlink   to
`../Makefile.common`. This one contains generic rules to implement the
features described above and works with most test-cases.

To  write   more  complicated   scenarios  (i.e.  when   just  calling
`latex-compile` once  is not enough  to test the feature  in question)
then you can  either add a Makefile.local in  the test-case directory,
or rewrite the Makefile altogether (see e.g. #22, #31, etc).

## test-cases/Makefile

Regression testing is  achieved via this "general"  Makefile. Once all
the individual  scenarios have  been verified  by hand  and `learned`,
then typing  `make test-all` will  go through all directories  and run
`make test` in there.

When you change something  in the script (to add a  new feature, or to
fix a bug),  running `make test-all` and checking  that all test-cases
are correct gives you some  confidence that you didn't break anything.
If some  test fails (i.e. prints  something else than a  zero) then go
into that directory,  and type `make explain` to get  a better idea of
the problem.

If it happens that the new  transcript is indeed correct, and that the
reference  transcript is  now  obsolete, then  type  `make accept`  to
delete the `ref` directory and `learn` again.

