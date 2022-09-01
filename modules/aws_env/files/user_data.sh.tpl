#!/usr/bin/env bash
set -e

# Install docker
yum update -y
amazon-linux-extras install docker
systemctl start docker
systemctl enable docker

# Post install
usermod -aG docker ec2-user

# Start application
docker run -d --restart always --name f5demo -p 80:80 -e F5DEMO_NODENAME='${node_name}' f5devcentral/f5-demo-httpd:nginx
