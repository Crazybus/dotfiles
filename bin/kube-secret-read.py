#!/usr/bin/env python3

import json
import sys
import base64

secret = json.loads(sys.stdin.read())
for key, value in secret["data"].items():
    print("=" * 80)
    print(key)
    print(base64.b64decode(value).decode())
