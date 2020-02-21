#!/bin/bash
curl -u $TOGGL_KEY:api_token \
	-H "Content-Type: application/json" \
	-d '{"time_entry":{"description":"work","tags":[],"created_with":"curl"}}' \
	-X POST https://www.toggl.com/api/v8/time_entries/start
