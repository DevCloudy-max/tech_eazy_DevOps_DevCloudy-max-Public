variable "region" {
  description = "This is instance region"
  type        = string
  default     = "ap-south-1"

}

variable "Image_Id" {
  description = "AMI id"
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
  default     = "https://github.com/DevCloudy-max/SimpleHttpServer_Java.git"
}