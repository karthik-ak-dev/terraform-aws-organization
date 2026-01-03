# ============================================================================
# AWS ORGANIZATIONS MODULE
# ============================================================================
#
# This module creates and configures the foundational AWS Organizations
# structure that serves as the management layer for a multi-account AWS
# environment. It establishes the organizational hierarchy and enables
# necessary AWS services.
#
# Key Components:
# 1. AWS Organization with all features enabled
# 2. Organizational Units (OUs) for logical account grouping
# 3. Service access principals for AWS service integration
#
# This module should be deployed first as other modules depend on the
# organizational structure it creates.

# ============================================================================
# AWS ORGANIZATION CREATION
# ============================================================================

# Create the AWS Organization
# This is the root container for all AWS accounts in the organization.
# Enabling "ALL" features provides access to advanced capabilities like
# Service Control Policies, backup policies, and consolidated billing.
resource "aws_organizations_organization" "main" {
  # AWS Service Access Principals
  # These services are granted permission to operate across the organization.
  # Each service listed here can access and manage resources across all
  # member accounts according to their specific capabilities.
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com", # Organization-wide CloudTrail logging
    "config.amazonaws.com",     # Configuration compliance across accounts
    "sso.amazonaws.com",        # IAM Identity Center (Single Sign-On)
    "account.amazonaws.com",    # Account management and creation
    "guardduty.amazonaws.com",  # Security threat detection
    "securityhub.amazonaws.com" # Centralized security findings
  ]

  # Feature Set: "ALL" enables advanced organizational features
  # - Service Control Policies (SCPs) for access governance
  # - Backup policies for automated data protection
  # - Advanced account management capabilities
  # - Consolidated billing and cost management
  feature_set = "ALL"

  # Policy Types: Enable specific policy frameworks
  # SERVICE_CONTROL_POLICY: Provides guardrails for account access
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY"
  ]
}

# Wait for organization to be fully ready before creating OUs
resource "time_sleep" "wait_for_organization" {
  depends_on      = [aws_organizations_organization.main]
  create_duration = "30s"
}

# ============================================================================
# ORGANIZATIONAL UNITS (OUs)
# ============================================================================
# Organizational Units provide a hierarchical structure for organizing
# AWS accounts. They enable the application of policies to groups of
# accounts and provide logical separation between development and production
# environments for better governance and policy isolation.

# Stage OU
# Purpose: Contains accounts for development, testing, and staging workloads
# Typical Accounts: Development, Staging, Testing, Sandbox
# Policies Applied: Development-friendly policies, cost controls, relaxed security
# Access Pattern: Developers have full access, relaxed change management
resource "aws_organizations_organizational_unit" "stage" {
  name      = var.stage_ou_name
  parent_id = aws_organizations_organization.main.roots[0].id

  tags = {
    Name        = "${var.stage_ou_name} OU"
    Description = "Organizational unit for stage environments"
    Purpose     = "Stage and testing workloads"
    Environment = "stage"
    ManagedBy   = "terraform"
  }

  depends_on = [time_sleep.wait_for_organization]
}

# Production OU
# Purpose: Contains accounts for live production workloads
# Typical Accounts: Production, Production-DR, Production-Backup
# Policies Applied: Enhanced security policies, strict change management, compliance controls
# Access Pattern: Restricted access, enhanced monitoring, strict change approval
resource "aws_organizations_organizational_unit" "production" {
  name      = var.production_ou_name
  parent_id = aws_organizations_organization.main.roots[0].id

  tags = {
    Name        = "${var.production_ou_name} OU"
    Description = "Organizational unit for production environments"
    Purpose     = "Live production workloads and services"
    Environment = "production"
    Criticality = "high"
    ManagedBy   = "terraform"
  }

  depends_on = [time_sleep.wait_for_organization]
}
