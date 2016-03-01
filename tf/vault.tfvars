project = "vault-20160301"
machine_type = "g1-small"
node_count = 3
vault_release_url = "https://releases.hashicorp.com/vault/0.5.1/vault_0.5.1_linux_amd64.zip"

# get the latest coreos image by gcloud:
# gcloud compute images list | grep coreos-stable | awk '{print $1;}'
image = "coreos-stable-835-13-0-v20160218"
