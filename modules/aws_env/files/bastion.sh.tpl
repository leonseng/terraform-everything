#!/usr/bin/env bash
set -e

mkdir -p /home/ec2-user/.ssh
echo -n "${host_private_key}" > /home/ec2-user/.ssh/id_rsa
chmod 600 /home/ec2-user/.ssh/id_rsa
chown -R ec2-user /home/ec2-user/.ssh
