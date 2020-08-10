#!/bin/bash
WHEREAMI=$(cat ~/tmp/whereami || echo /home/mick/)
termite --directory="$WHEREAMI" -e "tmux -2"
