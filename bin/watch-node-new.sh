#!/bin/bash

while true; do
    output=$(kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=$(k get nodes -o json | jq -r '.items[].metadata | [.creationTimestamp, .name] | @tsv' | sort | tail -n1 | awk '{ print $2 }'))
  clear
  echo "$output"
  sleep 5
done
