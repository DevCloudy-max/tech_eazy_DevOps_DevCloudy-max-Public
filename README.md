# 🚀 CI/CD Pipeline + Verifier EC2 Integration

This update enhances the existing Terraform project with:

---

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

