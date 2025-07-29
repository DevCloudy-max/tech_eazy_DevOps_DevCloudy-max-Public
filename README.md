# 🚀 Techezy DevOps Project – Terraform + S3 Log Upload Project + CI/CD + CloudWatch Alarm
## This project automates the deployment of a Spring Boot application using Terraform, sets up log uploads to S3, configures CloudWatch log-based alarms, and integrates with a GitHub Actions CI/CD pipeline.

### 📦 What This Project Does
- Provisions an EC2 instance to run a Spring Boot app.

- Installs the app from a GitHub repo, sets up logs to S3.

- Applies a lifecycle rule to clean logs after 7 days.

- Shuts down EC2 instance automatically (dev).

- Adds a CloudWatch Alarm for error detection from app logs.

- Deploys via GitHub Actions using stages (dev, prod).

- Includes an optional verifier EC2 for health or test scripts.

| Tool      | Requirement        |
| --------- | ------------------ |
| Terraform | v1.6 or later      |
| AWS       | IAM user or role   |
| GitHub    | App repo + secrets |
| AWS CLI   | Installed on EC2   |


## 🛠️ Setup Instructions

### 1. Clone the Repository
   ```
   git clone https://github.com/DevCloudy-max/tech_eazy_DevOps_DevCloudy-max-Public.git
   cd tech_eazy_DevOps_DevCloudy-max-Public
   ```

### 2. Configure Your Environment
   ```
   instance_type    = "t2.micro"
   stage            = "dev"
   region           = "ap-south-1"
   s3_bucket_prefix = "techeazy-logs-dev-role-"
   delete_S3_bucket = "true"
   ```

🔐 Don't include sensitive keys here.
### NOTE : It is not compulsory to create this file i already created this in my project but if you need any change in configuration like, change type of the instacne, stop instance type etc then you can do.


### 3. ⚙️ Initialize Terraform

```
terraform init
```

### 4. 🔍 Preview the changes

```
terraform plan -var-file="dev_config.tfvars"
```

### 5. 🚀 Apply the configuration

```
terraform apply -var-file="dev_config.tfvars" -auto-approve
```
## ✅ GitHub Actions CI/CD Pipeline

A full GitHub Actions pipeline is added (`.github/workflows/deploy.yaml`) that:

---

# AWS credentials must be stored as GitHub Secrets:
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```
## ✅ Benefits

- 🛠️ Zero manual steps after pushing code.
- ✅ Health-check ready & testable infra.
- 🔐 Secure and automated cloud provisioning.


- Automatically runs on `main`, `feature/*`, and tag-based deployments.
- Detects stage (dev/prod) from the branch/tag.
- Runs `terraform init`, `plan`, and `apply`.
- Waits for EC2 to be reachable on port 80.



## 🖥️ Verifier EC2 Instance

- A second EC2 instance is launched.
- Can be used for health checks, load testing, or validation scripts.
- Can optionally access logs with **read-only** IAM role.
- Shares region and VPC with the main EC2 instance.

---

## 🧠 CloudWatch Alarm Logic (🚨 Error Alerting from Logs)
After Terraform applies:

A Log Group techezy-app-logs is created.

App logs (pushed manually or via EC2) are scanned for "ERROR" using a CloudWatch metric filter.

If 1 or more errors appear in a 5-minute window, a custom metric AppErrorCount triggers.

A CloudWatch alarm (techezy-error-alarm) monitors this metric:

If AppErrorCount ≥ 1 for 1 period (5 mins), the alarm triggers.

Sends a notification to an SNS topic: app-alerts-topic.

You receive an email alert like:

🚨 "ERROR" detected at 29 July 2025, 17:24 UTC

### 🛑 Tear Down Infrastructure
```
terraform destroy -var-file="dev_config.tfvars" -auto-approve
```
### NOTE : 💡 Make sure your S3 bucket is empty or use force_destroy = true.

