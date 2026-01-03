# ============================================================================
# VARIABLES FOR AWS ACCOUNTS MODULE
# ============================================================================
#
# This file defines the input variables for the AWS Accounts module.
# These variables control which accounts are created, their configuration,
# and their placement within the organizational structure.
#
# IMPORTANT: Email addresses must be unique across ALL AWS accounts globally.
# Each account requires a unique email address that has never been used
# for any AWS account before.

# ============================================================================
# ORGANIZATIONAL UNIT DEPENDENCIES
# ============================================================================
# These variables receive the OU IDs from the organization module and
# determine where each account will be placed in the organizational hierarchy.

variable "stage_ou_id" {
  description = <<-EOT
    ID of the Stage organizational unit.

    This OU contains accounts for development and staging workloads:
    - Development environments
    - Testing environments
    - Staging environments
    - Sandbox environments

    Accounts placed in this OU inherit development-friendly policies
    with cost controls and relaxed security for development flexibility.
  EOT
  type        = string

  validation {
    condition     = can(regex("^ou-[0-9a-z]{4,32}-[0-9a-z]{8,32}$", var.stage_ou_id))
    error_message = "Stage OU ID must be a valid AWS Organizations OU ID (format: ou-xxxx-xxxxxxxx)."
  }
}

variable "production_ou_id" {
  description = <<-EOT
    ID of the Production organizational unit.

    This OU contains accounts for live production workloads:
    - Production environments
    - Production disaster recovery
    - Production backup environments

    Accounts placed in this OU inherit enhanced security policies,
    strict change management controls, and compliance requirements.
  EOT
  type        = string

  validation {
    condition     = can(regex("^ou-[0-9a-z]{4,32}-[0-9a-z]{8,32}$", var.production_ou_id))
    error_message = "Production OU ID must be a valid AWS Organizations OU ID (format: ou-xxxx-xxxxxxxx)."
  }
}

# ============================================================================
# STAGE ACCOUNT CONFIGURATION
# ============================================================================

variable "create_stage_account" {
  description = <<-EOT
    Whether to create the stage account.

    Set to true to create a dedicated account for:
    - Development and testing activities
    - Staging environments for pre-production validation
    - CI/CD pipeline testing and validation
    - Developer experimentation and learning

    Set to false if:
    - You prefer a different account structure
    - You're using existing accounts for staging
    - You want to create accounts manually
  EOT
  type        = bool
  default     = true
}

variable "stage_account_name" {
  description = <<-EOT
    Human-readable name for the stage account.

    This name appears in:
    - AWS Organizations console
    - Account selection interfaces
    - Billing and cost reports
    - IAM Identity Center account list

    Choose a name that clearly identifies the account's purpose.
    Common patterns: "Stage", "Development", "Dev-Stage", "Non-Prod"
  EOT
  type        = string
  default     = "Stage"

  validation {
    condition     = length(var.stage_account_name) > 0 && length(var.stage_account_name) <= 50
    error_message = "Stage account name must be between 1 and 50 characters."
  }
}

variable "stage_account_email" {
  description = <<-EOT
    Email address for the stage account root user.

    CRITICAL REQUIREMENTS:
    - Must be unique across ALL AWS accounts globally (not just your organization)
    - Cannot be reused if previously associated with any AWS account
    - Should be a monitored email address for security notifications
    - Consider using a pattern like: aws-stage@yourcompany.com

    SECURITY CONSIDERATIONS:
    - This email receives security notifications and password reset emails
    - Should be accessible by your operations team
    - Consider using a shared mailbox rather than individual email
    - Document who has access to this email address

    This email address cannot be changed after account creation.
  EOT
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.stage_account_email))
    error_message = "Stage account email must be a valid email address format."
  }
}

# ============================================================================
# PRODUCTION ACCOUNT CONFIGURATION
# ============================================================================

variable "create_prod_account" {
  description = "Whether to create the production account"
  type        = bool
  default     = true
}

variable "prod_account_name" {
  description = "Name of the production account"
  type        = string
  default     = "Production"
}

variable "prod_account_email" {
  description = "Email address for the production account (must be unique)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.prod_account_email))
    error_message = "Production account email must be a valid email address format."
  }
}
