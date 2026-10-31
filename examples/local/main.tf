variable "port" {
  type    = number
  default = 2334
}

module "ruby" {
  source = "../.."

  hosts                = { box = "127.0.0.1" }
  ssh_port             = var.port
  ssh_private_key_file = "./id_ed25519"
  ssh_known_hosts_file = "./known_hosts"

  gems = { rainbow = "3.1.1" }
}

output "ruby" {
  value = module.ruby.ruby
}
