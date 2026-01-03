# ============================================================================
# VARIABLES FOR IAM IDENTITY CENTER MODULE
# ============================================================================
#
# This module creates the foundational IAM Identity Center infrastructure
# including permission sets, groups, and account assignments. User creation
# is intentionally excluded for scalability and operational flexibility.

# ============================================================================
# ACCOUNT IDENTIFIERS
# ============================================================================

variable "stage_account_id" {
  description = <<-EOT
    AWS Account ID for the stage/development environment.
    If provided, groups will be assigned appropriate permissions to this account.
    Leave empty if stage account doesn't exist or shouldn't receive assignments.
  EOT
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^$|^[0-9]{12}$", var.stage_account_id))
    error_message = "Stage account ID must be empty or a valid 12-digit AWS account ID."
  }
}

variable "prod_account_id" {
  description = <<-EOT
    AWS Account ID for the production environment.
    If provided, groups will be assigned appropriate permissions to this account.
    Leave empty if production account doesn't exist or shouldn't receive assignments.
  EOT
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^$|^[0-9]{12}$", var.prod_account_id))
    error_message = "Production account ID must be empty or a valid 12-digit AWS account ID."
  }
}

variable "stage_account_exists" {
  description = <<-EOT
    Whether the stage account exists and should receive account assignments.
    Set to true if stage account exists, false otherwise.
    This avoids dependency cycles when account IDs are not yet available.
  EOT
  type        = bool
  default     = false
}

variable "prod_account_exists" {
  description = <<-EOT
    Whether the production account exists and should receive account assignments.
    Set to true if production account exists, false otherwise.
    This avoids dependency cycles when account IDs are not yet available.
  EOT
  type        = bool
  default     = false
}

variable "management_account_id" {
  description = <<-EOT
    AWS Account ID for the management/organization account.
    This is required as it's where IAM Identity Center runs and where
    organization administrators need access.
  EOT
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.management_account_id))
    error_message = "Management account ID must be a valid 12-digit AWS account ID."
  }
}

# ============================================================================
# DEPENDENCIES
# ============================================================================

variable "organization_dependency" {
  description = <<-EOT
    Dependency variable to ensure the organization is created before
    attempting to access SSO instances. Pass the organization resource
    or any resource that depends on the organization being fully created.
  EOT
  type        = any
  default     = null
}

# ============================================================================
# FEATURE TOGGLES
# ============================================================================

variable "create_account_assignments" {
  description = <<-EOT
    Whether to create account assignments linking groups to accounts.

    Set to true (default) to automatically create the standard account assignments:
    - Developers: DeveloperAccess to stage account
    - DevOps: DeveloperAccess to stage, ReadOnly + Admin to production
    - Admins: Full access to all accounts

    Set to false if you want to manage account assignments manually or
    through a separate process.
  EOT
  type        = bool
  default     = true
}
