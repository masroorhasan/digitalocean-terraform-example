# Create a new domain record
resource "digitalocean_domain" "default" {
   name = "haproxy-example.com"
   ip_address = "${digitalocean_droplet.haproxy-www.ipv4_address}"
}

# Add CNAME to point www.*.com to *.com
resource "digitalocean_record" "CNAME-www" {
  domain = "${digitalocean_domain.default.name}"
  type = "CNAME"
  name = "www"
  value = "@"
}