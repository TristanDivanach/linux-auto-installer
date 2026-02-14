#!/bin/bash

# ==========================================
#  Linux auto installer (Debian/Ubuntu)
#  Author : Tristan Divanach
# ==========================================

mkdir -p logs
LOG_FILE="logs/install.log"

if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root (sudo command)." | tee -a $LOG_FILE
    exit 1
fi

echo "==========================================" | tee -a $LOG_FILE
echo " Linux Auto Installer - Start of installation" | tee -a $LOG_FILE
echo "==========================================" | tee -a $LOG_FILE

# System update
echo "System update..." | tee -a $LOG_FILE
apt update && apt upgrade -y >> $LOG_FILE 2>&1

# Installation of essentials tools
echo "Installation of essentials tools..." | tee -a $LOG_FILE
apt install -y git curl htop tree vim >> $LOG_FILE 2>&1

# Firewall configuration
echo "Firewall configuration..." | tee -a $LOG_FILE
apt install -y ufw >> $LOG_FILE 2>&1
ufw allow OpenSSH >> $LOG_FILE 2>&1
ufw --force enable >> $LOG_FILE 2>&1

# Fail2Ban installation
echo "Fail2Ban installation..." | tee -a $LOG_FILE
apt install -y fail2ban >> $LOG_FILE 2>&1
systemctl enable fail2ban >> $LOG_FILE 2>&1
systemctl start fail2ban >> $LOG_FILE 2>&1

# Docker installation
echo "Docker installation..." | tee -a $LOG_FILE
./docker-install.sh >> $LOG_FILE 2>&1

# Creating it-tools container
echo "Creating it-tools container..." | tee -a $LOG_FILE
cat << EOF > docker-compose.yml
services:
  it-tools:
    image: 'ghcr.io/corentinth/it-tools:latest'
    ports:
      - '7474:80'
    restart: unless-stopped
    container_name: it-tools
    privileged: false
EOF

if command -v docker &> /dev/null; then
    docker compose up -d >> $LOG_FILE 2>&1
fi

echo "Installation completed successfully" | tee -a $LOG_FILE
