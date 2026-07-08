#!/usr/bin/env bash
################################################################################
# Script: mkcertreq.sh
# Purpose: Generate an RSA certificate signing request with an encrypted key.
# Usage: mkcertreq.sh <domain_name>
################################################################################

set -euo pipefail

usage() {
  echo "Usage: $0 <domain_name>"
  echo "Example: $0 example.org"
}

log() {
  printf '%s\n' "$1"
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

require_command openssl

SITE_NAME_RAW=$1
SITE_NAME_SAFE=$(printf '%s' "$SITE_NAME_RAW" | tr '[:space:]/' '_' | tr -cd '[:alnum:]._-' )
[[ -n "$SITE_NAME_SAFE" ]] || die "Domain name resolves to an empty filesystem-safe value"

CERT_BASE_DIR="${CERT_BASE_DIR:-$PWD/certs}"
EMAIL_RECIPIENT="${EMAIL_RECIPIENT:-}"
EMAIL_SUBJECT="${EMAIL_SUBJECT:-TLS certificate request}"
REQUEST_INFO_URL="${REQUEST_INFO_URL:-https://example.org/certificate-request-info}"

CSR_COUNTRY="${CSR_COUNTRY:-US}"
CSR_STATE="${CSR_STATE:-State}"
CSR_CITY="${CSR_CITY:-City}"
CSR_ORGANIZATION="${CSR_ORGANIZATION:-Organization}"
CSR_ORG_UNIT="${CSR_ORG_UNIT:-IT}"
CSR_EMAIL="${CSR_EMAIL:-}"
CSR_CHALLENGE_PASSWORD="${CSR_CHALLENGE_PASSWORD:-.}"
CSR_UNSTRUCTURED_NAME="${CSR_UNSTRUCTURED_NAME:-.}"

YEAR=$(date +%Y)
CERTDIR="${CERT_BASE_DIR}/ssl.crt.${SITE_NAME_SAFE}.precert.${YEAR}.RSA"
PASSPHRASE_FILE="pass.${SITE_NAME_SAFE}.${YEAR}"
TARNAME="$(basename "$CERTDIR").tar.gz"

umask 077
mkdir -p "$CERTDIR"
cd "$CERTDIR"

log "Creating RSA certificate files in: $CERTDIR"

PASSPHRASE=$(openssl rand -hex 16)
printf '%s\n' "$PASSPHRASE" > "$PASSPHRASE_FILE"
chmod 600 "$PASSPHRASE_FILE"

log "Generating encrypted RSA private key"
openssl genrsa -des3 -out server.key.encrypted -passout file:"$PASSPHRASE_FILE" 2048

log "Generating unencrypted private key copy for local use"
openssl rsa -in server.key.encrypted -out server.key -passin file:"$PASSPHRASE_FILE" >/dev/null 2>&1
chmod 600 server.key

log "Generating certificate signing request (CSR)"
openssl req -new -key server.key -out server.csr -sha256 <<EOF
$CSR_COUNTRY
$CSR_STATE
$CSR_CITY
$CSR_ORGANIZATION
$CSR_ORG_UNIT
$SITE_NAME_RAW
$CSR_EMAIL
$CSR_CHALLENGE_PASSWORD
$CSR_UNSTRUCTURED_NAME
EOF

log "CSR subject:"
openssl req -noout -subject -in server.csr

chmod 600 server.*

cd "$CERT_BASE_DIR"
tar -czf "$TARNAME" "$(basename "$CERTDIR")"
chmod 600 "$TARNAME"

if [[ -n "$EMAIL_RECIPIENT" ]]; then
  if command -v mail >/dev/null 2>&1; then
    CERTREQ=$(cat "$CERTDIR/server.csr")
    printf '%s\n\n%s\n\n%s\n' "$SITE_NAME_RAW" "$CERTREQ" "$REQUEST_INFO_URL" | \
      mail -s "$EMAIL_SUBJECT" "$EMAIL_RECIPIENT"
    log "CSR emailed to $EMAIL_RECIPIENT"
  else
    log "mail command not found; skipping email step"
  fi
fi

log "RSA certificate request completed successfully"
log "CSR available at: $CERTDIR/server.csr"

