variable "hosts" {
  type        = any
  description = "Hosts to configure: a map of names to addresses, or to host objects with an address and optional host_key, user, port, private_key_file or jump_hosts."
}

variable "ssh_user" {
  type        = string
  default     = "root"
  description = "User to log in as."
}

variable "ssh_port" {
  type        = number
  default     = 22
  description = "SSH port."
}

variable "ssh_private_key_file" {
  type        = string
  default     = null
  description = "Path to a private key. When null, Conn3x uses the SSH agent."
}

variable "ssh_known_hosts_file" {
  type        = string
  default     = null
  description = "known_hosts file to check host keys against. When null, ~/.ssh/known_hosts."
}

variable "ssh_become" {
  type        = bool
  default     = false
  description = "Run commands as root through sudo."
}

variable "gems" {
  type        = map(string)
  default     = {}
  description = "Gems to install from RubyGems, by name, each at an exact version, such as { rainbow = \"3.1.1\" }. Installs a compiler, make and Ruby's headers too."

  validation {
    condition     = alltrue([for name in keys(var.gems) : can(regex("^[A-Za-z0-9][A-Za-z0-9._-]*$", name))])
    error_message = "Each key of gems must be a gem name, such as \"rainbow\"."
  }

  validation {
    condition     = alltrue([for v in values(var.gems) : can(regex("^[0-9]+(\\.[0-9A-Za-z]+)*$", v))])
    error_message = "Each version in gems must be exact, such as \"3.1.1\", not a range."
  }
}
