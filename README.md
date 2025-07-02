# 🚀 Terraform AWS EC2 + S3 Log Upload Project

This project automates the provisioning of an EC2 instance using Terraform. It installs a Spring Boot app from GitHub and uploads logs to a secure S3 bucket. All AWS resources are provisioned using best practices like IAM roles and lifecycle rules.

---

## 📦 What This Project Does

- Creates an EC2 instance in a specified region.
- Installs Java and Spring Boot application from a GitHub repository.
- Uploads logs to a randomly named S3 bucket.
- Adds a lifecycle rule to delete logs older than 7 days.
- Shuts down EC2 instance automatically after a set time.
- Uses IAM roles for secure S3 access (Write-Only for EC2).

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
cd tech_eazy_DevOps_DevCloudy-max-Public
```

### 🧪 Prepare Your .tfvars(Example dev_config.tfvars)

##Example :
 instance_type    = "t2.micro"
 stage            = "dev"
 region           = "ap-south-1"
 s3_bucket_prefix = "techeazy-logs-dev-role-"
 delete_S3_bucket = "true"
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

### 📂 Files and Folders

| File/Folder              | Purpose                               |
| ------------------------ | ------------------------------------- |
| `main.tf`                | Infrastructure configuration          |
| `dev_config.tfvars`      | Your environment-specific variables   |
| `scripts/install_app.sh` | EC2 user data script for provisioning |
| `outputs.tf` (optional)  | Outputs like instance public IP       |


### 🛑 Tear Down Infrastructure
```
terraform destroy -var-file="dev_config.tfvars" -auto-approve
```
### NOTE : 💡 Make sure your S3 bucket is empty or use force_destroy = true.
