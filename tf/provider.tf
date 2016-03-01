# Configure the Google Cloud provider
provider "google" {
  credentials = "${file("account.json")}"
  project     = "vault-20160301"
  region      = "us-central1"
}