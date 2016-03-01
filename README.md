# Vault on Google Clould

This is a demo project that will install a **[Vault][vault]** on **[Google Clould Platform][gCloud]** with **[Terraform][terraform]**.

**Vault** — a tool from HashiCorp for securely managing secrets and encrypting data in-transit. From storing credentials and API keys to encrypting passwords for user signups, Vault is meant to be a solution for all secret management needs.

**Google Cloud Platform** enables developers to build, test and deploy applications on Google’s highly-scalable and reliable infrastructure.

**Terraform** is a tool for creating, combining, and managing infrastructure resources across multiple providers. Manage resources on cloud providers such as Amazon Web Services, Google Cloud, Microsoft Azure, DNS records on DNSSimple, Dyn, and CloudFlare, email services on Mailgun, and more.


## Setup A Google Cloud Project

The start point for working on Google Clould Platform is **Project** (very engineering oriented).

The first thing we need to do is to create a new project at [Google Project Console][gProject], for example:

Project Name | Project ID
------------ | ----------
ProjectVault | vault-20160301


**Note:** you'll be asked to setup billing infomation for this new project. If you are a new user, Google gives you a $300.00 GCP credit for 60 days. 

## Enable Google Cloud APIs for ProjectVault

To use and control Google Cloud with command line tools, we need to enable Google Cloud APIs.

Go to [Google Cloud API Manager][gAPI]
and enable Google Cloud APIs for ProjectVault:

* Compute Engine API
* Cloud Storage Service
* Cloud Deployment Manager API
* Cloud DNS API
* Cloud Monitoring API
* Cloud Storage JSON API
* Compute Engine Instance Group Manager API
* Compute Engine Instance Groups API
* Prediction API

**Note:** Not a state of the art UI/UX, just make sure the project is *ProjectVault* and click through the APIs to enable them.

## Get Authentication JSON File

Authenticating with Google Cloud services requires a JSON file which is called the __account file__ in Terraform.

This file is downloaded directly from the [Google Developers Console][gProject]. To make the process more straightforward, it is documented here:

1. Log into the [Google Developers Console][gProject] and select a project.

1. Click the menu button in the top left corner, and navigate to "Permissions", then "Service accounts", and finally "Create service account".

1. Provide **vault-20160301** as the name and ID in the corresponding fields, select "Furnish a new private key", and select "JSON" as the key type.

1. Clicking "Create" will download your credentials.

1. Rename the downloaded json file to **tf/account.json**

## Install and Setup Tools
### Install Google Cloud SDK
Google Cloud SDK comes with a very useful CLI utility 
**gcloud**. We may need it to login and check on the vault cluster.

Following [Google Cloud SDK Instructions][gSDK] to install Google Cloud SDK

### Initialize gcloud configuration
```
gcloud init --console-only
Welcome! This command will take you through the configuration of gcloud.
...
```

### Install Terraform

Following the instructions on [Installing Terraform][installing-terraform] to install Terraform

**Tip:** for MacOS users, just `brew install terraform`

### Install Vault Client On Local Machine

Download pre-compiled binary at [Download Vault Page][vault-download]

## Provsion the Vault on Google Cloud
```shell
git clone https://github.com/xuwang/vault-on-gcloud
cd vault-on-gcloud/tf
```
1. Check the **tf/variables.tf** and **tf/vault.tfvars** file and make sure you agrees with those value.
1. Check
```shell
terraform plan -var-file=vault.tfvars
```
1. Apply
```shell
terraform apply -var-file=vault.tfvars
```

## Cleanup: Destroy the Vault Cluster

If you want to stop paying google for **Vault**, remember to clean it up:

```shell
terraform destroy -var-file=vault.tfvars
```
**! Warning:** Make sure you saved all your secrets somewhere else before you destroy the Vault!


## Technical Notes
* Security
	* Google Cloud Platform
	* CoreOS
	* Vault
* High Availability
	* Google Cloud Platform
	* Etcd cluster as storage backend
	* Vault cluster behind load balancer
* Ssh backend not working on CoreOS

[virtualbox]: https://www.virtualbox.org/
[vagrant]: https://www.vagrantup.com/downloads.html
[using-coreos]: http://coreos.com/docs/using-coreos/
[installing-terraform]: https://www.terraform.io/intro/getting-started/install.html
[gProject]: https://console.cloud.google.com/project
[gSDK]: https://cloud.google.com/sdk/
[gAPI]: https://console.cloud.google.com/apis
[vault]: https://www.hashicorp.com/blog/vault.html
[gCloud]: https://cloud.google.com/
[terraform]: https://www.terraform.io/
[CoreOS]: https://coreos.com/
[vault-download]: https://www.vaultproject.io/downloads.html
