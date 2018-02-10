# Terraform with DigitalOcean

Simple project to document my learnings in using Terraform to build infra on DigitalOcean. This example creates two Nginx servers that are load balanced by an HAProxy server.

## Setup
Download/Install [Terraform](https://www.terraform.io/downloads.html), add to your path and create a DigitalOcean account.

### Personal Access Token
[Create](https://www.digitalocean.com/community/tutorials/how-to-use-the-digitalocean-api-v2#HowToGenerateaPersonalAccessToken) a DigitalOcean account and generate a Personal Access Token. Export the token:
```
export DO_TOKEN={your personal access token}
```

### Add SSH key to DO account
[Create](https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets) a SSH key pair locally and then add it to the DO account. Get the fingerprint of the SSH public key and export the fingerprint as:
```
export SSH_FINGERPRINT=xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
```

## Provider Configuration
DigitalOcean provider configuration as well as the Terraform variables are defined in `provider.tf`.

## Define Droplets

### Nginx servers
Definition of the Nginx servers are `www-1.tf` and `www-2.tf` respectively. 

Firstly, each configuration defines the droplet resource name and attributes as 
```
resource "digitalocean_droplet" "www-*" {
    # Droplet attributes (i.e. region, machine size, etc)
} 
```

This is followed up by the `connection` setup that describe how (via SSH in this case) Terraform should connect to server.

Lastly, as part of bootstrap process we set up the `provisioner` for remote execution (script) on the server. The script is responsible for installing nginx binaries on the droplets.

### HAProxy server
The droplet is defined similarly with droplet resource name as `haproxy-www` and similar compute attributes as the Nginx servers.

The HAProxy however needs a different setup on the droplet to install the HAProxy and configure address variables to point to the two Nginx servers. This is done in the `remote-exec` provisioner. The provisioning execution on the server is defined as follows:
* Install HAProxy 1.5
* Download the sample HAProxy configuration file
* Replace IP address variables in HAProxy configuration file to use Droplet IP addresses
* Restart HAProxy to load the changes

### DNS Domains and records
The `haproxy-example.com.tf` configuration shows how to point an existing domain such as `haproxy-example.com` to the newly created HAProxy server.

## Deploy with Terraform
At this point Terraform can be run to create the HAProxy + Nginx servers. 

### Initialize
Initialize Terraform project to download plugins for DigitalOcean provider.
```
terraform init
```

### View execution plan
View the execution plan - what Terraform will attempt to build the infrastructure described. Specify values for the defined variables.
```
terraform plan \
  -var "do_token=${DO_TOKEN}" \
  -var "pub_key=$HOME/.ssh/id_rsa.pub" \
  -var "pvt_key=$HOME/.ssh/id_rsa" \
  -var "ssh_fingerprint=$SSH_FINGERPRINT"
```

### Apply the changes
Apply the changes required to reach the desired state of the configuration. Once again, the values for defined variables should be specified with the command.
```
terraform apply \
  -var "do_token=${DO_TOKEN}" \
  -var "pub_key=$HOME/.ssh/id_rsa.pub" \
  -var "pvt_key=$HOME/.ssh/id_rsa" \
  -var "ssh_fingerprint=$SSH_FINGERPRINT"
```

The the command finishes successfully, the resources built can be viewed on the DigitalOcean control plane (UI). There should be three droplets as per defined previously. The IP addresses are public, thus visiting the IP address will show the Nginx welcome screen.

### Show state
To view current state of the environment, run:
```
terraform show terraform.tfstate
```

### Refresh state
The local state can be refreshed by updating to the latest state (from any outside modifications):
```
terraform refresh \
  -var "do_token=${DO_TOKEN}" \
  -var "pub_key=$HOME/.ssh/id_rsa.pub" \
  -var "pvt_key=$HOME/.ssh/id_rsa" \
  -var "ssh_fingerprint=$SSH_FINGERPRINT"
```

### Destroy
Create an execution plan to destroy the infrastructure. Terraform will output a plan with resources marked to be deleted.
```
terraform plan -destroy -out=terraform.tfplan \
  -var "do_token=${DO_TOKEN}" \
  -var "pub_key=$HOME/.ssh/id_rsa.pub" \
  -var "pvt_key=$HOME/.ssh/id_rsa" \
  -var "ssh_fingerprint=$SSH_FINGERPRINT"
```

Apply the destroy from the indicated destroy plan:
```
terraform apply terraform.tfplan
```

## Resources
* [Terraform DigitalOcean provider](https://www.terraform.io/docs/providers/do/index.html)
* [DigitalOcean droplet specification](https://www.terraform.io/docs/providers/do/r/droplet.html)
* [How To Use the DigitalOcean API v2](https://www.digitalocean.com/community/tutorials/how-to-use-the-digitalocean-api-v2#HowToGenerateaPersonalAccessToken)
* [DigitalOcean API 2 docs](https://developers.digitalocean.com/documentation/v2/)
* [How To Use Terraform with DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean)


