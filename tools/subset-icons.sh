#!/bin/sh
set -e
if [ $# -ne 2 ]; then
    echo "usage: $0 MaterialSymbolsRounded.ttf MaterialSymbolsRounded.codepoints" >&2
    echo "requires fonttools and skia-pathops (set PYTHON to an interpreter that has them)" >&2
    exit 1
fi
python=${PYTHON:-python3}
root=$(dirname "$0")/..
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

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

for fill in 0 1; do
    "$python" -m fontTools varLib.instancer "$1" FILL=$fill wght=400 GRAD=0 opsz=24 \
        --remove-overlaps --no-overlap-flag -o "$work/full$fill.ttf"
done

pyftsubset "$work/full0.ttf" --unicodes="${unicodes#,}" --layout-features= --no-hinting \
    --output-file="$root/resources/fonts/MaterialSymbolsRounded.ttf"
pyftsubset "$work/full1.ttf" --unicodes="${unicodes#,}" --layout-features= --no-hinting \
    --output-file="$root/resources/fonts/MaterialSymbolsRoundedFilled.ttf"

"$python" - "$root/resources/fonts/MaterialSymbolsRoundedFilled.ttf" <<'PY'
import sys
from fontTools.ttLib import TTFont

font = TTFont(sys.argv[1])
names = {
    1: "Material Symbols Rounded Filled",
    4: "Material Symbols Rounded Filled Regular",
    6: "MaterialSymbolsRoundedFilled-Regular",
    16: "Material Symbols Rounded Filled",
}
for record in font["name"].names:
    if record.nameID in names:
        record.string = names[record.nameID]
font.save(sys.argv[1])
PY
