#!/bin/bash

xdg-open $(task information $1| egrep 'Github URL' | egrep -o 'https://github.com/[^/]\S*/[^/]\S*/(issues|pull)/[[:digit:]]+' | uniq | tail -n1) &
