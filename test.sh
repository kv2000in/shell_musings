#!/bin/sh

GPIO="$1"
URL="$2"

if [ -z "$GPIO" ] || [ -z "$URL" ]; then
echo "Usage: $0 <gpio> <url>"
exit 1
fi

GPIO_PATH="/sys/class/gpio/gpio$GPIO"

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

# Clear pending edge
cat "$GPIO_PATH/value" > /dev/null

# Run forever (blocking, zero CPU)
while :; do
read _ < "$GPIO_PATH/value"
curl -s -o /dev/null "$URL"
sleep 0.3   # debounce
done

