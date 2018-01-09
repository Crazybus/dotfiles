#!/bin/bash
# Tries to ping google for 5 minutes. If succesful launches the application supplied as command line argument
export DISPLAY=:0
for x in {0..300}; do
  ping -c 1 8.8.8.8 > /dev/null 2>&1
  if [[ $? == 0 ]]; then
    $1 &
    exit 0
  else
    printf "."
    sleep 1
  fi
done
