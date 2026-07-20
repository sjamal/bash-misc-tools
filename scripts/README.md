# Bash Scripts

Comprehensive collection of production-ready bash utilities for system administration, certificate management, file processing, and data analysis pipelines.

## Quick Navigation

### 🔒 Certificate Management
Certificate generation and inspection tools for RSA and ECDSA key pairs with secure password protection.

- **[`certificates/`](certificates/README.md)** — Complete documentation
  - `mkcertreq.sh` — Generate RSA CSR with encrypted private keys
  - `mkcertreq_ecdsa.sh` — Generate ECDSA CSR with encrypted private keys
  - `listCertDetails.sh` — Extract and display RSA certificate details
  - `listCertDetails_ecdsa.sh` — Extract and display ECDSA certificate details

### 📄 File Operations
Utilities for batch file renaming and formatting.

- **[`file-operations/`](file-operations/README.md)** — Complete documentation
  - `split_with_number_prefix.sh` — Rename `xaa`, `xab`... files to `001-xaa`, `002-xab`... format

### 📊 Data Processing
Tools for analyzing, transforming, and cross-referencing data sources.

- **[`data-processing/`](data-processing/README.md)** — Complete documentation
  - `uniquePrograms.sh` — Extract unique programs from logs and cross-reference with course databases

### 🔍 Text Analysis (Map-Reduce Pipeline)
Distributed text processing using Unix pipes — tokenization, term/document frequency, and TF-IDF scoring.

- **[`tf-idf/`](tf-idf/README.md)** — Complete documentation
  - `tf.sh` — Tokenize documents and emit term/document pairs
  - `df.sh` — Calculate document frequency per term
  - `reduce-tf.sh` — Aggregate term frequencies
  - `reduce-df.sh` — Aggregate document frequencies
  - `tf-idf.sh` — Complete pipeline combining all stages
  - `sample-data/` — Example documents for testing

## Usage Examples

### Generate a self-signed certificate request (RSA)
```bash
cd scripts/certificates
./mkcertreq.sh "example.com" "US" "New York" "Example Inc"
```

### Generate ECDSA certificate request
```bash
./mkcertreq_ecdsa.sh "secure.example.com" "US" "California" "Secure Inc"
```

### Extract certificate details
```bash
# View RSA certificate details
./listCertDetails.sh example.com.crt

# View ECDSA certificate details
./listCertDetails_ecdsa.sh secure.example.com.crt
```

### Process files from split output
```bash
cd scripts/file-operations
# Rename xaa, xab, xac... to 001-xaa, 002-xab, 003-xac...
./split_with_number_prefix.sh
```

### Run TF-IDF analysis on documents
```bash
cd scripts/tf-idf

# Process sample documents
./tf-idf.sh sample-data/* > scores.txt

# Or manually through pipeline stages:
cat sample-data/* | ./tf.sh | sort | ./reduce-tf.sh > tf.txt
cat sample-data/* | ./df.sh | sort | ./reduce-df.sh > df.txt
# Then combine for TF-IDF scoring
```

### Find unique programs across logs
```bash
cd scripts/data-processing
./uniquePrograms.sh program-list.txt course-database.csv
```

## Installation

```bash
git clone https://github.com/sjamal/bash.git
cd bash/scripts
chmod +x */*.sh
```

### Requirements
- Bash 4.0+ (or sh for most scripts)
- Standard Unix utilities: `sort`, `awk`, `sed`, `grep`, `uniq`, `tr`
- For certificate tools: `openssl`

## Features

- **No External Dependencies** — Pure bash + standard Unix tools
- **Pipeline-Compatible** — All scripts accept stdin/stdout for chaining
- **Idempotent** — Safe to re-run without side effects
- **Well-Documented** — Each tool includes usage examples
- **Production-Ready** — Error handling and validation included
- **Portable** — Designed to work across Linux, macOS, BSD

## Design Principles

### 1. Unix Philosophy
> "Do one thing and do it well"
- Each script focuses on a single task
- Scripts output structured text for piping and chaining
- Minimal configuration, maximum flexibility

### 2. Composability
Scripts are designed to work together. Example composable workflows:

```bash
# Extract unique programs, rank by frequency, output formatted list
./uniquePrograms.sh logs.txt db.csv | sort -k2 -rn | awk '{print $1, $2}'

# Process documents, calculate TF-IDF, find top terms
./tf-idf.sh docs/* | sort -k3 -rn | head -20
```

### 3. Simplicity Over Features
- Minimal options and flags
- Clear, readable code
- Predictable behavior

## Script Categories

### Certificates
SSL/TLS and cryptographic operations. Uses `openssl` for key generation and inspection.

#### Use Cases
- Generating certificate signing requests (CSR) for commercial CAs
- Creating self-signed test certificates
- Extracting certificate metadata for auditing
- Batch certificate management

### File Operations
Batch file manipulation with focus on splitting, renaming, and organizing.

#### Use Cases
- Organizing output from `split` command
- Batch file renaming workflows
- Preparation for archive processing

### Data Processing
Analytical tools for extracting insights from structured data.

#### Use Cases
- Log analysis and deduplication
- Cross-referencing data sources
- Inventory management
- Data validation

### Text Analysis
Map-reduce style text processing pipeline for NLP and information retrieval.

#### Use Cases
- Search engine indexing
- Document relevance scoring
- Keyword extraction
- Text analytics

## Best Practices

When using these scripts in production:

1. **Test First** — Run with sample data to verify behavior
2. **Version Data** — Keep baseline/comparison data versions
3. **Log Everything** — Redirect stderr to audit trails
4. **Handle Edge Cases** — Add error checks for your use case
5. **Document Pipelines** — Explain complex chained commands

## Contributing

Enhancements welcome! When adding scripts:

- Include usage examples in the script header
- Ensure portability across bash/sh/zsh
- Test with real data
- Document assumptions and limitations
- Add to appropriate category directory
- Update this README

## Related Projects

- [python-sysadmin-tools](https://github.com/sjamal/python-sysadmin-tools) — Python data processing utilities
- [ansible](https://github.com/sjamal/ansible) — Ansible playbooks for infrastructure automation
- [hybrid-governance-automation](https://github.com/sjamal/hybrid-governance-automation) — Enterprise automation framework

## License

See [LICENSE](../LICENSE) file.

## Questions?

- Check the category-specific READMEs in each subdirectory
- Review script headers for detailed documentation
- Open an issue with your use case
