#cloud-config

coreos:
  etcd2:
    # Discovery is populated by Terraform
    discovery: ${etcd_discovery_url}
    # $public_ipv4 and $private_ipv4 are populated by the cloud provider
    # for vault, we only allows internal etcd clients
    advertise-client-urls: http://$private_ipv4:2379
    initial-advertise-peer-urls: http://$private_ipv4:2380
    listen-client-urls: http://0.0.0.0:2379
    listen-peer-urls: http://$private_ipv4:2380
  units:
    - name: etcd2.service
      command: start
    - name: install-vault
      command: start
      enable: true
      content: |
        [Unit]
        Description=Install Vault
        [Service]
        Type=oneshot
        RemainAfterExit=true
        ExecStart=/bin/bash -c "[ -x /opt/bin/vault ] || \
          (mkdir -p /opt/bin; cd /tmp;  \
          curl -s -L -O ${vault_release_url} \
          && unzip -o $(basename ${vault_release_url}) -d /opt/bin/ \
          && chmod 755 /opt/bin/vault \
          && rm $(basename ${vault_release_url}))"
    - name: install-vault
      command: start
      enable: true
      content: |
        [Unit]
        Description=vault
        Wants=install-vault.service
        After=install-vault.service
        [Service]
        ExecStart=/opt/bin/vault server -config /var/lib/apps/vault/vault.hcl"
        RestartSec=5
        Restart=always

write_files:
  - path: /var/lib/apps/vault/vault.hcl
    permissions: 0644
    owner: root
    content: |
      ${vault_conf}
  - path: /var/lib/apps/certs/vault.crt
    permissions: 0644
    owner: root
    content: |
      ${vault_crt}
  - path: /var/lib/apps/certs/vault.key
    permissions: 0644
    owner: root
    content: |
      ${vault_key}




