#!/usr/bin/env bash
mkdir -p /home/${user}/.ssh
echo -n "${host_private_key}" > /home/${user}/.ssh/id_rsa
chmod 600 /home/${user}/.ssh/id_rsa
chown -R ${user} /home/${user}/.ssh
