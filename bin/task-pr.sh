#!/bin/bash

urls=$(task information $1| egrep '(githuburl|     https://github.com/)' | egrep -o 'https://github.com/[^/]\S*/[^/]\S*/(issues|pull)/[[:digit:]]+' | uniq | tail -n1) 
echo $urls
echo $urls | xargs xdg-open
