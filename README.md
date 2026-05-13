# CGE-P Labs

Lab work for the Certified GRC Engineer - Practitioner (CGE-P) program.

## Structure

- `terraform/modules/` - reusable compliant infrastructure modules
- `scripts/` - shared utilities (evidence capture, etc.)
- `terraform/primitives/` - single compliant resources or module consumers
- `evidence/lab-X-Y/` - machine-readable compliance evidence for each lab

## Completed Labs

- Lab 2.3: First Compliant Resource (single S3 bucket on AWS, NIST 800-53)
- Lab 2.4: Terraform Modules for Compliance (GCS module + consumer on GCP, NIST 800-53)
- Lab 2.5: IaC as Compliance Evidence (S3 Object Lock vault + capture script, NIST 800-53)