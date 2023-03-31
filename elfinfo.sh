#!/bin/sh

filename=$1

# Check if the file exists and is readable
if [ ! -r "$filename" ]; then
  echo "Error: File '$filename' not found or not readable"
  exit 1
fi

# Read the first 4 bytes of the file to check for the magic number
magic=$(dd if="$filename" bs=1 count=4 2>/dev/null)

# Check if the file is an ELF executable
if [ "$magic" != $'\x7fELF' ]; then
  echo "$filename: not an ELF executable"
  exit 1
fi

# Read the class of the ELF file (32-bit or 64-bit)
class=$(dd if="$filename" bs=1 skip=4 count=1 2>/dev/null | od -t d1 | awk '{print $2}')

if [ "$class" = "1" ]; then
  echo "Class: 32-bit"
elif [ "$class" = "2" ]; then
  echo "Class: 64-bit"
else
  echo "Unknown class: $class"
fi

# Read the endianness of the ELF file
endianness=$(dd if="$filename" bs=1 skip=5 count=1 2>/dev/null | od -t d1 | awk '{print $2}')

if [ "$endianness" = "1" ]; then
  echo "Endianness: little"
elif [ "$endianness" = "2" ]; then
  echo "Endianness: big"
else
  echo "Unknown endianness: $endianness"
fi

# Read the type of the ELF file (executable, shared object, etc.)
type=$(dd if="$filename" bs=1 skip=16 count=2 2>/dev/null | od -t d2 -An | awk '{print $1}')

if [ "$type" = "1" ]; then
  echo "Type: relocatable"
elif [ "$type" = "2" ]; then
  echo "Type: executable"
elif [ "$type" = "3" ]; then
  echo "Type: shared object"
elif [ "$type" = "4" ]; then
  echo "Type: core dump"
else
  echo "Unknown type: $type"
fi

# Read the entry point address of the ELF file
entry=$(dd if="$filename" bs=1 skip=24 count=4 2>/dev/null | od -t x4 -An | awk '{print $1}')

echo "Entry point: 0x$entry"
