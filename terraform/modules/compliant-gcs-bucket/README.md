# Compliant GCS Bucket Module

This module enforces NIST 800-53 controls SC-12, SC-13, SC-28, AU-11, and CM-6 on a single Google Cloud Storage bucket with a customer-managed encryption key (CMEK).

## Controls enforced

- **SC-12** — Cryptographic Key Establishment (customer-managed KMS keyring + crypto key)
- **SC-13** — Cryptographic Protection (AES-256 via CMEK with 90-day rotation)
- **SC-28** — Protection of Information at Rest (CMEK encryption on bucket)
- **AU-11** — Audit Record Retention (versioning + retention policy)
- **CM-6** — Configuration Settings (required compliance labels + uniform access)

## Module interface

- **Inputs:** consumer provides project, environment, retention days, bucket suffix
- **Outputs:** `bucket_url`, `bucket_self_link`, `kms_key_id`, and a structured `compliance_attestation` map for downstream Rego policies and OSCAL evidence

## Compliance by default

Encryption, versioning, public access prevention, uniform access, and required labels are hardcoded in `main.tf`. Consumers cannot disable them. Production environments are additionally required to set `retention_days >= 365` via variable validation.