#!/bin/sh

GPIO="$1"
URL="$2"
DELAY="$3"

if [ -z "$GPIO" ] || [ -z "$URL" ] || [ -z "$DELAY" ]; then
echo "Usage: $0 <gpio> <url> <delay_seconds>"
exit 1
fi

GPIO_PATH="/sys/class/gpio/gpio$GPIO"

# Enable pull-up resistor
raspi-gpio set "$GPIO" pu

# Export GPIO if needed
if [ ! -d "$GPIO_PATH" ]; then
echo "$GPIO" > /sys/class/gpio/export
sleep 0.2
fi

# Configure GPIO
echo in > "$GPIO_PATH/direction"
echo falling > "$GPIO_PATH/edge"

# Clear any pending edge
cat "$GPIO_PATH/value" > /dev/null

# Run forever (blocking, near-zero CPU)
while :; do
# Block until button press
read _ < "$GPIO_PATH/value"

# Delay after press
sleep "$DELAY"

# Fire URL (ignore response)
curl -s -o /dev/null "$URL"

# Debounce
sleep 0.3
done

