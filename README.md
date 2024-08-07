latex-compile
=============

Yet another script to compile your latex documents.

## Features

- run pdflatex the right number of times
- also run bibtex/biber when needed
- pretty-print warnings and error messages
- "daemon"-mode: monitors your files and recompile when needed, for near-real-time WYSISWG editing

## Design Rationale

- easy-to-use: should not require users to "read the instructions first"
- drop-in replacement for pdflatex: don't slow down the compilation too much
- sane defaults: don't hang when we should exit
- high signal-to-noise ratio: don't be needlessly verbose
- kiss: be readable and easy to extend by others (less than 600 lines)

## Installation

- make sure python 3 is installed
- drop `latex-compile` somewhere in your path
- profit
