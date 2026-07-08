#!/usr/bin/env bash
#
# Reduce document-frequency seed rows into final rows with per-word document
# frequency attached to each word/document record.
#
# Input:  word<TAB>document_id<TAB>term_frequency<TAB>1 (sorted or unsorted)
# Output: word<TAB>document_id<TAB>term_frequency<TAB>document_frequency

set -euo pipefail

LC_ALL=C sort -t $'\t' -k1,1 -k2,2n \
  | awk -F'\t' -v OFS='\t' '
      NF == 0 { next }
      {
        rows[NR] = $0
        document_frequency[$1] += $4 + 0
      }

      END {
        for (i = 1; i <= NR; i++) {
          split(rows[i], fields, "\t")
          print fields[1], fields[2], fields[3], document_frequency[fields[1]]
        }
      }
    '
