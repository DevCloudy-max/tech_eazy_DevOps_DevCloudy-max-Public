variable "region" {
  description = "This is instance region"
  type        = string
  default     = "ap-south-1"

}

variable "AMI_img_Id" {
  description = "AMI id"
  type        = string
  default     = "ami-0d03cb826412c6b0f"

}

variable "instance_type" {
  description = "Type of Instance"
  type        = string
  default     = "t2.micro"

}


variable "stage" {
  description = "Deployment stage like dev or prod"
  type        = string
  default     = "dev"
}

variable "github_repo_url" {
  description = "GitHub repo to clone"
  type        = string
  default     = "https://github.com/techeazy-consulting/techeazy-devops.git"
}

variable "stop_after" {
  description = "After the given time instance is stop automatically"
  type        = number
  default     = 20
}

variable "s3_bucket_prefix" {
  type        = string
  description = "Name of the S3 bucket for storing logs"

}

variable "delete_S3_bucket" {
  description = "To delete force fully"
  type        = bool
  default     = true

}


