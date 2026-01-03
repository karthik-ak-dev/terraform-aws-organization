# ============================================================================
# OUTPUTS FOR IAM IDENTITY CENTER MODULE
# ============================================================================

output "sso_instance_arn" {
  description = "ARN of the SSO instance"
  value       = local.sso_instance_arn
}

output "identity_store_id" {
  description = "ID of the identity store"
  value       = local.identity_store_id
}

# Permission Set ARNs
output "organization_admin_permission_set_arn" {
  description = "ARN of the Organization Admin permission set"
  value       = aws_ssoadmin_permission_set.organization_admin.arn
}

output "readonly_permission_set_arn" {
  description = "ARN of the ReadOnly permission set"
  value       = aws_ssoadmin_permission_set.readonly.arn
}

output "poweruser_permission_set_arn" {
  description = "ARN of the PowerUser permission set"
  value       = aws_ssoadmin_permission_set.poweruser.arn
}

output "admin_permission_set_arn" {
  description = "ARN of the Admin permission set"
  value       = aws_ssoadmin_permission_set.admin.arn
}

# Group IDs
output "org_admin_group_id" {
  description = "ID of the OrgAdmin group"
  value       = aws_identitystore_group.org_admin.group_id
}

output "stage_readonly_group_id" {
  description = "ID of the StageReadOnly group"
  value       = aws_identitystore_group.stage_readonly.group_id
}

output "stage_poweruser_group_id" {
  description = "ID of the StagePowerUser group"
  value       = aws_identitystore_group.stage_poweruser.group_id
}

output "stage_admin_group_id" {
  description = "ID of the StageAdmin group"
  value       = aws_identitystore_group.stage_admin.group_id
}

output "prod_readonly_group_id" {
  description = "ID of the ProdReadOnly group"
  value       = aws_identitystore_group.prod_readonly.group_id
}

output "prod_poweruser_group_id" {
  description = "ID of the ProdPowerUser group"
  value       = aws_identitystore_group.prod_poweruser.group_id
}

output "prod_admin_group_id" {
  description = "ID of the ProdAdmin group"
  value       = aws_identitystore_group.prod_admin.group_id
}

# Convenient map of all permission sets
output "permission_sets" {
  description = "Map of all permission set ARNs"
  value = {
    organization_admin = aws_ssoadmin_permission_set.organization_admin.arn
    readonly           = aws_ssoadmin_permission_set.readonly.arn
    poweruser          = aws_ssoadmin_permission_set.poweruser.arn
    admin              = aws_ssoadmin_permission_set.admin.arn
  }
}

# Convenient map of all groups
output "groups" {
  description = "Map of all group IDs"
  value = {
    org_admin       = aws_identitystore_group.org_admin.group_id
    stage_readonly  = aws_identitystore_group.stage_readonly.group_id
    stage_poweruser = aws_identitystore_group.stage_poweruser.group_id
    stage_admin     = aws_identitystore_group.stage_admin.group_id
    prod_readonly   = aws_identitystore_group.prod_readonly.group_id
    prod_poweruser  = aws_identitystore_group.prod_poweruser.group_id
    prod_admin      = aws_identitystore_group.prod_admin.group_id
  }
}

# Account assignment status
output "account_assignments_created" {
  description = "Status of account assignments creation"
  value = {
    org_admin_management_access = var.create_account_assignments
    stage_readonly_access       = var.create_account_assignments && var.stage_account_exists
    stage_poweruser_access      = var.create_account_assignments && var.stage_account_exists
    stage_admin_access          = var.create_account_assignments && var.stage_account_exists
    prod_readonly_access        = var.create_account_assignments && var.prod_account_exists
    prod_poweruser_access       = var.create_account_assignments && var.prod_account_exists
    prod_admin_access           = var.create_account_assignments && var.prod_account_exists
  }
}
