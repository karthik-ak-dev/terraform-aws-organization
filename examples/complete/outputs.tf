# ============================================================================
# OUTPUTS FOR COMPLETE EXAMPLE
# ============================================================================

# Organization outputs
output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = module.organization.organization_id
}

output "organization_master_account_id" {
  description = "The ID of the master account"
  value       = module.organization.organization_master_account_id
}

# Account outputs
output "stage_account_id" {
  description = "ID of the stage account"
  value       = module.accounts.stage_account_id
}

output "prod_account_id" {
  description = "ID of the production account"
  value       = module.accounts.prod_account_id
}

# OU outputs
output "stage_ou_id" {
  description = "ID of the stage organizational unit"
  value       = module.organization.stage_ou_id
}

output "production_ou_id" {
  description = "ID of the production organizational unit"
  value       = module.organization.production_ou_id
}

output "all_account_ids" {
  description = "Map of all created account IDs"
  value       = module.accounts.all_account_ids
}

# IAM Identity Center outputs
output "sso_instance_arn" {
  description = "ARN of the SSO instance"
  value       = module.identity_center.sso_instance_arn
}

output "identity_store_id" {
  description = "ID of the identity store"
  value       = module.identity_center.identity_store_id
}

output "permission_sets" {
  description = "Map of all permission set ARNs"
  value       = module.identity_center.permission_sets
}

output "groups" {
  description = "Map of all SSO group IDs"
  value       = module.identity_center.groups
}
