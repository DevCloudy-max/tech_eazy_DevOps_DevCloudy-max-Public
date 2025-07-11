#!/bin/bash

# Enable debugging and exit on error
set -e

REPO_URL="${REPO_URL}"
STOP_INSTANCE="${STOP_INSTANCE}"
S3_BUCKET_NAME="${S3_BUCKET_NAME}"
AWS_REGION_FOR_SCRIPT="${AWS_REGION_FOR_SCRIPT}"  # Needed for S3 uploads

# 1. Log Setup
LOG_FILE="/var/log/user_data.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Provisioning Start"

# 2. Update Packages
echo "Updating system packages..."
sudo yum update -y

# 3. Install Java 21 and Git
echo "Installing Java 21 and Git..."
sudo yum install -y java-21-amazon-corretto-devel git

# 4. Clone GitHub Repository
APP_DIR="/home/ec2-user/app"
echo "Cloning GitHub repository from $REPO_URL..."
sudo git clone "$REPO_URL" "$APP_DIR"

# 5. Build and Run Spring Boot App
cd "$APP_DIR" || exit 1

# Set HOME environment variable
export HOME="/home/ec2-user"

echo "Making mvnw executable..."
chmod +x ./mvnw

echo "Building Spring Boot application..."
./mvnw clean install

echo "Starting Spring Boot application..."
nohup $JAVA_HOME/bin/java -jar target/*.jar > app.log 2>&1 &
echo "Application started."

# 6. Upload logs to S3
echo "Uploading logs to S3..."


sleep 40  # Let logs generate

# Install AWS CLI v2 if not already available
if ! command -v aws &> /dev/null; then
  echo "Installing AWS CLI v2..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
fi

sync
aws s3 cp /var/log/user_data.log "s3://${S3_BUCKET_NAME}/logs/cloud-init-logs-$(hostname)-$(date +%Y%m%d%H%M%S).log" \
  --region "${AWS_REGION_FOR_SCRIPT}" || echo "User data log upload failed"

sync
aws s3 cp app.log "s3://${S3_BUCKET_NAME}/logs/app-logs-$(hostname)-$(date +%Y%m%d%H%M%S).log" \
  --region "${AWS_REGION_FOR_SCRIPT}" || echo "App log upload failed"

# 7. Schedule Auto Shutdown
echo "Scheduling instance shutdown in '$STOP_INSTANCE' minutes..."
sudo shutdown -h +"$STOP_INSTANCE"

echo "Provisioning Complete"
