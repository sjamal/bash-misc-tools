#!/usr/bin/env bash
#
# Tokenize one document per input line and emit word/document pairs for the
# TF stage of the pipeline.
#
# Input:  one document per line on stdin
# Output: word<TAB>document_id<TAB>1

set -euo pipefail

document_id=0

while IFS= read -r line || [[ -n "$line" ]]; do
	document_id=$((document_id + 1))

	normalized=$(printf '%s' "$line" \
		| tr '[:upper:]' '[:lower:]' \
		| tr '[:punct:]' ' ' \
		| tr -s '[:space:]' ' ')

	for token in $normalized; do
		[[ -n "$token" ]] || continue
		printf '%s\t%s\t%s\n' "$token" "$document_id" "1"
	done
done
