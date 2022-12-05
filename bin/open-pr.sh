#!/bin/bash

set +x
stdin=$(cat)
echo $stdin > ~/tmp/stdin
urls=$(echo $stdin | egrep -o '\s+https://github.com/[^/]\S*/[^/]\S*/(issues|pull)/[[:digit:]]+\S*' | tail -n1) 
echo $urls
for u in $urls; do
    open $u
done
