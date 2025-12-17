#!/bin/bash
# ~/bin/stocktick.sh

SYMBOL="${1:-GRMN}"
API_KEY="d4qk6p1r01quli1d5un0d4qk6p1r01quli1d5ung"

get_stock_data() {
    RESPONSE=$(curl -s "https://finnhub.io/api/v1/quote?symbol=${SYMBOL}&token=${API_KEY}")

    if ! echo "$RESPONSE" | jq empty 2>/dev/null; then
        return 1
    fi

    echo "$RESPONSE" | jq -r '.c as $current |
           .pc as $prev |
           .dp as $pct |
           "\($current)|\($pct)"'
}

DATA=$(get_stock_data)

if [ -z "$DATA" ] || [ "$DATA" == "null|null" ]; then
    echo '{"text":"'"$SYMBOL"' N/A","tooltip":"No data","class":"neutral"}'
    exit 1
fi

IFS='|' read -r PRICE PCT <<< "$DATA"

if (( $(echo "$PCT > 0" | bc -l) )); then
    ARROW="↗"
    CLASS="up"
elif (( $(echo "$PCT < 0" | bc -l) )); then
    ARROW="↘"
    CLASS="down"
else
    ARROW="─"
    CLASS="neutral"
fi

echo "{\"text\":\"$SYMBOL $ARROW \$$PRICE\",\"tooltip\":\"$SYMBOL $ARROW ${PCT}%\",\"class\":\"$CLASS\"}"
