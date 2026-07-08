# Certificate Management Scripts

Scripts for generating SSL/TLS certificates and extracting certificate details using both RSA and ECDSA algorithms.

## Scripts

### RSA Certificates

#### mkcertreq.sh
Generates an RSA certificate signing request with an encrypted private key.

**Key Features:**
- Configurable certificate output directory
- RSA key generation with encryption
- SHA-256 CSR generation
- Generic placeholder subject fields for public-safe use
- Optional CSR email step controlled by environment variables

**Usage:**
```bash
./mkcertreq.sh example.org
```

#### listCertDetails.sh
Extracts and displays subject and issuer information from PEM-encoded certificates.

**Key Features:**
- Handles multiple certificates in one file
- Processes BEGIN/END markers automatically
- Clean formatted output

**Usage:**
```bash
./listCertDetails.sh certificates.pem
```

---

### ECDSA Certificates

#### mkcertreq_ecdsa.sh
Generates an ECDSA certificate signing request with an encrypted private key.

**Key Features:**
- Configurable elliptic curve with a safe default
- ECDSA key generation with encryption
- SHA-256 CSR generation
- Generic placeholder subject fields for public-safe use
- Optional CSR email step controlled by environment variables

**Usage:**
```bash
./mkcertreq_ecdsa.sh example.org
```

#### listCertDetails_ecdsa.sh
Extracts and displays detailed information from ECDSA-based X.509 certificates, including curve details and public key information.

**Key Features:**
- Handles multiple certificates in one file
- Shows elliptic curve parameters and ASN1 OID
- Displays signature algorithm verification
- Processes BEGIN/END markers automatically
- Comprehensive formatted output

**Usage:**
```bash
./listCertDetails_ecdsa.sh ecdsa_certs.pem
```

**Output Includes:**
- Subject and issuer
- Signature algorithm
- Public key type and curve
- Validity period
- Serial number

---

## Requirements

### Common
- OpenSSL with X.509 support
- `mail` command for optional CSR delivery
- Write permissions to certificate directories

### ECDSA-Specific
- OpenSSL with ECDSA support
- ECDSA curve support in your OpenSSL build

## Notes

- `mkcertreq_ecdsa.sh` is now included in the repository snapshot.
- Scripts use generic placeholder subject values and avoid hard-coded names, local URLs, and mailbox addresses.
- See `CHANGES.md` for the current cleanup log and rationale.

## Configuration

Edit scripts to customize:
- Certificate output directory (`CERT_BASE_DIR`)
- Elliptic curve for ECDSA (`EC_CURVE`)
- Email recipients and subject (`EMAIL_RECIPIENT`, `EMAIL_SUBJECT`)
- CSR subject fields (`CSR_COUNTRY`, `CSR_STATE`, `CSR_CITY`, `CSR_ORGANIZATION`, `CSR_ORG_UNIT`, `CSR_EMAIL`) where `CSR_EMAIL` may be left blank
- Optional request information link (`REQUEST_INFO_URL`)

## Comparison: RSA vs ECDSA

| Feature | RSA 2048 | ECDSA P-256 |
|---------|----------|------------|
| Security Level | ~112 bits | ~128 bits |
| Key Size | 2048 bits | 256 bits |
| Signature Size | 256 bytes | 64 bytes |
| Key Generation | Slower | Faster |
| Computation Speed | Slower | Faster |
| Browser Support | Universal | Modern browsers |

## Usage Recommendations

- **Use RSA** for maximum compatibility with older systems and clients
- **Use ECDSA** for modern deployments, better performance, and future compatibility
- **Consider hybrid** with both RSA and ECDSA certificates for optimal coverage
