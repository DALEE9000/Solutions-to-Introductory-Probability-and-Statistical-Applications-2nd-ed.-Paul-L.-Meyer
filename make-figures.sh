#!/usr/bin/env bash
# Pre-convert the EPS figures to the PDF names graphicx expects.
#
# Why this is needed: pdftex.def converts EPS on the fly by shelling out to
# epstopdf, but it does not quote the filename, so every figure whose name
# contains parentheses -- 1.5(a).eps, 1.10(b)(iii).eps, Fig3.11(a).eps, ... --
# fails to convert (15 of the 20 figures here). Running epstopdf ourselves
# sidesteps the quoting bug entirely: pdftex.def finds the already-converted
# "<name>-eps-converted-to.pdf" next to the source and uses it as-is, so no
# -shell-escape is required either.
#
# The generated PDFs are build artifacts and are gitignored; the .eps sources
# are the things under version control. Re-run this after adding or changing a
# figure. Safe to run repeatedly -- it only reconverts what is out of date.

set -euo pipefail
cd "$(dirname "$0")"

converted=0
skipped=0

while IFS= read -r -d '' eps; do
    out="${eps%.eps}-eps-converted-to.pdf"
    if [[ -f "$out" && "$out" -nt "$eps" ]]; then
        skipped=$((skipped + 1))
        continue
    fi
    epstopdf "$eps" --outfile="$out"
    converted=$((converted + 1))
done < <(find . -name '*.eps' -not -path './build/*' -print0)

echo "figures: ${converted} converted, ${skipped} already up to date"
