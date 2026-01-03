# Terraform AWS Organization

Production-ready Terraform modules for setting up a complete AWS multi-account organization with IAM Identity Center (SSO).

## Overview

This repository provides a modular, enterprise-grade solution for bootstrapping AWS Organizations with:

- **Multi-Account Strategy**: Separate Stage and Production accounts for workload isolation
- **Organizational Units**: Logical grouping with policy inheritance
- **IAM Identity Center**: Centralized SSO with granular permission sets
- **Security Best Practices**: Least-privilege access, billing restrictions, and audit-ready configuration

## Architecture

```
┌────────────────────────────────────────────────────────────────────────────┐
│                         AWS Organization (Root)                            │
│                                                                            │
│  ┌─────────────────────────────┐    ┌─────────────────────────────┐        │
│  │       Stage OU              │    │      Production OU          │        │
│  │                             │    │                             │        │
│  │  ┌───────────────────────┐  │    │  ┌───────────────────────┐  │        │
│  │  │    Stage Account      │  │    │  │  Production Account   │  │        │
│  │  │                       │  │    │  │                       │  │        │
│  │  │  - Dev workloads      │  │    │  │  - Live services      │  │        │
│  │  │  - Testing            │  │    │  │  - Customer data      │  │        │
│  │  │  - CI/CD pipelines    │  │    │  │  - High availability  │  │        │
│  │  └───────────────────────┘  │    │  └───────────────────────┘  │        │
│  └─────────────────────────────┘    └─────────────────────────────┘        │
│                                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    IAM Identity Center (SSO)                        │   │
│  │                                                                     │   │
│  │   Permission Sets:           Groups:                                │   │
│  │   ├── OrganizationAdmin      ├── OrgAdmin                           │   │
│  │   ├── Admin                  ├── StageAdmin / ProdAdmin             │   │
│  │   ├── PowerUser              ├── StagePowerUser / ProdPowerUser     │   │
│  │   └── ReadOnly               └── StageReadOnly / ProdReadOnly       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────────┘
```

## Modules

| Module | Description |
|--------|-------------|
| [organization](./modules/organization) | Creates AWS Organization with OUs and enables required services |
| [accounts](./modules/accounts) | Provisions Stage and Production AWS accounts |
| [identity-center](./modules/identity-center) | Sets up IAM Identity Center with permission sets and groups |
| [providers](./modules/providers) | Centralized provider version management |

## Quick Start

### Prerequisites

1. **AWS CLI** configured with admin access to your management account
2. **Terraform** >= 1.0
3. **IAM Identity Center** manually enabled in AWS Console (one-time setup)
4. **Unique email addresses** for each AWS account (globally unique across all of AWS)

### Enable IAM Identity Center (One-Time)

```bash
# 1. Go to AWS Console → IAM Identity Center → Enable
# 2. Choose "AWS Identity Center directory" as identity source
# 3. Wait for propagation (~2 minutes)

# Verify it's enabled:
aws sso-admin list-instances
```

### Deploy

```bash
cd examples/complete

# Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Initialize and apply
terraform init
terraform plan
terraform apply
```

## Usage

### Basic Usage

```hcl
module "organization" {
  source = "github.com/YOUR_USERNAME/terraform-aws-organization//modules/organization"

  organization_name  = "my-company"
  stage_ou_name      = "Stage"
  production_ou_name = "Production"
}

module "accounts" {
  source = "github.com/YOUR_USERNAME/terraform-aws-organization//modules/accounts"

  stage_ou_id      = module.organization.stage_ou_id
  production_ou_id = module.organization.production_ou_id

  stage_account_name  = "Stage"
  stage_account_email = "aws-stage@my-company.com"
  prod_account_name   = "Production"
  prod_account_email  = "aws-prod@my-company.com"

  depends_on = [module.organization]
}

module "identity_center" {
  source = "github.com/YOUR_USERNAME/terraform-aws-organization//modules/identity-center"

  stage_account_id      = module.accounts.stage_account_id
  prod_account_id       = module.accounts.prod_account_id
  management_account_id = data.aws_caller_identity.current.account_id

  stage_account_exists = true
  prod_account_exists  = true

  organization_dependency = module.organization.organization_id

  depends_on = [module.accounts]
}
```

### Permission Sets

| Permission Set | Access Level | Use Case |
|---------------|--------------|----------|
| OrganizationAdmin | Full org + SSO management | Organization administrators |
| Admin | AdministratorAccess | Account administrators |
| PowerUser | PowerUserAccess (with restrictions) | Developers (no IAM/billing) |
| ReadOnly | ReadOnlyAccess | Monitoring, troubleshooting |

### PowerUser Restrictions

The PowerUser permission set includes explicit denies for:

- **IAM Management**: CreateUser, DeleteUser, CreateRole, DeleteRole, AttachPolicy, DetachPolicy
- **Organization Management**: All organizations:* actions
- **Billing Access**: Cost Explorer, Budgets, Billing Console, Invoicing, Payments

## Security Features

- **Account Isolation**: Workloads isolated in separate AWS accounts
- **Least Privilege**: Account-specific groups prevent cross-account access
- **Billing Restrictions**: IAM users denied billing access; centralized in management account
- **Service Control Policies**: Framework enabled for organizational guardrails
- **Session Duration**: Time-limited sessions (4-8 hours based on privilege level)
- **Audit Trail**: All AWS service integrations enabled for organization-wide logging

## Inputs

### Organization Module

| Name | Description | Type | Default |
|------|-------------|------|---------|
| organization_name | Name of the AWS Organization | string | "my-organization" |
| stage_ou_name | Name for Stage OU | string | "Stage" |
| production_ou_name | Name for Production OU | string | "Production" |

### Accounts Module

| Name | Description | Type | Required |
|------|-------------|------|----------|
| stage_ou_id | ID of Stage OU | string | yes |
| production_ou_id | ID of Production OU | string | yes |
| stage_account_email | Email for stage account | string | yes |
| prod_account_email | Email for production account | string | yes |

### Identity Center Module

| Name | Description | Type | Required |
|------|-------------|------|----------|
| management_account_id | Management account ID | string | yes |
| stage_account_id | Stage account ID | string | no |
| prod_account_id | Production account ID | no | no |
| create_account_assignments | Create group-to-account assignments | bool | true |

## Outputs

| Name | Description |
|------|-------------|
| organization_id | AWS Organization ID |
| stage_account_id | Stage account ID |
| prod_account_id | Production account ID |
| sso_instance_arn | IAM Identity Center instance ARN |
| permission_sets | Map of permission set ARNs |
| groups | Map of SSO group IDs |

## Adding Users

Users are managed outside Terraform for operational flexibility. After deployment:

### Via AWS Console

1. Go to **IAM Identity Center → Users**
2. Create users or configure external identity provider
3. Add users to appropriate groups (StageAdmin, ProdReadOnly, etc.)

### Via AWS CLI

```bash
# Create user
aws identitystore create-user \
  --identity-store-id <IDENTITY_STORE_ID> \
  --user-name "john.doe" \
  --display-name "John Doe" \
  --emails '[{"Value":"john@company.com","Primary":true}]'

# Add to group
aws identitystore create-group-membership \
  --identity-store-id <IDENTITY_STORE_ID> \
  --group-id <GROUP_ID> \
  --member-id UserId=<USER_ID>
```

## Best Practices Implemented

1. **Multi-Account Strategy**: Environment isolation reduces blast radius
2. **Centralized Identity**: Single sign-on simplifies access management
3. **Infrastructure as Code**: All configuration version-controlled
4. **Modular Design**: Reusable modules for different scenarios
5. **Comprehensive Outputs**: Easy integration with other Terraform configurations
6. **Input Validation**: Terraform validates inputs before applying

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |
| time | ~> 0.9 |

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

**Karthik**

*AWS Platform Engineer specializing in multi-account architectures, Infrastructure as Code, and cloud security.*
