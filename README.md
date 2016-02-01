latex-compile
=============

Yet another script to compile your latex documents.


## Features

- run pdflatex the right number of times
- also run bibtex if needed
- pretty-print warnings and error messages
- "daemon"-mode: monitors your files and recompile when needed, for near-real-time WYSISWG editing

## Design Rationale

- easy-to-use: should not require users to "read the instructions first"
- drop-in replacement for pdflatex: don't slow up the compilation too much
- sane defaults: dont hang when we should exit
- high signal-to-noise ratio: don't be needlessly verbose
- kiss: be readable and easy to extend by others (so far, single-file, 350 lines)

## Installation

- make sure python 2.7+ is installed
- drop `latex-compile` somewhere in your path
- profit

## Wishlist

- filter out annoying warnings on a document-per-document basis
  (and/or per user ?) 
  example of such message:

        Package frenchb.ldf Warning: The definition of \@makecaption has been changed.

- an option to proceed despite bibtex errors.


# Changelog

* 2016-01-02 better error reporting (cf #43 #44) 
* 2015-10-02 better error reporting (cf #41)
* 2015-09-30 bugfix in file tracking logic (#42)
* 2015-09-29 don't crash when glossaries cause a compile error on later runs (cf #41)
* 2015-07-10 add support for glossaries.sty (cf #38 #39)
* 2015-06-03 improvements in error pretty-printing (cf #02)
* 2015-06-03 bugfix in error pretty-printing (cf #14 #36)
* 2015-03-26 bugfix in file tracking logic (cf #35)
* 2014-10-16 add a --version option
* 2014-09-18 print error messages and offending filenames on the same line
* 2014-06-11 always rerun bibtex if it previously failed (cf #31 #32)
* 2014-06-02 addition of `latex-clean`
