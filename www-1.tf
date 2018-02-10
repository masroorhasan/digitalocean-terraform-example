# create a web server, resource name: www-1
resource "digitalocean_droplet" "www-1" {
  # droplet attributes
  image = "ubuntu-14-04-x64"
  name = "www-1"
  region = "nyc1"
  size = "512mb"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]

  # define terraform connection to server over SSH
  connection {
    user = "root"
    type = "ssh"
    private_key = "${file(var.pvt_key)}"
    timeout = "2m"
  }

  # provisioner to install Nginx
  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install nginx
      "sudo apt-get update",
      "sudo apt-get -y install nginx"
    ]
  }
}

