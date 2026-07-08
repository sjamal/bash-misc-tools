#!/usr/bin/env bash
#
# Reduce duplicate word/document rows into a single term-frequency record.
#
# Input:  word<TAB>document_id<TAB>1 (sorted or unsorted)
# Output: word<TAB>document_id<TAB>term_frequency

set -euo pipefail

LC_ALL=C sort -t $'\t' -k1,1 -k2,2n \
	| awk -F'\t' -v OFS='\t' '
			NF == 0 { next }
			NR == 1 {
				current_word = $1
				current_document = $2
				current_frequency = $3 + 0
				next
			}

			$1 == current_word && $2 == current_document {
				current_frequency += $3 + 0
				next
			}

			{
				print current_word, current_document, current_frequency
				current_word = $1
				current_document = $2
				current_frequency = $3 + 0
			}

			END {
				if (NR > 0) {
					print current_word, current_document, current_frequency
				}
			}
		'
