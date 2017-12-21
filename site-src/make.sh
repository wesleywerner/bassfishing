#!/bin/bash
echo Ensure you run zim and add the basslover notebook to the list of known notebooks.

zim --export basslover --output ../ --overwrite --template ./.template/basslover.html

cd ..
python -m SimpleHTTPServer
