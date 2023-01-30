#!/bin/bash

rm -f doc.aux # prevent stale files

cat two.v1.bib > two.bib

export PYTHONUNBUFFERED=yes # otherwise latex-compile's output never makes it into the file
echo 'test: running latex-compile in interactive mode (i.e. background process)' > transcript.txt
latex-compile --loop doc.tex >> transcript.txt &
export PIDXC=$!

(sleep 60 ; echo "test: emergency exit" ; kill $PIDXC >/dev/null 2>&1) & # safety measure, in case our script itself is killed
export PIDEE=$!

while [ `cat transcript.txt |wc -l` -lt 6 ] # magic number: 1-line test banner and 5 lines from latex-compile
do
    sleep 2
done

sleep 5 # wait enough time for the latex-compile snapshotter to perceive the change
echo 'test: ----------' >> transcript.txt
echo 'test: changing .bib file: should trigger a full recompilation: latex+bibtex+latex' >> transcript.txt
cat two.v2.bib > two.bib

while [ `cat transcript.txt |wc -l` -lt 10 ] # one more line of banner, three more for latex+bibtex+latex
do
    sleep 2
done

echo 'test: did latex-compile correctly rerun bibtex+latex ?'>> transcript.txt

echo 'test: killing latex-compile background process'>> transcript.txt

kill -9 $PIDEE $PIDXC
wait $PIDXC 2>/dev/null
wait $PIDEE 2>/dev/null

rm -f doc.aux # prevent stale files
