# AWS Aurora PostgreSQL Infrastructure with Terraform

## 📌 Project Overview

This project demonstrates the deployment and management of an **Amazon Aurora PostgreSQL** database environment using **Terraform Infrastructure as Code (IaC)**.

The goal of this lab is to simulate a production-oriented database infrastructure deployment while applying PostgreSQL DBA, AWS, networking, security, backup, and Infrastructure-as-Code best practices.

### Key Technologies

* **AWS Aurora PostgreSQL 17**
* **Terraform**
* **Amazon VPC**
* **Amazon RDS**
* **AWS Security Groups**
* **AWS Subnet Groups**
* **PostgreSQL**
* **Git / GitHub**
* **psql**

---

## 🏗️ Architecture

```text
                         AWS Cloud
                            │
                            │
                    ┌───────▼────────┐
                    │      VPC       │
                    │   dba-lab-vpc  │
                    └───────┬────────┘
                            │
              ┌─────────────┴─────────────┐
              │                           │
       ┌──────▼──────┐             ┌──────▼──────┐
       │   Private   │             │   Private   │
       │   Subnet    │             │   Subnet    │
       │   AZ-1      │             │   AZ-2      │
       └──────┬──────┘             └──────┬──────┘
              │                           │
              └─────────────┬─────────────┘
                            │
                    ┌───────▼────────┐
                    │ Aurora Cluster │
                    │ PostgreSQL 17  │
                    └───────┬────────┘
                            │
                 ┌──────────┴──────────┐
                 │                     │
          ┌──────▼──────┐       ┌──────▼──────┐
          │    Writer   │       │    Reader   │
          │  Instance   │       │  Instance   │
          │             │       │             │
          │ Read/Write  │       │    Read     │
          └─────────────┘       └─────────────┘
                 │                     │
                 └──────────┬──────────┘
                            │
                     PostgreSQL Clients
                         / psql
```

---

## 🎯 Project Objectives

This lab demonstrates how to:

1. Deploy Aurora PostgreSQL using Terraform.
2. Build AWS networking infrastructure using Infrastructure as Code.
3. Configure private database subnets.
4. Configure security groups for database access.
5. Deploy an Aurora PostgreSQL cluster.
6. Deploy separate writer and reader instances.
7. Configure Aurora PostgreSQL parameter groups.
8. Enable storage encryption.
9. Configure automated backups.
10. Configure backup retention.
11. Configure maintenance windows.
12. Retrieve database connection information through Terraform outputs.
13. Manage infrastructure using Git and GitHub.
14. Follow secure practices for Terraform variables and credentials.

---

## 📁 Project Structure

```text
terraform-aws-aurora-postgresql-lab/
│
├── aurora.tf
├── providers.tf
├── security.tf
├── variables.tf
├── outputs.tf
├── vpc.tf
├── .gitignore
├── .terraform.lock.hcl
└── README.md
```

### File Responsibilities

| File                  | Purpose                                                   |
| --------------------- | --------------------------------------------------------- |
| `providers.tf`        | Configures Terraform and AWS provider                     |
| `vpc.tf`              | Creates VPC and networking resources                      |
| `security.tf`         | Defines database security group rules                     |
| `aurora.tf`           | Creates Aurora cluster, parameter groups, and instances   |
| `variables.tf`        | Defines configurable Terraform variables                  |
| `outputs.tf`          | Displays endpoints and connection information             |
| `.gitignore`          | Prevents secrets and Terraform state from being committed |
| `.terraform.lock.hcl` | Locks provider versions                                   |
| `README.md`           | Project documentation                                     |

---

# ☁️ AWS Infrastructure

## VPC

The database environment is deployed inside an Amazon VPC.

The VPC provides network isolation for the Aurora PostgreSQL environment.

The database subnets are distributed across multiple Availability Zones to support Aurora's high-availability architecture.

---

## 🔐 Security Group

The Aurora cluster is protected using an AWS security group.

The security group controls which traffic is allowed to reach PostgreSQL.

PostgreSQL uses:

```text
TCP 5432
```

Example architecture:

```text
Application / DBA Client
          │
          │ TCP 5432
          ▼
   Security Group
          │
          ▼
Aurora PostgreSQL
```

In a production environment, database access should be restricted to approved application servers, bastion hosts, VPN networks, or other trusted sources rather than allowing unrestricted internet access.

---

# 🗄️ Aurora PostgreSQL

The project deploys:

```text
Aurora PostgreSQL 17
```

with:

```text
1 Writer Instance
1 Reader Instance
```

### Writer

The writer instance handles:

* INSERT
* UPDATE
* DELETE
* DDL
* Read operations

Applications performing write operations should use the **cluster/writer endpoint**.

### Reader

The reader instance is intended for read workloads.

Applications can use the **reader endpoint** for read-only workloads.

This architecture helps separate read and write workloads.

---

# 🔄 Aurora Endpoints

Aurora provides different endpoints for different workloads.

### Writer / Cluster Endpoint

Used for:

```text
READ
WRITE
```

Example:

```bash
psql -h <cluster-endpoint> \
     -p 5432 \
     -U dbamaster \
     -d auroradb
```

### Reader Endpoint

Used primarily for:

```text
READ
```

Example:

```bash
psql -h <reader-endpoint> \
     -p 5432 \
     -U dbamaster \
     -d auroradb
```

The reader endpoint distributes connections across Aurora read replicas.

---

# 💾 Backup Configuration

The Aurora cluster is configured with automated backups.

Example configuration:

```hcl
backup_retention_period = 7
```

This provides a seven-day backup retention period.

The project also defines a preferred backup window:

```hcl
preferred_backup_window = "03:00-04:00"
```

Backup configuration is an important component of database recovery planning.

---

# 🔒 Encryption

Storage encryption is enabled for the Aurora database.

Encryption at rest protects database storage and automated backups.

For production workloads containing sensitive information, encryption should be combined with:

* IAM controls
* KMS key management
* TLS connections
* Network isolation
* Least-privilege access
* Secrets management
* Auditing

---

# ⚙️ Parameter Groups

Aurora PostgreSQL uses parameter groups to control database configuration.

Because this project uses PostgreSQL 17, the parameter group family must match:

```text
aurora-postgresql17
```

The engine and parameter group family must remain compatible.

Example:

```hcl
resource "aws_rds_cluster_parameter_group" "aurora" {
  name   = "dba-lab-dev-cluster-params"
  family = "aurora-postgresql17"
}
```

This demonstrates an important DBA configuration-management principle:

> Database engine versions and parameter group families must be compatible.

---

# 🚀 Deployment

## Prerequisites

Install:

* Terraform
* AWS CLI
* Git
* PostgreSQL client (`psql`)
* AWS account

Verify Terraform:

```bash
terraform --version
```

Verify AWS CLI:

```bash
aws --version
```

Verify PostgreSQL client:

```bash
psql --version
```

---

## AWS Authentication

Configure AWS credentials using the AWS CLI:

```bash
aws configure
```

Then verify access:

```bash
aws sts get-caller-identity
```

---

## Initialize Terraform

From the project directory:

```bash
terraform init
```

---

## Format Terraform

```bash
terraform fmt
```

---

## Validate Configuration

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

---

## Review the Deployment

Before creating infrastructure:

```bash
terraform plan
```

Always review the plan before applying changes.

---

## Deploy

```bash
terraform apply
```

Confirm with:

```text
yes
```

Terraform will provision the AWS infrastructure.

---

# 🔎 Verify the Deployment

After deployment:

```bash
terraform output
```

Check Terraform resources:

```bash
terraform state list
```

You should see resources such as:

```text
aws_rds_cluster.aurora
aws_rds_cluster_instance.writer
aws_rds_cluster_instance.reader
aws_db_subnet_group.aurora
aws_security_group.aurora
```

---

# 🐘 PostgreSQL Connectivity

Use the Aurora writer endpoint to connect:

```bash
psql -h <WRITER-ENDPOINT> \
     -p 5432 \
     -U dbamaster \
     -d auroradb
```

After connecting:

```sql
SELECT version();
```

Check the current database and user:

```sql
SELECT current_database(), current_user;
```

Check the server:

```sql
SELECT inet_server_addr(), inet_server_port();
```

---

# 🧪 DBA Validation Tests

After connecting to Aurora, basic DBA validation can include:

### Database Information

```sql
SELECT version();
```

### Current Connections

```sql
SELECT count(*)
FROM pg_stat_activity;
```

### Active Sessions

```sql
SELECT pid,
       usename,
       state,
       query
FROM pg_stat_activity
WHERE state <> 'idle';
```

### Database Size

```sql
SELECT pg_size_pretty(pg_database_size(current_database()));
```

### Database List

```sql
SELECT datname
FROM pg_database;
```

These queries demonstrate basic PostgreSQL operational monitoring.

---

# 🛡️ Security Practices

Sensitive Terraform variables should not be committed to Git.

For example:

```text
terraform.tfvars
```

is excluded using `.gitignore`.

Terraform state files are also excluded:

```text
*.tfstate
*.tfstate.*
```

For production environments, secrets should preferably be managed using services such as:

* AWS Secrets Manager
* AWS Systems Manager Parameter Store
* Terraform Cloud/Enterprise variable management
* CI/CD secret stores

Passwords should never be hard-coded into source-controlled Terraform configuration.

---

# 🧹 Destroy the Lab

When the lab is no longer needed:

```bash
terraform destroy
```

Review the destruction plan carefully and confirm when prompted.

This prevents unnecessary AWS charges.

---

# 📚 DBA Skills Demonstrated

This project demonstrates practical experience with:

### PostgreSQL

* PostgreSQL 17
* Database connectivity
* Writer/reader architecture
* Parameter groups
* Database monitoring
* PostgreSQL administration

### AWS

* Amazon Aurora PostgreSQL
* Amazon RDS
* VPC
* Availability Zones
* Security Groups
* Subnet Groups
* Encryption
* Automated backups

### Infrastructure as Code

* Terraform
* Variables
* Resources
* Outputs
* State management
* Provider configuration
* Terraform plan/apply workflow

### DevOps / GitOps

* Git
* GitHub
* Version-controlled infrastructure
* `.gitignore`
* Infrastructure change management

---

# 📈 Future Improvements

Possible future enhancements include:

* Add AWS Secrets Manager
* Add CloudWatch monitoring
* Configure Performance Insights
* Add CloudWatch alarms
* Configure enhanced monitoring
* Add IAM database authentication
* Add Terraform remote state in S3
* Add DynamoDB state locking where applicable
* Add CI/CD with GitHub Actions
* Add Terraform validation in CI/CD
* Add security scanning with Checkov or tfsec
* Add automated PostgreSQL health checks
* Add additional Aurora read replicas
* Implement disaster recovery testing
* Document RTO/RPO requirements
* Add monitoring with Datadog

---

## Terraform Workflow

This project follows a standard Infrastructure as Code workflow:

1. `terraform init`
2. `terraform fmt`
3. `terraform validate`
4. `terraform plan`
5. `terraform apply`
6. Validate the AWS resources
7. `terraform destroy`

# 👨💻 Author

**Henri Siyapdje**

Database Administrator / PostgreSQL DBA

This project was created as a hands-on demonstration of **PostgreSQL database administration, AWS cloud infrastructure, Terraform Infrastructure as Code, high availability, security, and database operations**.

