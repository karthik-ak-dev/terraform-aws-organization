# ============================================================================
# VARIABLES FOR COMPLETE EXAMPLE
# ============================================================================

variable "region" {
  description = "AWS region for the management account"
  type        = string
  default     = "us-east-1"
}

# Organization Configuration
variable "organization_name" {
  description = "Name of the AWS Organization"
  type        = string
  default     = "my-organization"
}

variable "stage_ou_name" {
  description = "Name for the Stage Organizational Unit"
  type        = string
  default     = "Stage"
}

variable "production_ou_name" {
  description = "Name for the Production Organizational Unit"
  type        = string
  default     = "Production"
}

# Stage Account Configuration
variable "create_stage_account" {
  description = "Whether to create the stage account"
  type        = bool
  default     = true
}

variable "stage_account_name" {
  description = "Name of the stage account"
  type        = string
  default     = "Stage"
}

variable "stage_account_email" {
  description = "Email address for the stage account (must be globally unique)"
  type        = string
}

# Production Account Configuration
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
  description = "Email address for the production account (must be globally unique)"
  type        = string
}

# IAM Identity Center Configuration
variable "create_account_assignments" {
  description = "Whether to create account assignments linking groups to accounts"
  type        = bool
  default     = true
}
