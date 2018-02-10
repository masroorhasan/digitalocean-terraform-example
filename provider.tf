variable "do_token" {}          # DO personal access token
variable "pub_key" {}           # public key location (client)
variable "pvt_key" {}           # private key location (client)
variable "ssh_fingerprint" {}   # SSH key fingerprint

# define DO provider with token
provider "digitalocean" {
  token = "${var.do_token}"
}