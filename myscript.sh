#!/bin/bash

set -e  # Exit on any error
set -o pipefail

echo "[INFO] Updating packages..."
sudo apt update -y
sudo apt install -y unzip curl

# Install AWS CLI v2
echo "[INFO] Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip
echo "[INFO] AWS CLI version: $(aws --version)"

# Install kubectl for EKS
echo "[INFO] Installing kubectl..."
curl -LO "https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.7/2024-12-12/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
echo "[INFO] kubectl version: $(kubectl version --client --short)"

echo "[INFO] Provisioning complete!"

