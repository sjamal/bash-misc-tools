#!/usr/bin/env bash
#
# Convert term-frequency rows into document-frequency seed rows.
#
# Input:  word<TAB>document_id<TAB>tf
# Output: word<TAB>document_id<TAB>tf<TAB>1

set -euo pipefail

while IFS=$'\t' read -r word document_id term_frequency || [[ -n "$word" ]]; do
	[[ -n "$word" ]] || continue
	printf '%s\t%s\t%s\t%s\n' "$word" "$document_id" "$term_frequency" "1"
done
