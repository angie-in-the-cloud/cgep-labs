# Evidence Vault (Lab 2.5)

S3 Object Lock vault for storing immutable compliance evidence bundles.

## What it builds

- S3 bucket with Object Lock enabled at creation
- Versioning (required by Object Lock)
- Default retention policy applied to every uploaded object
- AES256 server-side encryption
- Public access block (all four flags)
- Bucket policy denying `s3:DeleteBucket` except by account root

## NIST 800-53 controls

| Control | What satisfies it |
|---------|-------------------|
| AC-3    | Public access block (4 flags) |
| AU-9    | Object Lock + bucket-policy deny on DeleteBucket |
| AU-11   | Default retention rule (configurable days) |
| CM-6    | Required tags via `default_tags` |
| SC-28   | Server-side encryption (AES256) |

## Variables

| Name | Default | Notes |
|------|---------|-------|
| `project_name` | `cgep-lab` | Tag prefix and bucket name component |
| `lock_mode` | `GOVERNANCE` | `GOVERNANCE` (lab, bypassable) or `COMPLIANCE` (real, not bypassable) |
| `retention_days` | `1` | Days every uploaded object is locked |

## Deploy

```bash
aws sso login --profile angie
cd terraform/primitives/evidence-vault
terraform init
terraform apply -auto-approve
```

The `vault_name` output is the bucket name to pass to `scripts/capture-evidence.sh --vault`.

## Cleanup

GOVERNANCE mode allows bypass for lab cleanup. See the lab guide's Cleanup section for the bypass + delete-objects + destroy sequence. COMPLIANCE mode cannot be cleaned up until retention expires.