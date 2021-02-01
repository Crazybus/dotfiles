#!/bin/bash

while true; do
  output=$(kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=$(k get nodes | rg SchedulingDisabled | head -n1 | awk '{ print $1 }' ))
  clear
  echo "$output"
  sleep 5
done
