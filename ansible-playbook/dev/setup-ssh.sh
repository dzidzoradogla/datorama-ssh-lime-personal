#!/bin/bash

export VAULT_ADDR="https://vault-dev.datorama.io"
export VAULT_TOKEN=$(</root/.vault.token)

cd /etc/ssh

# sign host keys using vault
for PK in *key.pub; do
    vault write -field=signed_key ssh-host/sign/datorama.net cert_type=host public_key=@$PK > $(basename $PK .pub)-cert.pub
done

# store SSH CA certificate locally
vault read -field=public_key ssh-host/config/ca > /etc/ssh/trusted-user-ca-keys.pem

# add SSH CA certificate to system known hosts file
CA=$(cat /etc/ssh/trusted-user-ca-keys.pem)
SYSTEM_KNOWN_HOSTS_FILE="/etc/ssh/ssh_known_hosts"
if ! grep "$CA" $SYSTEM_KNOWN_HOSTS_FILE > /dev/null; then
    echo "@cert-authority * $CA" >> $SYSTEM_KNOWN_HOSTS_FILE
fi
