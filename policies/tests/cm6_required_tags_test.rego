package compliance.cm6_test

import rego.v1
import data.compliance.cm6

complete := {"planned_values": {"root_module": {"resources": [{
	"address": "google_storage_bucket.good",
	"type": "google_storage_bucket",
	"values": {"labels": {
		"project": "x",
		"environment": "dev",
		"managed_by": "terraform",
		"compliance_scope": "cge-p-lab",
	}},
}]}}}

partial := {"planned_values": {"root_module": {"resources": [{
	"address": "google_storage_bucket.bad",
	"type": "google_storage_bucket",
	"values": {"labels": {"project": "x"}},
}]}}}

no_labels := {"planned_values": {"root_module": {"resources": [{
	"address": "google_storage_bucket.naked",
	"type": "google_storage_bucket",
	"values": {},
}]}}}

test_complete_passes if {
	count(cm6.deny) == 0 with input as complete
}

test_partial_fails if {
	some msg in cm6.deny with input as partial
	contains(msg, "CM-6")
}

test_no_labels_fails if {
	some msg in cm6.deny with input as no_labels
	contains(msg, "CM-6")
}