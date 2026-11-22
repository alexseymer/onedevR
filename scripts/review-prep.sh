#!/usr/bin/env bash
# Build a review bundle for a reviewer (agy, a human, any coding agent).
#
# Uses the `ocr` CLI (Open Code Review, https://github.com/alibaba/open-code-review)
# in delegation mode: `ocr delegate` selects the reviewable files and resolves
# the review rules without calling any LLM, so no API key is needed. The bundle
# holds the file list with exclusion reasons, the rules per file and the
# merge-base diff per file, as Markdown on stdout.
#
# Usage:
#   scripts/review-prep.sh <from> [<to>]       # range, <to> defaults to HEAD
#   scripts/review-prep.sh -c <commit>         # single commit
#   scripts/review-prep.sh --exclude 'a,b' ... # extra exclude patterns
#
# Example (hand the bundle to agy in one call):
#   scripts/review-prep.sh 95c154c 7aba528 > /tmp/bundle.md
#
# Needs: ocr (npm i -g @alibaba-group/open-code-review), git >= 2.41, jq.
set -euo pipefail

command -v ocr >/dev/null || { echo "review-prep: ocr not found (npm i -g @alibaba-group/open-code-review)" >&2; exit 2; }
command -v jq >/dev/null || { echo "review-prep: jq not found" >&2; exit 2; }

flags=()
exclude=""
if [ "${1:-}" = "-c" ]; then
  [ -n "${2:-}" ] || { echo "usage: review-prep.sh -c <commit>" >&2; exit 2; }
  flags=(--commit "$2"); shift 2
elif [ -n "${1:-}" ] && [ "${1#-}" = "$1" ]; then
  flags=(--from "$1"); shift
  if [ -n "${1:-}" ] && [ "${1#-}" = "$1" ]; then flags+=(--to "$1"); shift; fi
else
  echo "usage: review-prep.sh <from> [<to>] | -c <commit> [--exclude a,b]" >&2; exit 2
fi
if [ "${1:-}" = "--exclude" ]; then exclude="${2:-}"; fi
[ -z "$exclude" ] || flags+=(--exclude "$exclude")

preview="$(ocr delegate preview --format json "${flags[@]}")"
mode="$(jq -r .mode <<<"$preview")"
to="$(jq -r '.to // empty' <<<"$preview")"
base="$(jq -r '.merge_base // empty' <<<"$preview")"
commit="$(jq -r '.commit // empty' <<<"$preview")"
mapfile -t files < <(jq -r '.reviewable_files[].path' <<<"$preview")

echo "# Review bundle (${mode})"
echo
jq -r '"Repository: \(.repository)\nFrom: \(.from // "-")  To: \(.to // "-")  Commit: \(.commit // "-")  Merge base: \(.merge_base // "-")\nChanged files: \(.total_files) (+\(.total_insertions) -\(.total_deletions)); reviewable: \(.reviewable_count); excluded: \(.excluded_count)"' <<<"$preview"
echo
echo "## Reviewable files (review every one; end the report with a reviewed/skipped checklist)"
jq -r '.reviewable_files[] | "- \(.path) (\(.status), +\(.insertions) -\(.deletions))"' <<<"$preview"
echo
echo "## Excluded files (do not review)"
jq -r '.excluded_files[] | "- \(.path) (\(.exclude_reason))"' <<<"$preview"

if [ "${#files[@]}" -eq 0 ]; then
  echo; echo "Nothing reviewable."; exit 0
fi

echo
echo "## Review rules (per group of files)"
ocr delegate rule --format json "${flags[@]}" "${files[@]}" |
  jq -r '.groups[] | "### Rule group \(.group_id) (\(.source), \(.pattern))\nFiles: \(.files | join(", "))\n\n\(.rule)\n"'

echo "## Diffs"
for f in "${files[@]}"; do
  echo
  echo "### $f"
  echo '```diff'
  if [ "$mode" = "commit" ]; then
    git --no-pager show --no-ext-diff --no-textconv --no-color "$commit" -- "$f"
  else
    git --no-pager diff --no-ext-diff --no-textconv --no-color "${base}..${to}" -- "$f"
  fi
  echo '```'
done
