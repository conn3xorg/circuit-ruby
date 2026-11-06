variable "port" {
  type    = number
  default = 2334
}

# CI sets this to an older rainbow first, then upgrades the gem by applying
# again with the default.
variable "rainbow_version" {
  type    = string
  default = "3.1.1"
}

module "ruby" {
  source = "../.."

  hosts                = { box = "127.0.0.1" }
  ssh_port             = var.port
  ssh_private_key_file = "./id_ed25519"
  ssh_known_hosts_file = "./known_hosts"

  gems = { rainbow = var.rainbow_version }
}

output "ruby" {
  value = module.ruby.ruby
}
