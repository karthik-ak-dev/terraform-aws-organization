# ============================================================================
# OUTPUTS FOR AWS ORGANIZATIONS MODULE
# ============================================================================

output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = aws_organizations_organization.main.id
}

output "organization_arn" {
  description = "The ARN of the AWS Organization"
  value       = aws_organizations_organization.main.arn
}

output "organization_master_account_id" {
  description = "The ID of the master account"
  value       = aws_organizations_organization.main.master_account_id
}

output "organization_master_account_email" {
  description = "The email of the master account"
  value       = aws_organizations_organization.main.master_account_email
}

output "root_id" {
  description = "The ID of the organization root"
  value       = aws_organizations_organization.main.roots[0].id
}

output "stage_ou_id" {
  description = "The ID of the Stage organizational unit"
  value       = aws_organizations_organizational_unit.stage.id
}

output "production_ou_id" {
  description = "The ID of the Production organizational unit"
  value       = aws_organizations_organizational_unit.production.id
}
