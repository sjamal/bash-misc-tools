#!/usr/bin/env bash
#
# Compute TF-IDF scores from term frequency and document frequency rows.
#
# Required environment variable:
#   N = total number of documents in the corpus
#
# Input:  word<TAB>document_id<TAB>term_frequency<TAB>document_frequency
# Output: word<TAB>document_id<TAB>tf_idf

set -euo pipefail

: "${N:?Set N to the total number of documents before running tf-idf.sh}"
N=${N//[[:space:]]/}

if ! [[ "$N" =~ ^[0-9]+$ ]]; then
	printf 'Error: N must be a positive integer, got %s\n' "$N" >&2
	exit 1
fi

while IFS=$'\t' read -r word document_id term_frequency document_frequency || [[ -n "$word" ]]; do
	[[ -n "$word" ]] || continue

	tf_idf=$(awk -v tf="$term_frequency" -v df="$document_frequency" -v n="$N" '
		BEGIN {
			if (n <= 0 || df <= 0 || tf < 0) {
				print 0
				exit
			}
			printf "%.10f", tf * log(n / df)
		}
	')

	printf '%s\t%s\t%s\n' "$word" "$document_id" "$tf_idf"
done
