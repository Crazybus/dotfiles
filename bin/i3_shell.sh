#!/bin/bash
WHEREAMI=$(cat ~/tmp/whereami)
termite --directory="$WHEREAMI"
