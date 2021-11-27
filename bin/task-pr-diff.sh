#!/bin/bash

urls=$(task information $1 2>/dev/null | egrep 'Github URL' | egrep -o 'https://github.com/[^/]\S*/[^/]\S*/(issues|pull)/[[:digit:]]+' | uniq | tail -n1) 

echo $urls
echo $urls | /home/mick/bin/github-mail-diff.py || sleep 5
