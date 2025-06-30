#!/bin/bash

# Enable debugging and exit on error
set -e

# 1. Log Setup
LOG_FILE="/var/log/user_data.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "🚀 Provisioning Start"

# 2. Update Packages
echo "Updating system packages..."
sudo yum update -y

# 3. Install Java 21 and Git
echo "Installing Java 21 and Git..."
sudo dnf install -y java-21-amazon-corretto-devel git

# 4. Clone GitHub Repository
REPO_URL="https://github.com/techeazy-consulting/techeazy-devops.git"
APP_DIR="/home/ec2-user/app"

echo "Cloning GitHub repository from $REPO_URL..."
sudo git clone "$REPO_URL" "$APP_DIR"

# 5. Build and Run Spring Boot App
cd "$APP_DIR" || exit 1

# Set HOME environment variable
export HOME="/home/ec2-user"

echo "Making mvnw executable..."
chmod +x ./mvnw

echo "🔧 Building Spring Boot application..."
./mvnw clean install

echo "🚀 Starting Spring Boot application..."
sudo java -jar target/techeazy-devops-0.0.1-SNAPSHOT.jar &
echo "✅ Application started."

# 6. Schedule Auto Shutdown
echo "Scheduling instance shutdown in 30 minutes..."
sudo shutdown -h +30

echo "✅ Provisioning Complete"
