# Compliance Policy Library

OPA/Rego policies that gate Terraform plans against NIST 800-53 controls. GCP and AWS variants share control IDs but target cloud-specific resource types.

## Policies

| File | Control | Cloud | Severity | What it enforces |
|------|---------|-------|----------|------------------|
| `sc28_encryption.rego` | SC-28 | GCP | high | Every `google_storage_bucket` must have a customer-managed encryption key (CMEK) |
| `sc28_encryption_aws.rego` | SC-28 | AWS | high | Every `aws_s3_bucket` must have a matching `aws_s3_bucket_server_side_encryption_configuration` |
| `ac3_no_public.rego` | AC-3 | GCP | critical | GCS buckets must enforce uniform access; firewalls must not expose 22/3389 to 0.0.0.0/0 |
| `ac3_no_public_aws.rego` | AC-3 | AWS | critical | Every `aws_s3_bucket` must have an `aws_s3_bucket_public_access_block` with all four flags `true` |
| `cm6_required_tags.rego` | CM-6 | GCP | medium | Every taggable resource must carry the four required labels: `project`, `environment`, `managed_by`, `compliance_scope` |
| `cm6_required_tags_aws.rego` | CM-6 | AWS | medium | Every taggable resource must carry the four required tags: `Project`, `Environment`, `ManagedBy`, `ComplianceScope` |

## Test

```bash
opa test -v policies/
```

Expected: `PASS: 8/8`. (Unit tests cover the GCP variants; AWS variants are exercised via Conftest against real Terraform plans — see below.)

## Evaluate against a Terraform plan

### Via OPA (GCP policies, ad-hoc)

```bash
terraform plan -out=tfplan
terraform show -json tfplan > plan.json
opa eval -d policies -i plan.json data.compliance.sc28.deny --format=pretty
opa eval -d policies -i plan.json data.compliance.ac3.deny  --format=pretty
opa eval -d policies -i plan.json data.compliance.cm6.deny  --format=pretty
```

Empty result = compliant. Non-empty = the listed resources violate that control.

### Via Conftest (AWS policies, gate-style)

```bash
bash scripts/policy-gate.sh --workspace terraform/primitives/compliant-s3
```

The wrapper runs SC-28, AC-3, and CM-6 against the workspace's `tfplan`, aggregates results into `evidence/lab-3-4/conftest-results.json`, and exits 0 on pass / 1 on fail. CI uses the exit code to decide whether a PR can merge.

## Roadmap

- Lab 4.3 wires `scripts/policy-gate.sh` into a GitHub Actions pipeline as the policy gate on every PR.
