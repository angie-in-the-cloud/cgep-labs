# Compliance Policy Library

OPA/Rego policies that gate Terraform plans against NIST 800-53 controls.

## Policies

| File | Control | Severity | What it enforces |
|------|---------|----------|------------------|
| `sc28_encryption.rego` | SC-28 | high | Every GCS bucket must have a customer-managed encryption key (CMEK) |
| `ac3_no_public.rego` | AC-3 | critical | GCS buckets must enforce uniform access; firewalls must not expose ports 22/3389 to 0.0.0.0/0 |
| `cm6_required_tags.rego` | CM-6 | medium | Every taggable resource must carry the four required labels: project, environment, managed_by, compliance_scope |

## Test

```bash
opa test -v policies/
```

Expected: `PASS: 8/8`.

## Evaluate against a Terraform plan

```bash
terraform plan -out=tfplan
terraform show -json tfplan > plan.json

opa eval -d policies -i plan.json data.compliance.sc28.deny --format=pretty
opa eval -d policies -i plan.json data.compliance.ac3.deny  --format=pretty
opa eval -d policies -i plan.json data.compliance.cm6.deny  --format=pretty
```

Empty result = compliant. Non-empty = the listed resources violate that control.

## Roadmap

- Lab 3.4 adds AWS-resource-type variants (aws_s3_bucket, aws_security_group, etc.) with the same control IDs.
- Lab 4.3 wires this library into a GitHub Actions pipeline via Conftest as the policy gate.