# Change to your own project id!
google_project_id = "vault-20160301"

machine_type = "n1-standard-1"
node_count = 3

# Check to use the latest vault release:
vault_release_url = "https://releases.hashicorp.com/vault/0.5.1/vault_0.5.1_linux_amd64.zip"

# Get the latest coreos image by following cmd:
# gcloud compute images list | grep coreos-stable | awk '{print $1;}'
image = "coreos-stable-835-13-0-v20160218"
