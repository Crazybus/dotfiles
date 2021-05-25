#!/bin/bash
WHEREAMI=$(cat ~/tmp/whereami || echo /home/mick/)
alacritty --working-directory="$WHEREAMI" -e tmux -2
