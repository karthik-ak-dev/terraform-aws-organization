# ============================================================================
# COMPLETE AWS ORGANIZATION EXAMPLE
# ============================================================================
#
# This example demonstrates how to use the terraform-aws-organization module
# to set up a complete multi-account AWS environment with:
# - AWS Organizations with Stage and Production OUs
# - Separate AWS accounts for each environment
# - IAM Identity Center (SSO) with granular permission sets
#
# PREREQUISITES:
# - AWS CLI configured with administrative access to management account
# - Terraform >= 1.0 installed
# - S3 bucket and DynamoDB table for state storage
# - Unique email addresses for each AWS account
# - IAM Identity Center manually enabled in AWS Console

# ============================================================================
# TERRAFORM BACKEND CONFIGURATION
# ============================================================================
# Remote state storage in S3 with DynamoDB locking for team collaboration.
# Update these values with your specific bucket and region information.

terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"    # UPDATE: Your S3 bucket name
    key            = "organization/terraform.tfstate" # State file path
    region         = "us-east-1"                      # UPDATE: Your preferred region
    encrypt        = true                             # Encrypt state file at rest
    dynamodb_table = "terraform-state-locks"          # DynamoDB table for locking
  }
}

# ============================================================================
# PROVIDER CONFIGURATION
# ============================================================================

module "providers" {
  source = "../../modules/providers"
}

provider "aws" {
  region = var.region
}

# ============================================================================
# DATA SOURCES
# ============================================================================

data "aws_caller_identity" "current" {}

# ============================================================================
# PHASE 1: AWS ORGANIZATION FOUNDATION
# ============================================================================

module "organization" {
  source = "../../modules/organization"

  organization_name  = var.organization_name
  stage_ou_name      = var.stage_ou_name
  production_ou_name = var.production_ou_name
}

# ============================================================================
# PHASE 2: AWS ACCOUNTS CREATION
# ============================================================================

module "accounts" {
  source = "../../modules/accounts"

  stage_ou_id      = module.organization.stage_ou_id
  production_ou_id = module.organization.production_ou_id

  # Stage Account
  create_stage_account = var.create_stage_account
  stage_account_name   = var.stage_account_name
  stage_account_email  = var.stage_account_email

  # Production Account
  create_prod_account = var.create_prod_account
  prod_account_name   = var.prod_account_name
  prod_account_email  = var.prod_account_email

  depends_on = [module.organization]
}

# ============================================================================
# PHASE 3: IAM IDENTITY CENTER (AWS SSO)
# ============================================================================

module "identity_center" {
  source = "../../modules/identity-center"

  stage_account_id      = module.accounts.stage_account_id
  prod_account_id       = module.accounts.prod_account_id
  management_account_id = data.aws_caller_identity.current.account_id

  stage_account_exists = var.create_stage_account
  prod_account_exists  = var.create_prod_account

  create_account_assignments = var.create_account_assignments
  organization_dependency    = module.organization.organization_id

  depends_on = [module.organization, module.accounts]
}
