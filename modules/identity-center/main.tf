# ============================================================================
# IAM IDENTITY CENTER MODULE
# ============================================================================
# This module creates a clean, simple IAM Identity Center setup with:
# - Organization Admin permission set for management account
# - ReadOnly, PowerUser, Admin permission sets for Stage/Production accounts
# - Account-specific groups for granular access control
#
# IMPORTANT PREREQUISITE:
# IAM Identity Center MUST be manually enabled before running this Terraform module.
#
# MANUAL SETUP REQUIRED:
# 1. Go to AWS Console -> IAM Identity Center
# 2. Click "Enable" to activate IAM Identity Center
# 3. Choose your identity source (AWS Identity Center directory recommended for new setups)
# 4. Wait for the service to be fully enabled (this can take a few minutes)
# 5. Only then run terraform plan/apply
#
# WHY MANUAL ENABLEMENT IS REQUIRED:
# - IAM Identity Center enablement is a one-time organization-level operation
# - It requires interactive choices (identity source selection)
# - AWS doesn't provide a reliable Terraform resource for initial enablement
# - The service needs time to propagate across all AWS regions
#
# VERIFICATION:
# You can verify IAM Identity Center is enabled by running:
# aws sso-admin list-instances
# This should return at least one instance with an ARN and Identity Store ID.

# ============================================================================
# DATA SOURCES AND LOCALS
# ============================================================================

# Get the SSO instance that is created when you enable IAM Identity Center
# This will fail if IAM Identity Center is not manually enabled first
data "aws_ssoadmin_instances" "main" {
  depends_on = [var.organization_dependency]
}

# Local values for easier reference throughout the module
locals {
  sso_instance_arn  = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
}

# ============================================================================
# PERMISSION SETS
# ============================================================================

# Organization Admin Permission Set (Management Account)
resource "aws_ssoadmin_permission_set" "organization_admin" {
  name             = "OrganizationAdmin"
  description      = "Administrative access for AWS Organizations and IAM Identity Center management"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT4H" # 4 hours

  tags = {
    Name        = "Organization Admin"
    Environment = "management"
    ManagedBy   = "terraform"
  }
}

# ReadOnly Permission Set (Stage & Production)
resource "aws_ssoadmin_permission_set" "readonly" {
  name             = "ReadOnly"
  description      = "Read-only access to AWS resources for monitoring and troubleshooting"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT8H" # 8 hours

  tags = {
    Name      = "ReadOnly"
    Purpose   = "Monitoring and troubleshooting"
    ManagedBy = "terraform"
  }
}

# PowerUser Permission Set (Stage & Production)
resource "aws_ssoadmin_permission_set" "poweruser" {
  name             = "PowerUser"
  description      = "PowerUser access with restrictions on IAM, organization management, and billing/cost access"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT8H" # 8 hours

  tags = {
    Name      = "PowerUser"
    Purpose   = "Development and infrastructure work without billing access"
    ManagedBy = "terraform"
  }
}

# Admin Permission Set (Stage & Production)
resource "aws_ssoadmin_permission_set" "admin" {
  name             = "Admin"
  description      = "Full administrative access to AWS resources"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT4H" # 4 hours

  tags = {
    Name      = "Admin"
    Purpose   = "Full administrative access"
    ManagedBy = "terraform"
  }
}

# ============================================================================
# MANAGED POLICY ATTACHMENTS
# ============================================================================

# Organization Admin Policies
resource "aws_ssoadmin_managed_policy_attachment" "org_admin_orgs" {
  instance_arn       = local.sso_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AWSOrganizationsFullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.organization_admin.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "org_admin_sso" {
  instance_arn       = local.sso_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AWSSSODirectoryAdministrator"
  permission_set_arn = aws_ssoadmin_permission_set.organization_admin.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "org_admin_full" {
  instance_arn       = local.sso_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.organization_admin.arn
}

# ReadOnly Policy
resource "aws_ssoadmin_managed_policy_attachment" "readonly" {
  instance_arn       = local.sso_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
}

# PowerUser Policy
resource "aws_ssoadmin_managed_policy_attachment" "poweruser" {
  instance_arn       = local.sso_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  permission_set_arn = aws_ssoadmin_permission_set.poweruser.arn
}

# Admin Policy
resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = local.sso_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
}

# ============================================================================
# INLINE POLICIES
# ============================================================================

# PowerUser restrictions (prevent dangerous IAM actions and billing access)
resource "aws_ssoadmin_permission_set_inline_policy" "poweruser_restrictions" {
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyDangerousActions"
        Effect = "Deny"
        Action = [
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "organizations:*",
          "account:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyBillingAndCostAccess"
        Effect = "Deny"
        Action = [
          "ce:*",                  # Cost Explorer - all actions
          "cur:*",                 # Cost and Usage Reports
          "aws-portal:*",          # AWS Billing Console
          "pricing:*",             # AWS Pricing
          "budgets:*",             # AWS Budgets
          "billing:*",             # Billing
          "purchase-orders:*",     # Purchase Orders
          "tax:*",                 # Tax Settings
          "consolidatedbilling:*", # Consolidated Billing
          "invoicing:*",           # Invoicing
          "payments:*",            # Payment Methods
          "freetier:*"             # Free Tier
        ]
        Resource = "*"
      }
    ]
  })
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.poweruser.arn
}

# ============================================================================
# USER GROUPS - ACCOUNT SPECIFIC
# ============================================================================

# Organization Admin Group
resource "aws_identitystore_group" "org_admin" {
  display_name      = "OrgAdmin"
  description       = "Organization administrators with management account access"
  identity_store_id = local.identity_store_id
}

# Stage Account Groups
resource "aws_identitystore_group" "stage_readonly" {
  display_name      = "StageReadOnly"
  description       = "Read-only access to Stage account only"
  identity_store_id = local.identity_store_id
}

resource "aws_identitystore_group" "stage_poweruser" {
  display_name      = "StagePowerUser"
  description       = "PowerUser access to Stage account only"
  identity_store_id = local.identity_store_id
}

resource "aws_identitystore_group" "stage_admin" {
  display_name      = "StageAdmin"
  description       = "Admin access to Stage account only"
  identity_store_id = local.identity_store_id
}

# Production Account Groups
resource "aws_identitystore_group" "prod_readonly" {
  display_name      = "ProdReadOnly"
  description       = "Read-only access to Production account only"
  identity_store_id = local.identity_store_id
}

resource "aws_identitystore_group" "prod_poweruser" {
  display_name      = "ProdPowerUser"
  description       = "PowerUser access to Production account only"
  identity_store_id = local.identity_store_id
}

resource "aws_identitystore_group" "prod_admin" {
  display_name      = "ProdAdmin"
  description       = "Admin access to Production account only"
  identity_store_id = local.identity_store_id
}

# ============================================================================
# ACCOUNT ASSIGNMENTS - ACCOUNT SPECIFIC
# ============================================================================

# Management Account - Only OrgAdmin group gets Organization Admin access
resource "aws_ssoadmin_account_assignment" "org_admin_management" {
  count = var.create_account_assignments ? 1 : 0

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.organization_admin.arn
  principal_id       = aws_identitystore_group.org_admin.group_id
  principal_type     = "GROUP"
  target_id          = var.management_account_id
  target_type        = "AWS_ACCOUNT"
}

# Stage Account Assignments
resource "aws_ssoadmin_account_assignment" "stage_readonly" {
  count = var.create_account_assignments && var.stage_account_exists ? 1 : 0

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  principal_id       = aws_identitystore_group.stage_readonly.group_id
  principal_type     = "GROUP"
  target_id          = var.stage_account_id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "stage_poweruser" {
  count = var.create_account_assignments && var.stage_account_exists ? 1 : 0

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.poweruser.arn
  principal_id       = aws_identitystore_group.stage_poweruser.group_id
  principal_type     = "GROUP"
  target_id          = var.stage_account_id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "stage_admin" {
  count = var.create_account_assignments && var.stage_account_exists ? 1 : 0

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = aws_identitystore_group.stage_admin.group_id
  principal_type     = "GROUP"
  target_id          = var.stage_account_id
  target_type        = "AWS_ACCOUNT"
}

# Production Account Assignments
resource "aws_ssoadmin_account_assignment" "prod_readonly" {
  count = var.create_account_assignments && var.prod_account_exists ? 1 : 0

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  principal_id       = aws_identitystore_group.prod_readonly.group_id
  principal_type     = "GROUP"
  target_id          = var.prod_account_id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "prod_poweruser" {
  count = var.create_account_assignments && var.prod_account_exists ? 1 : 0

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.poweruser.arn
  principal_id       = aws_identitystore_group.prod_poweruser.group_id
  principal_type     = "GROUP"
  target_id          = var.prod_account_id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "prod_admin" {
  count = var.create_account_assignments && var.prod_account_exists ? 1 : 0

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = aws_identitystore_group.prod_admin.group_id
  principal_type     = "GROUP"
  target_id          = var.prod_account_id
  target_type        = "AWS_ACCOUNT"
}
