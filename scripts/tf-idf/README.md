# TF-IDF Bash Pipeline

Simple map-reduce inspired bash scripts for computing term frequency, document frequency, and TF-IDF scores from a plain-text corpus.

The workflow was adapted from a Hadoop streaming example series by The Oracle Alchemist:

http://www.oraclealchemist.com/series/hadoop-streaming/

## Workflow

One document per line flows through these stages:

1. `tf.sh` tokenizes text and emits `word<TAB>document_id<TAB>1`.
2. `reduce-tf.sh` aggregates repeated word/document pairs into term frequency.
3. `df.sh` appends a document-frequency seed value of `1`.
4. `reduce-df.sh` sums document-frequency totals per word and attaches them to each row.
5. `tf-idf.sh` computes the final score using `tf * log(N / df)`.

## Sample Data

See `sample-data/neighbourhood_sample_corpus.txt` for a small reproducible corpus.

## Example

From the repository root:

```bash
N=$(awk 'END { print NR }' scripts/tf-idf/sample-data/neighbourhood_sample_corpus.txt)
cat scripts/tf-idf/sample-data/neighbourhood_sample_corpus.txt \
	| scripts/tf-idf/tf.sh \
	| scripts/tf-idf/reduce-tf.sh \
	| scripts/tf-idf/df.sh \
	| scripts/tf-idf/reduce-df.sh \
	| N="$N" scripts/tf-idf/tf-idf.sh
```

## Inputs

- Plain text, one document per line.
- Tokens are lowercased and stripped of punctuation.
- Blank lines are allowed and count as empty documents.

## Outputs

- `word<TAB>document_id<TAB>1` from `tf.sh`
- `word<TAB>document_id<TAB>term_frequency` from `reduce-tf.sh`
- `word<TAB>document_id<TAB>term_frequency<TAB>1` from `df.sh`
- `word<TAB>document_id<TAB>term_frequency<TAB>document_frequency` from `reduce-df.sh`
- `word<TAB>document_id<TAB>tf_idf` from `tf-idf.sh`

## Requirements

- Bash 4+
- Standard Unix tools: `awk`, `sort`, `tr`, `wc`

## Notes

- `N` must be set before running `tf-idf.sh`.
- The reducers sort their input internally so they can be used as standalone filters.
