terraform {
  backend "s3" {
     bucket         = "techeazy-terraform-state"     # ✅ Replace with your shared bucket
    key            = "env/terraform.tfstate"  # ⬅️ dynamic path based on stage
    region         = "ap-south-1"                     # ⬅️ Use var.region (e.g., ap-south-1)
    encrypt        = true
  }
}