#!/bin/bash

# Enable debugging and exit on error
set -e


# 1. Log Setup

LOG_FILE="/var/log/user_data.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo " Provisioning Start "


# 2. Update Packages

echo "Updating system packages..."
sudo yum update -y


# 3. Install Java 21 JDK (with javac)

echo "Installing Java 21..."
sudo yum install -y java-21-amazon-corretto-devel git


# 4. Clone GitHub Repository

REPO_URL="${GITHUB_REPO_URL:-https://github.com/DevCloudy-max/SimpleHttpServer_Java.git}"
APP_DIR="/opt/app"

echo "Cloning GitHub repository from $REPO_URL..."
sudo git clone "$REPO_URL" "$APP_DIR"


# 5. Navigate and Run Java Application

cd "$APP_DIR" || exit 1

# Check if the Java file exists
if [ -f SimpleHttpServer.java ]; then
    echo "Compiling Java application..."
    javac SimpleHttpServer.java

    echo "Running Java application on port 80..."
    sudo java SimpleHttpServer &
else
    echo "❌ SimpleHttpServer.java not found. Please check the repo."
    exit 1
fi


# 6. Schedule Auto Shutdown

echo "Scheduling instance shutdown in 30 minutes..."
sudo shutdown -h +30

echo "Provisioning Complete"
