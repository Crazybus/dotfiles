#!/bin/bash

set +x
stdin=$(cat)
echo $stdin > ~/tmp/stdin
urls=$(echo $stdin | egrep -o '\s+https://github.com/[^/]\S*/[^/]\S*/(issues|pull)/[[:digit:]]+' | sort | uniq) 
echo $urls
for u in $urls; do
    xdg-open $u
done
