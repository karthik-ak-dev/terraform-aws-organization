# ============================================================================
# OUTPUTS FOR AWS ACCOUNTS MODULE
# ============================================================================

output "stage_account_id" {
  description = "ID of the stage account"
  value       = var.create_stage_account ? aws_organizations_account.stage[0].id : null
}

output "stage_account_arn" {
  description = "ARN of the stage account"
  value       = var.create_stage_account ? aws_organizations_account.stage[0].arn : null
}

output "stage_account_email" {
  description = "Email of the stage account"
  value       = var.create_stage_account ? aws_organizations_account.stage[0].email : null
}

output "prod_account_id" {
  description = "ID of the production account"
  value       = var.create_prod_account ? aws_organizations_account.prod[0].id : null
}

output "prod_account_arn" {
  description = "ARN of the production account"
  value       = var.create_prod_account ? aws_organizations_account.prod[0].arn : null
}

output "prod_account_email" {
  description = "Email of the production account"
  value       = var.create_prod_account ? aws_organizations_account.prod[0].email : null
}

# Convenient map of all account IDs
output "all_account_ids" {
  description = "Map of all created account IDs"
  value = {
    stage = var.create_stage_account ? aws_organizations_account.stage[0].id : null
    prod  = var.create_prod_account ? aws_organizations_account.prod[0].id : null
  }
}
