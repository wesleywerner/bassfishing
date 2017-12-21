#!/bin/bash
echo Ensure you run zim and add the basslover notebook to the list of known notebooks.

zim --export basslover --output ../ --overwrite --template ./.template/basslover.html

# add responsive images
#find ../ -iname "*.html" -type f -exec sed -i 's/<img /<img class="img-responsive img-thumbnail" /g' {} +

cd ..
python -m SimpleHTTPServer
