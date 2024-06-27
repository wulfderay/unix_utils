#!/bin/sh

#lspci replacement for embedded system hacking/discovery
#syntax: lspci.sh [pci.ids]
#if you can get pci.ids or a cut down version onto your system it will
#be used to provide human readable names for the pci devices.
#if not, at least it will print the list in a relatively readable format.

PCI_IDS_FILE="$1"
VENDOR_ID="$2"

if [ ! -f "$PCI_IDS_FILE" ]; then
  echo "pci.ids file not found: $PCI_IDS_FILE"
  exit 1
fi

if [ -z "$VENDOR_ID" ]; then
  echo "Vendor ID not provided"
  exit 1
fi

# Print the first occurrence of the vendor ID
grep -i "^$VENDOR_ID " "$PCI_IDS_FILE"

# Use grep to find subsequent entries for the vendor and print until the next vendor starts
grep -i -A1000 "^$VENDOR_ID " "$PCI_IDS_FILE" | tail +2 | while IFS= read -r line; do
  # Print each line until a line starting with another vendor ID is encountered
  if echo "$line" | grep -q '^[0-9a-fA-F]\{4\} '; then
    break
  fi
  echo "$line"
done

root@DD-WRT:/mnt/sda# cat lspci.sh
#!/bin/sh

PCI_PATH="/sys/bus/pci/devices"
PCI_IDS_FILE=""
CACHE=""
CACHED_VENDOR=""
CACHE_SIZE="1000"
# caches a smaller section of the pci.ids file that starts with one vendor's entries
cache_vendor(){
  local vendor_id="$1"
  if [ "$vendor_id" != "$CACHED_VENDOR"  ]; then
    echo "Caching vendor $vendor_id"
    CACHED_VENDOR="$vendor_id"
    CACHE=$(grep -i -A"$CACHE_SIZE" "^$vendor_id " "$PCI_IDS_FILE")
  fi
}

# Function to map ID to human-readable name
map_id() {
  local id="$1"
  local type="$2"
  local result="Unknown"
  local grep_pattern=""
  local awk_command=""

  if [ "$type" = "vendor" ]; then
    grep_pattern="^$id "
    awk_command='{print substr($0, index($0, $2))}'
  elif [ "$type" = "device" ]; then
    grep_pattern="^\t$id "
    awk_command='{print substr($0, index($0, $2))}'
  elif [ "$type" = "subsystem" ]; then
    grep_pattern="^\\t\\t$id "
    awk_command='{print substr($0, index($0, $3))}'
  fi
  result=$(echo "$CACHE" | grep -i "$grep_pattern" | awk "$awk_command" | head -n 1)
  [ -n "$result" ] && echo "$result" || echo "Unknown"
}

# Parse command line arguments
if [ $# -ge 1 ]; then
  PCI_IDS_FILE="$1"
  if [ ! -f "$PCI_IDS_FILE" ]; then
    echo "pci.ids file not found: $PCI_IDS_FILE"
    exit 1
  fi
fi

if [ ! -d "$PCI_PATH" ]; then
  echo "PCI path not found"
  exit 1
fi

if [ $# -ge 2 ]; then
  if ! echo "$2" | grep -q '^[0-9]\+$'; then
    echo "Error: Argument '$2' is not a valid number. Cannot use for cache size."
    exit 1
  fi
  CACHE_SIZE="$2"
fi


for device in "$PCI_PATH"/*; do
  if [ -d "$device" ]; then
    VENDOR=$(cat "$device/vendor" 2>/dev/null | sed 's/^0x//')
    DEVICE=$(cat "$device/device" 2>/dev/null | sed 's/^0x//')
    CLASS=$(cat "$device/class" 2>/dev/null | sed 's/^0x//')
    SUBSYSTEM_VENDOR=$(cat "$device/subsystem_vendor" 2>/dev/null | sed 's/^0x//')
    SUBSYSTEM_DEVICE=$(cat "$device/subsystem_device" 2>/dev/null | sed 's/^0x//')

    if [ -n "$PCI_IDS_FILE" ]; then

      cache_vendor "$VENDOR"
      VENDOR_NAME=$(map_id "$VENDOR" "vendor")
      DEVICE_NAME=$(map_id "$DEVICE" "device")
      #SUBSYSTEM_NAME=$(map_id "$VENDOR:$DEVICE:$SUBSYSTEM_VENDOR:$SUBSYSTEM_DEVICE" "subsystem" "$VENDOR")
    fi

    # Format and display the output
    printf "Vendor: %s (%s), Device: %s (%s), Class: %s, Subsystem: %s\n" \
      "$VENDOR" "${VENDOR_NAME:-Unknown}" \
      "$DEVICE" "${DEVICE_NAME:-Unknown}" \
      "$CLASS" \
      "${SUBSYSTEM_NAME:-Unknown}"
  fi
done
