#!/usr/bin/env bash
################################################################################
# Script: mkcertreq_ecdsa.sh
# Purpose: Generate an ECDSA certificate signing request with an encrypted key.
# Usage: mkcertreq_ecdsa.sh <domain_name>
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
EC_CURVE="${EC_CURVE:-prime256v1}"

CSR_COUNTRY="${CSR_COUNTRY:-US}"
CSR_STATE="${CSR_STATE:-State}"
CSR_CITY="${CSR_CITY:-City}"
CSR_ORGANIZATION="${CSR_ORGANIZATION:-Organization}"
CSR_ORG_UNIT="${CSR_ORG_UNIT:-IT}"
CSR_EMAIL="${CSR_EMAIL:-}"
CSR_CHALLENGE_PASSWORD="${CSR_CHALLENGE_PASSWORD:-.}"
CSR_UNSTRUCTURED_NAME="${CSR_UNSTRUCTURED_NAME:-.}"

YEAR=$(date +%Y)
CERTDIR="${CERT_BASE_DIR}/ssl.crt.${SITE_NAME_SAFE}.precert.${YEAR}.ECDSA"
PASSPHRASE_FILE="pass.${SITE_NAME_SAFE}.${YEAR}"
TARNAME="$(basename "$CERTDIR").tar.gz"

umask 077
mkdir -p "$CERTDIR"
cd "$CERTDIR"

log "Creating ECDSA certificate files in: $CERTDIR"

PASSPHRASE=$(openssl rand -hex 16)
printf '%s\n' "$PASSPHRASE" > "$PASSPHRASE_FILE"
chmod 600 "$PASSPHRASE_FILE"

log "Generating encrypted ECDSA private key on curve: $EC_CURVE"
openssl genpkey \
  -algorithm EC \
  -pkeyopt "ec_paramgen_curve:${EC_CURVE}" \
  -aes-256-cbc \
  -pass file:"$PASSPHRASE_FILE" \
  -out server.key.encrypted

log "Generating unencrypted private key copy for local use"
openssl pkey \
  -in server.key.encrypted \
  -out server.key \
  -passin file:"$PASSPHRASE_FILE"
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

log "ECDSA certificate request completed successfully"
log "CSR available at: $CERTDIR/server.csr"
