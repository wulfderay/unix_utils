#!/bin/sh

# print the entries for a specific vendor from a pci.ids file.
# this is useful if you want to make a stripped down version for use on 
# a space/speed constrained system.
# usage: find_vendor_entries.sh <pci.ids file location> <vendor id>

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
