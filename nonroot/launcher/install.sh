#!/bin/sh

FILES=$(ls files/)

mkdir -p ~/.local/share/applications/

for X in $FILES
do
	cp "files/$X" ~/.local/share/applications/
done

exit
