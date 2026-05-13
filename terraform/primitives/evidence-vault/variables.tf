variable "project_name" {
  type        = string
  description = "Tag prefix and bucket name component. Same pattern as labs 2.3 and 2.4."
  default     = "cgep-lab"
}

variable "lock_mode" {
  type        = string
  description = "Object Lock retention mode. GOVERNANCE for lab work (bypassable for cleanup); COMPLIANCE for real evidence (cannot be bypassed)."
  default     = "GOVERNANCE"
  validation {
    condition     = contains(["GOVERNANCE", "COMPLIANCE"], var.lock_mode)
    error_message = "lock_mode must be GOVERNANCE or COMPLIANCE."
  }
}

variable "retention_days" {
  type        = number
  description = "Default retention applied to every uploaded object."
  default     = 1
}
