# 🚀 Terraform AWS EC2 + S3 Log Upload + CI/CD Pipeline Project

This project automates the provisioning of EC2 instances using Terraform, deploys a Spring Boot app from GitHub, uploads logs to a secure S3 bucket, and performs health checks using a verifier instance. It also includes a GitHub Actions CI/CD pipeline for fully automated deployment.

---

## 📦 What This Project Does

- Provisions a main EC2 instance running a Spring Boot application.
- Provisions an additional EC2 verifier instance to simulate load/monitoring or future test scripts.
- Installs Java and pulls the Spring Boot app from a public GitHub repo.
- Uploads application logs to a secure, uniquely named S3 bucket.
- Adds S3 lifecycle rules to delete logs older than 7 days.
- Automatically shuts down EC2 after a time (via Terraform or CI/CD).
- Implements CI/CD using GitHub Actions.
- Uses IAM roles with least privilege for EC2/S3 access:
   - Write-only access to the log bucket from EC2.
   - Read-only access (optional) from verifier.

---

## 🔧 Prerequisites

| Tool             | Version/Requirement |
|------------------|---------------------|
| Terraform        | v1.6 or later       |
| AWS Account      | Access + Secret Key |
| GitHub Repo      | Spring Boot App     |
| AWS CLI (Optional for debugging) | Pre-installed in Amazon Linux 2 |

---

## 🛠️ Setup Instructions

### 1. 📁 Clone the repository

```bash
git clone https://github.com/DevCloudy-max/tech_eazy_DevOps_DevCloudy-max-Public.git
```
```
cd tech_eazy_DevOps_DevCloudy-max-Public
```

### 2. 🧪 Prepare Your .tfvars(Example dev_config.tfvars)

## Example :
 instance_type    = "t2.micro"
 stage            = "dev"
 region           = "ap-south-1"
 s3_bucket_prefix = "techeazy-logs-dev-role-"
 delete_S3_bucket = "true"
🔐 Don't include sensitive keys here.
### NOTE : It is not compulsory to create this file i already created in my project but if you need any change in configuration like, change type of the instacne, stop instance type etc then you can do.

### 3. Configure AWS Credentials
Before running any Terraform commands, make sure your AWS credentials (Access Key and Secret Key) are properly configured. You can do this by running the following command:

```
aws configure
AWS Access Key ID [None]: AKIA**************
AWS Secret Access Key [None]: ***************
Default region name [None]: ap-south-1
Default output format [None]: json
```

### Note : This two things 
Default region name and 
Default output format is not mandatory you leave it blank and simply press enter

### 4. ⚙️ Initialize Terraform

```
terraform init
```

### 5. 🔍 Preview the changes

```
terraform plan -var-file="dev_config.tfvars"
```

### 6. 🚀 Apply the configuration

```
terraform apply -var-file="dev_config.tfvars" 
```

# NOTE: PLEASE WAIT AFTER "TERRAFORM APPLY" BECAUSE IT MAY TAKE 5 MINUTES FOR CONFIGURATION AND DEPLOYMENT. 

### ⚙️ GitHub Actions CI/CD Pipeline
## CI/CD pipeline is included via github-actions.yaml. It performs:
1. Checks out the code. 
2. Determines the stage (dev or prod) based on branch or tag.
3. Runs terraform init, plan, and apply.
4. Waits until the deployed app on EC2 is available on port 80.
5. Verifies HTTP 200 status using curl.

# ❗ Make sure to store your AWS credentials in GitHub Secrets as:
```
AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY
```
### 🛑 Tear Down Infrastructure
```
terraform destroy -var-file="dev_config.tfvars" -auto-approve
```
### NOTE : 💡 Make sure your S3 bucket is empty or use force_destroy = true.
