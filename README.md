# bash-misc-tools

Small Bash utilities for routine infrastructure, certificate, file, and CSV-oriented tasks. The repository is intentionally lightweight and keeps each tool as a standalone script.

## Layout

```text
.
├── certificates/
├── data/
├── files/
├── git-tools/
├── network/
├── CONTRIBUTING.md
└── README.md
```

## Scope

This repository collects miscellaneous shell helpers that were created for practical administrative tasks. Some scripts are generic, while others reflect specific operational environments and should be reviewed before reuse.

## Requirements

- Bash
- Standard Unix utilities such as `awk`, `grep`, `sed`, `tail`, and `mv`
- `ssh-keygen` for SSH key inspection
- `openssl` for certificate inspection and request generation
- `nc` for TCP connectivity checks
- `mail` for the legacy certificate request workflow in `mkcertreq.sh`

## Scripts

### network/check-connectivity.sh

Checks whether a TCP port is reachable from the current host by using `nc`.

- Primary use: quick validation of listener reachability without using `telnet`
- Default port: `50008`
- Typical use: `./network/check-connectivity.sh hostname.example 443`
- Exit codes: `0` on success, `1` on connection failure, `2` on missing arguments, `127` when `nc` is unavailable

### network/check-ssh-key.sh

Prints three SSH key properties for the supplied public or private key file.

- Output 1: key length
- Output 2: key fingerprint hash token
- Output 3: key type
- Typical use: `./network/check-ssh-key.sh ~/.ssh/id_rsa.pub`

### certificates/listCertDetails.sh

Reads one or more PEM certificates from a file and prints the subject and issuer for each certificate block.

- Primary use: inspecting certificate bundles or concatenated PEM files
- Input expectation: a text file containing one or more `BEGIN CERTIFICATE` and `END CERTIFICATE` blocks
- Typical use: `./certificates/listCertDetails.sh fullchain.pem`

### certificates/mkcertreq.sh

Generates a private key, certificate signing request, archival tarball, and notification email for a server certificate workflow.

- Primary use: legacy server certificate request preparation
- Environment assumptions: writable `/root/certs`, local `mail` command, and OpenSSL installed in standard locations
- Input expectation: one site or hostname argument
- Typical use: `./certificates/mkcertreq.sh site.example`

This script is environment-specific and should be reviewed carefully before use in a different organization or host layout.

### files/split_with_number_prefix.sh

Renames files that share a common prefix by appending a zero-padded numeric suffix.

- Primary use: renaming outputs after a prior `split` operation
- Current suffix width: `3`
- Typical use: `./files/split_with_number_prefix.sh x`

If files such as `xaa`, `xab`, and `xac` exist, the script renames them to `x001`, `x002`, and `x003`.

### data/uniquePrograms.sh

Reads a CSV of current courses and appends matching program-course associations from a second file into `ProgsWithCourseAssocs.csv`.

- Input 1: file containing active program associations
- Input 2: CSV file whose first column contains course identifiers
- Output: `ProgsWithCourseAssocs.csv`
- Typical use: `./data/uniquePrograms.sh active_programs.txt current_courses.csv`

## Usage Notes

- Review every script before running it against production systems.
- Run scripts with explicit paths to input files to avoid accidental reads from the wrong directory.
- Prefer testing in a temporary directory when a script modifies files.
- Some scripts predate stricter shell portability and safety conventions; local adaptation may be appropriate.

## Organization Notes

Scripts are grouped by function to improve discoverability:

- `network/` for connectivity and SSH-related utilities
- `certificates/` for certificate inspection and request generation
- `files/` for file renaming or split-output helpers
- `data/` for CSV or text-processing scripts

Additional category folders can be introduced as needed while preserving this domain-based layout.

## Version Control

See [CONTRIBUTING.md](CONTRIBUTING.md) for the expected branch and merge workflow.
