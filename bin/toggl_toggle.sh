#!/bin/bash

set -euo pipefail

current=$(curl -s -u $TOGGL_KEY:api_token 'https://www.toggl.com/api/v8/time_entries/current' | jq -r .data.id)

if [ "$current" != "null" ]; then
    curl -s -u $TOGGL_KEY:api_token \
    	-H "Content-Type: application/json" \
    	-X PUT https://www.toggl.com/api/v8/time_entries/$current/stop
    notify-send -u critical "stopping toggl"
else
    echo not running starting
    curl -s -u $TOGGL_KEY:api_token \
    	-H "Content-Type: application/json" \
    	-d '{"time_entry":{"description":"work","tags":[],"created_with":"curl"}}' \
    	-X POST https://www.toggl.com/api/v8/time_entries/start
    notify-send -u low "starting toggl"
fi

