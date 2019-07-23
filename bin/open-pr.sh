#!/bin/bash

stdin=$(cat)
echo $stdin > ~/tmp/stdin
urls=$(echo $stdin | egrep -o '\s+https://github.com/[^/]\S*/[^/]\S*/(issues|pull)/\d+' | sort | uniq) 
echo $urls
echo $urls | xargs open
