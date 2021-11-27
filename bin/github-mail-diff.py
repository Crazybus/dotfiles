#!/usr/bin/env python3

import sys
import time
import os

url = None
for line in sys.stdin:
    if line.startswith("https://github.com"):
        url = line

_, _, _, user, repo, _, number = url.strip().split("/")[:7]

number = number.split("#")[0]
api_url = f"https://api.github.com/repos/{user}/{repo}/pulls/{number}".strip()
command = f'curl -s -u Crazybus:$GITHUB_TOKEN --header "Accept: application/vnd.github.v3.diff" {api_url} | delta --diff-so-fancy | LESS="-g -i -M -R -S -w -X -z-4" less'
os.system("clear")
os.system(command)
