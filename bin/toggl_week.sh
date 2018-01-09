#!/bin/bash
source ~/.creds_toggl
hours=$(curl -s -u ${TOKEN}:api_token -H "Content-Type: application/json" https://toggl.com/reports/api/v2/weekly\?user_agent\=crazybus24@gmail.com\&workspace_id\=1525433\&since\=$(gdate -d last-monday +%Y-%m-%d) | jq -r '.total_grand')
echo "scale = 2; $hours / 3600000" | bc
