#!/usr/bin/env bash
################################################################################
# Script: listCertDetails_ecdsa.sh
# Purpose: Extract key certificate details from PEM-encoded ECDSA certificates.
# Usage: listCertDetails_ecdsa.sh <certificate_file>
################################################################################

set -euo pipefail

usage() {
  echo "Usage: $0 <certificate_file>"
  echo "Example: $0 server.crt"
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

certificate_file=$1
[[ -f "$certificate_file" ]] || die "File not found: $certificate_file"

printf 'Extracting ECDSA certificate details from: %s\n\n' "$certificate_file"

certificate_buffer=""
while IFS= read -r line || [[ -n "$line" ]]; do
  certificate_buffer+="$line"$'\n'

  if [[ "$line" == *"END CERTIFICATE"* ]]; then
    printf '%b' "$certificate_buffer" | openssl x509 -text -noout | awk '
      /Subject:|Issuer:|Signature Algorithm:|Public-Key:|EC PARAMETERS:|ASN1 OID:|Not Before:|Not After :|Serial Number:/ {
        print
      }
    '
    printf '\n'
    certificate_buffer=""
  fi
done < "$certificate_file"

printf 'ECDSA certificate details extraction complete.\n'

