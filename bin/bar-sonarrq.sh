#!/bin/bash

SONARR_URL="http://192.168.1.137:8989"
API_KEY="6fa5c55cb7d94cb7978fc8dccfd97adf"
TODAY=$(date -u +"%Y-%m-%dT00:00:00Z")
TODAY_END=$(date -u +"%Y-%m-%dT23:59:59Z")
TOMORROW=$(date -u -d "tomorrow" +"%Y-%m-%dT00:00:00Z")
TOMORROW_END=$(date -u -d "tomorrow" +"%Y-%m-%dT23:59:59Z")

today_response=$(curl -s -X GET "${SONARR_URL}/api/v3/calendar?start=${TODAY}&end=${TODAY_END}&includeSeries=true" -H "X-Api-Key: ${API_KEY}")
tomorrow_response=$(curl -s -X GET "${SONARR_URL}/api/v3/calendar?start=${TOMORROW}&end=${TOMORROW_END}&includeSeries=true" -H "X-Api-Key: ${API_KEY}")

process_episodes() {
    local response="$1"
    local count=0
    local output=""
    
    if [ -n "$response" ] && [ "$response" != "[]" ]; then
        while IFS= read -r episode; do
            series=$(printf '%s' "$episode" | jq -r '.series.title')
            season=$(printf '%s' "$episode" | jq -r '.seasonNumber')
            ep=$(printf '%s' "$episode" | jq -r '.episodeNumber')
            title=$(printf '%s' "$episode" | jq -r '.title')
            hasFile=$(printf '%s' "$episode" | jq -r '.hasFile')
            
            if [ "$hasFile" = "true" ]; then
                status="✅"
            else
                monitored=$(printf '%s' "$episode" | jq -r '.monitored')
                [ "$monitored" = "true" ] && status="⏬" || status="❌"
            fi
            
            output+="${series} - S${season}E${ep} ${title} ${status}\\n"
            ((count++))
        done < <(printf '%s' "$response" | jq -c '.[]')
    else
        output="No shows\\n"
    fi
    
    printf '%s|%s' "$count" "$output"
}

today_data=$(process_episodes "$today_response")
today_count=$(printf '%s' "$today_data" | cut -d'|' -f1)
today_list=$(printf '%s' "$today_data" | cut -d'|' -f2-)

tomorrow_data=$(process_episodes "$tomorrow_response")
tomorrow_count=$(printf '%s' "$tomorrow_data" | cut -d'|' -f1)
tomorrow_list=$(printf '%s' "$tomorrow_data" | cut -d'|' -f2-)

printf '{"text":" %s shows","tooltip":"TODAY:\\n%s\\n━━━━━━━━━━━━━━━━━━━━━━━━━━\\n\\nTOMORROW:\\n%s"}' \
    "$today_count" "$today_list" "$tomorrow_list"