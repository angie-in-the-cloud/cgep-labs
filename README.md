# CGE-P Labs

Lab work for the Certified GRC Engineer - Practitioner (CGE-P) program.

## Structure

- `terraform/modules/` - reusable compliant infrastructure modules
- `terraform/primitives/` - single compliant resources or module consumers
- `policies/` - Rego policy library mapped to NIST 800-53 controls
- `scripts/` - shared utilities (evidence capture, etc.)
- `evidence/lab-X-Y/` - machine-readable compliance evidence for each lab

## Completed Labs

- Lab 2.3: First Compliant Resource (single S3 bucket on AWS, NIST 800-53)
- Lab 2.4: Terraform Modules for Compliance (GCS module + consumer on GCP, NIST 800-53)
- Lab 2.5: IaC as Compliance Evidence (S3 Object Lock vault + capture script, NIST 800-53)
- Lab 3.3: Writing Compliance Policies in Rego (SC-28, AC-3, CM-6 on GCP fixture, NIST 800-53)