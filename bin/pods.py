#!/usr/bin/env python3

import json
import os
import subprocess

cmd = "kubectl get pods -o json".split()

if "ALL_NAMESPACES" in os.environ:
    cmd.append("--all-namespaces")

pods = json.loads(subprocess.check_output(cmd))

for pod in pods["items"]:
    if "DONT_PRINT_CONTAINERS" in os.environ:
        print(f"-n {pod['metadata']['namespace']} {pod['metadata']['name']}")
        continue

    for c in pod["spec"]["containers"]:
        container_name = c["name"]
        print(
            f"-n {pod['metadata']['namespace']} {pod['metadata']['name']} -c {c['name']}"
        )
