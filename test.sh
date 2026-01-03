#!/bin/sh

GPIO="$1"
URL="$2"
DELAY="$3"

if [ -z "$GPIO" ] || [ -z "$URL" ] || [ -z "$DELAY" ]; then
echo "Usage: $0 <gpio> <url> <delay_seconds>"
exit 1
fi

GPIO_PATH="/sys/class/gpio/gpio$GPIO"
VALUE="$GPIO_PATH/value"

# Enable pull-up
raspi-gpio set "$GPIO" pu

# Export GPIO if needed
if [ ! -d "$GPIO_PATH" ]; then
echo "$GPIO" > /sys/class/gpio/export
sleep 0.2
fi

# Configure GPIO
echo in > "$GPIO_PATH/direction"
echo falling > "$GPIO_PATH/edge"

# Clear any stale state
cat "$VALUE" > /dev/null

# Run forever — blocks until GPIO changes
while :; do
inotifywait -qq -e modify "$VALUE"

# Confirm it's actually LOW (falling edge)
if [ "$(cat "$VALUE")" = "0" ]; then
sleep "$DELAY"
curl -s -o /dev/null "$URL"
sleep 0.3   # debounce
fi
done

