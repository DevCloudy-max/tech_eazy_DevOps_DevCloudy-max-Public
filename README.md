# ☁️ Automated EC2 Deployment with Terraform

This project automates the provisioning of an EC2 instance on AWS using Terraform. The EC2 instance pulls a Spring Boot project from GitHub, builds it using Maven, runs the application and auto-shuts down after a specified duration.

---

## 🧰 Features

- EC2 provisioning using Terraform
- Cloud-init shell script for:
  - Java + Maven installation
  - Secure GitHub repository clone using `GITHUB_TOKEN`
  - Spring Boot project build (`mvn clean package`)
  - Application auto-start (`java -jar target/*.jar`)
  - Automatic instance shutdown after `N` minutes
- Separate `dev` and `prod` environment support via `dev_config.tfvars` / `prod_config.tfvars`

---

## 📁 Project Structure

```bash
.
├── main.tf
├── variables.tf
├── outputs.tf
├── dev_config.tfvars
├── prod_config.tfvars
├── Script
  ├── install_app.sh
└── README.md
```


## Requirements
Terraform CLI (v1.5+)

AWS CLI configured with appropriate credentials


## How to Deploy
1. Initialize Terraform
```
terraform init
```

2. Validate and Plan
```
terraform plan -var-file="dev_config.tfvars"

```

3.  Apply the Configuration
```
terraform apply -var-file="dev_config.tfvars"
```
