# ============================================================================
# AWS ACCOUNTS MANAGEMENT MODULE
# ============================================================================
#
# This module creates and manages AWS accounts within the organization.
# It implements a multi-account strategy that provides:
#
# 1. ISOLATION: Each environment (stage, prod) runs in separate accounts
# 2. SECURITY: Account boundaries provide strong security isolation
# 3. BILLING: Clear cost allocation and budget management per account
# 4. COMPLIANCE: Easier compliance and audit with separated environments
# 5. BLAST RADIUS: Limits impact of issues to individual accounts
#
# Account Types Created:
# - Stage Account: Development and testing workloads
# - Production Account: Live production workloads
#
# Each account is created with:
# - Unique email address (required by AWS)
# - Appropriate Organizational Unit placement
# - Billing access restrictions
# - Lifecycle protection to prevent accidental deletion
# - Comprehensive tagging for management and cost allocation

# ============================================================================
# STAGE ACCOUNT
# ============================================================================

# Stage Account for Development and Testing
# Purpose: Provides an isolated environment for development, testing, and staging
# Workloads: Development applications, testing infrastructure, CI/CD pipelines
# Access: Developers have full access, DevOps have management access
# Cost Profile: Variable usage, cost optimization important
# Security: Relaxed policies for development flexibility
resource "aws_organizations_account" "stage" {
  count = var.create_stage_account ? 1 : 0

  # Account Configuration
  name  = var.stage_account_name  # Human-readable account name
  email = var.stage_account_email # Must be unique across all AWS accounts globally

  # Billing Access: Deny IAM user access to billing information
  # This centralizes billing management to the organization management account
  # and prevents developers from accessing sensitive billing data
  iam_user_access_to_billing = "DENY"

  # Organizational Placement: Place in Stage OU
  # This ensures the account inherits development-friendly policies applied to the Stage OU
  parent_id = var.stage_ou_id

  # Resource Tagging: Comprehensive tags for management and cost allocation
  tags = {
    Name        = var.stage_account_name
    Environment = "stage"
    Purpose     = "Development and testing workloads"
    CostCenter  = "Engineering"
    Owner       = "Development Team"
    ManagedBy   = "terraform"
  }

  # Lifecycle Protection: Prevent accidental account deletion
  # Uncomment for production use
  # lifecycle {
  #   prevent_destroy = true
  #   ignore_changes = [iam_user_access_to_billing]
  # }
}

# ============================================================================
# PRODUCTION ACCOUNT
# ============================================================================

# Production Account for Live Workloads
# Purpose: Hosts live production applications and services serving real users
# Workloads: Production applications, databases, monitoring, alerting
# Access: Restricted access, DevOps have limited admin access, developers read-only
# Cost Profile: Predictable usage, focus on reliability and performance
# Security: Enhanced security policies, strict change management
resource "aws_organizations_account" "prod" {
  count = var.create_prod_account ? 1 : 0

  # Account Configuration
  name  = var.prod_account_name  # Human-readable account name
  email = var.prod_account_email # Must be unique across all AWS accounts globally

  # Billing Access: Deny IAM user access to billing information
  # Production account users should not have access to billing data
  # All billing management is centralized in the management account
  iam_user_access_to_billing = "DENY"

  # Organizational Placement: Place in Production OU
  # Inherits enhanced security policies and strict change management controls
  parent_id = var.production_ou_id

  # Resource Tagging: Enhanced tagging for production environment
  tags = {
    Name         = var.prod_account_name
    Environment  = "production"
    Purpose      = "Live production workloads"
    CostCenter   = "Operations"
    Owner        = "DevOps Team"
    Criticality  = "High"
    BackupPolicy = "Required"
    ManagedBy    = "terraform"
  }

  # Lifecycle Protection: Critical protection for production account
  # Uncomment for production use
  # lifecycle {
  #   prevent_destroy = true
  #   ignore_changes = [iam_user_access_to_billing]
  # }
}
