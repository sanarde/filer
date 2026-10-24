#!/bin/sh
set -e
if [ $# -ne 2 ]; then
    echo "usage: $0 MaterialSymbolsRounded.ttf MaterialSymbolsRounded.codepoints" >&2
    exit 1
fi
root=$(dirname "$0")/..
unicodes=""
: > "$root/resources/icons.txt"
while read -r name; do
    code=$(grep "^$name " "$2" | cut -d' ' -f2)
    if [ -z "$code" ]; then
        echo "unknown icon: $name" >&2
        exit 1
    fi
    echo "$name $code" >> "$root/resources/icons.txt"
    unicodes="$unicodes,U+$code"
done < "$root/tools/icon-names.txt"
pyftsubset "$1" --unicodes="${unicodes#,}" --layout-features= --no-hinting \
    --output-file="$root/resources/fonts/MaterialSymbolsRounded.ttf"
