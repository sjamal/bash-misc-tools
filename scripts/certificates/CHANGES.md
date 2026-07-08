# Changes

## 2026-07-06

Commit message:
`feat(certificates): standardize certificate scripts and add ECDSA CSR workflow`

Commit body:
`Remove hard-coded names and URLs from the certificate scripts, standardize comments and validation, add a public-safe ECDSA mkcertreq workflow, and document the cleanup decisions in the certificates README.`

Summary of updates:
- Standardized the RSA and ECDSA certificate detail scripts with safer shell settings and clearer comments.
- Removed hard-coded names, mailbox addresses, and URLs from the certificate request workflow.
- Left the CSR email subject field blank by default so no placeholder address appears in the generated request.
- Added `mkcertreq_ecdsa.sh` as a public-safe ECDSA CSR generator.
- Updated the certificates README to match the current files and configuration options.
- Logged the cleanup decisions and the reason the ECDSA request script was missing from the tree before this change.

Validation notes:
- The scripts were reviewed for public-safe defaults and consistent documentation.
- The ECDSA workflow now exists in the repository snapshot and is documented alongside the RSA workflow.
