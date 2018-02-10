# create a web (proxy) server, resource name: haproxy-www
resource "digitalocean_droplet" "haproxy-www" {
    # droplet attributes
    image = "ubuntu-16-04-x64"
    name = "haproxy-www"
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

  # provisioner to install and configure HAProxy
  provisioner "remote-exec" {
    inline = [
        "export PATH=$PATH:/usr/bin",
        # install haproxy 1.5
        "sudo add-apt-repository -y ppa:vbernat/haproxy-1.5",
        "sudo apt-get update",
        "sudo apt-get -y install haproxy",

        # download haproxy sample config
        # TODO: haproxy.cfg file on Terraform execution pipleline
        "sudo wget https://gist.githubusercontent.com/thisismitch/91815a582c27bd8aa44d/raw/8fc59b7cb88a2be9b802cd76288ca1c2ea957dd9/haproxy.cfg -O /etc/haproxy/haproxy.cfg",

        # replace ip address variables in haproxy conf to use droplet ip addresses
        "sudo sed -i 's/HAPROXY_PUBLIC_IP/${digitalocean_droplet.haproxy-www.ipv4_address}/g' /etc/haproxy/haproxy.cfg",
        "sudo sed -i 's/WWW_1_PRIVATE_IP/${digitalocean_droplet.www-1.ipv4_address_private}/g' /etc/haproxy/haproxy.cfg",
        "sudo sed -i 's/WWW_2_PRIVATE_IP/${digitalocean_droplet.www-2.ipv4_address_private}/g' /etc/haproxy/haproxy.cfg",

        # restart haproxy to load changes
        "sudo service haproxy restart"
    ]
  }
}