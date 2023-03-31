#!/bin/sh

#check if follow links is set

follow_links=0
while [ $# -gt 0 ]
do
	case "$1" in
		-f)
			follow_links=1
			shift
                        ;;
		-h)
			echo "Usage: $0 [-f] <filename> [<filename> ...]"
			echo "	-f	Follow symbolic links"
			echo "	-h	This help :)"
			exit 0
			;;
		*)
			break
			;;
	esac
done

for filename in "$@"; do
   	if [ ! -e "$filename" ]; then
   		echo "$filename: no such file or directory"
   	elif [ -d "$filename" ]; then
   		echo "$filename: directory" 
	elif [ -L "$filename" ] && [ $follow_links -eq 0 ]; then
		link=$(readlink "$filename")
		echo "$filename: symbolic link -> $link"
	elif [ -s "$filename" ]; then
	
		if dd if="$filename" bs=1 count=4 2>/dev/null | grep -q -F $(echo -ne '\x7fELF'); then
      			echo "$filename: ELF executable"
		elif dd if="$filename" bs=1 count=3 2>/dev/null | grep -q -F $(echo -ne '\xff\xd8\xff'); then
      			echo "$filename: JPEG image"
		elif dd if="$filename" bs=1 count=4 2>/dev/null | grep -q -F "#!"; then
      			echo "$filename: script text"
		elif dd if="$filename" bs=1 count=3 2>/dev/null | grep -q -F "GIF"; then
			echo "$filename: GIF image"
		elif dd if="$filename" bs=1 count=5 2>/dev/null | grep -q -F "<html"; then
			echo "$filename: HTML document"
		elif dd if="$filename" bs=1 count=6 2>/dev/null | grep -q -F "@charset"; then
			echo "$filename: CSS stylesheet"
		elif dd if="$filename" bs=1 count=15 2>/dev/null | grep -q -F "<!DOCTYPE html>"; then
	        	echo "$filename: HTML document"
		elif dd if="$filename" bs=1 count=4 2>/dev/null | grep -q -F "<scr"; then
	        	echo "$filename: JavaScript file"
		elif dd if="$filename" bs=1 count=2 2>/dev/null | grep -q -F $(echo -ne '\x4d\x5a'); then
	        	echo "$filename: DOS executable"
	       	elif dd if="$filename" bs=1 count=4 2>/dev/null | grep -q -F $(echo -ne '<!DO'); then
	       	    echo "$filename: HTML document"
	       	elif dd if="$filename" bs=1 count=4 2>/dev/null | grep -q -F $(echo -ne '\x1b\x5b\x32\x6a'); then
	       		echo "$filename: ASCII text, with escape sequences"
	      	elif dd if="$filename" bs=1 count=4 2>/dev/null | grep -q -F $(echo -ne '\x50\x4b\x03\x04'); then
	       	        echo "$filename: zip archive"
	       	elif dd if="$filename" bs=1 count=4 2>/dev/null | grep -q -F $(echo -ne '\x7f\x45\x4c\x46'); then
	       	       	echo "$filename: ELF executable"
	       	elif dd if="$filename" bs=1 count=4 2>/dev/null | grep -q -F $(echo -ne '\x1f\x8b\x08\x00'); then
	       	        echo "$filename: gzip compressed data"
	       	elif dd if="$filename" bs=1 count=2 2>/dev/null | grep -q -F $(echo -ne '\xff\xfe'); then
	       	        echo "$filename: UTF-16 Unicode text"
	       	elif dd if="$filename" bs=1 count=2 2>/dev/null | grep -q -F $(echo -ne '\xfe\xff'); then
	       	       	echo "$filename: UTF-16 Unicode text"
	       	elif dd if="$filename" bs=1 count=3 2>/dev/null | grep -q -F $(echo -ne '\xef\xbb\xbf'); then
	       	       	echo "$filename: UTF-8 Unicode (with BOM) text"
		else
      			magic=$(dd if="$filename" bs=1 count=8 2>/dev/null)
      			echo "$filename: unknown file type (magic: ${magic})"
      		fi
   	else
   		echo "$filename: empty file"
	fi
done
