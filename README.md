# Bash Misc Tools

General-purpose bash utility scripts for file operations and data processing. Standalone scripts covering tasks too small for a dedicated repository.

## Repository Structure

```
bash-misc-tools/
├── README.md                          # Main repository documentation
├── .gitignore                         # Git ignore patterns
└── scripts/
    ├── certificates/                  # SSL/TLS certificate management
    │   ├── CHANGES.md
    │   ├── README.md
    │   ├── mkcertreq.sh               # Generate RSA CSR with encrypted keys
    │   ├── mkcertreq_ecdsa.sh         # Generate ECDSA CSR with encrypted keys
    │   ├── listCertDetails.sh         # Extract RSA certificate details
    │   └── listCertDetails_ecdsa.sh   # Extract ECDSA certificate details
    ├── file-operations/               # File manipulation utilities
    │   ├── README.md
    │   └── split_with_number_prefix.sh # Rename split files with numeric suffixes
    ├── tf-idf/                        # Map-reduce style text scoring pipeline
    │   ├── CHANGES.md
    │   ├── README.md
    │   ├── tf.sh
    │   ├── reduce-tf.sh
    │   ├── df.sh
    │   ├── reduce-df.sh
    │   ├── tf-idf.sh
    │   └── sample-data/
    └── data-processing/               # Data analysis and cross-referencing
        ├── README.md
        └── uniquePrograms.sh         # Cross-reference programs with courses
```

## Quick Start

### Installation

1. Clone the repository:
```bash
git clone https://github.com/sjamal/bash.git
cd bash
```

2. Make all scripts executable:
```bash
chmod +x scripts/*/*.sh
```

3. (Optional) Add to PATH:
```bash
export PATH="$PATH:$(pwd)/scripts/certificates:$(pwd)/scripts/file-operations:$(pwd)/scripts/data-processing"
```

## Script Categories

### 🔐 Certificate Management
SSL/TLS certificate generation and analysis scripts.

- **mkcertreq.sh** - Generate RSA certificate signing requests with encrypted keys
- **mkcertreq_ecdsa.sh** - Generate ECDSA certificate signing requests with encrypted keys
- **listCertDetails.sh** - Extract and display RSA certificate details
- **listCertDetails_ecdsa.sh** - Extract and display ECDSA certificate details

[Full Documentation](scripts/certificates/README.md)

[Change History](scripts/certificates/CHANGES.md)

### 📁 File Operations
File manipulation and organization utilities.

- **split_with_number_prefix.sh** - Rename split files with numeric prefixes

[Full Documentation](scripts/file-operations/README.md)

### 🧮 TF-IDF Pipeline
Map-reduce inspired text processing scripts for term frequency, document frequency, and TF-IDF scoring.

- **tf.sh** - Tokenize documents and emit term counts
- **reduce-tf.sh** - Aggregate term frequency per word/document pair
- **df.sh** - Seed document-frequency records
- **reduce-df.sh** - Aggregate document frequency per word
- **tf-idf.sh** - Compute TF-IDF scores

[Full Documentation](scripts/tf-idf/README.md)

[Change History](scripts/tf-idf/CHANGES.md)

### 📊 Data Processing
Data cross-referencing and analysis scripts.

- **uniquePrograms.sh** - Cross-reference programs with course data

[Full Documentation](scripts/data-processing/README.md)

## System Requirements

- **Bash** 4.0 or higher
- **OpenSSL** (for certificate scripts)
- Standard Unix utilities: `grep`, `sed`, `awk`, `sort`, `tr`, `wc`, `mail`
- POSIX-compliant shell environment

## Usage Examples

### Generate a certificate request (RSA)
```bash
./scripts/certificates/mkcertreq.sh example.com
```

### Generate a certificate request (ECDSA)
```bash
./scripts/certificates/mkcertreq_ecdsa.sh example.com
```

### Extract certificate details (RSA)
```bash
./scripts/certificates/listCertDetails.sh bundle.pem
```

### Extract certificate details (ECDSA)
```bash
./scripts/certificates/listCertDetails_ecdsa.sh bundle.pem
```

### Rename split files
```bash
split -l 1000 large.txt part_
./scripts/file-operations/split_with_number_prefix.sh part_
```

### Cross-reference programs with courses
```bash
./scripts/data-processing/uniquePrograms.sh programs.txt courses.csv
```

### Compute TF-IDF scores
```bash
N=$(awk 'END { print NR }' scripts/tf-idf/sample-data/neighbourhood_sample_corpus.txt)
cat scripts/tf-idf/sample-data/neighbourhood_sample_corpus.txt \
    | scripts/tf-idf/tf.sh \
    | scripts/tf-idf/reduce-tf.sh \
    | scripts/tf-idf/df.sh \
    | scripts/tf-idf/reduce-df.sh \
    | N="$N" scripts/tf-idf/tf-idf.sh
```

## Documentation

Each script includes:
- Header documentation
- Usage examples
- Input/output expectations
- Configuration notes where needed

For detailed information about a specific script, see the comments at the top of the file or the category README.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

## Contributing

Improvements and bug fixes are welcome. Ensure scripts are tested before use in production environments.

## Related Projects

- [bash-certificate-tools](https://github.com/sjamal/bash-certificate-tools) — SSL/TLS certificate generation and inspection scripts
- [bash-tfidf](https://github.com/sjamal/bash-tfidf) — Map-reduce style TF-IDF text scoring pipeline
- [python-data-processing](https://github.com/sjamal/python-data-processing) — Python ETL and data transformation pipelines
