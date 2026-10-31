# Facts give each host's distribution, which picks the package names.
data "conn3x_host" "facts" {
  for_each = var.hosts

  ssh {
    host             = try(each.value.address, each.value)
    host_key         = try(each.value.host_key, null)
    user             = try(each.value.user, var.ssh_user)
    port             = try(each.value.port, var.ssh_port)
    private_key_file = try(each.value.private_key_file, var.ssh_private_key_file)
    jump_hosts       = try(each.value.jump_hosts, null)
    known_hosts_file = var.ssh_known_hosts_file
  }
}

circuit "ruby" {
  hosts = var.hosts

  ssh {
    user             = var.ssh_user
    port             = var.ssh_port
    private_key_file = var.ssh_private_key_file
    known_hosts_file = var.ssh_known_hosts_file
    become           = var.ssh_become
  }

  step "package" {
    package {
      name = "ruby"
    }
  }

  step "rubygems" {
    package {
      name = data.conn3x_host.facts[each.key].os_family == "debian" ? "ruby-rubygems" : "rubygems"
    }
  }

  # A gem with C in it needs a compiler and Ruby's headers to install.
  step "build_tool" {
    for_each = length(var.gems) > 0 ? toset(["gcc", "make"]) : toset([])
    package {
      name = item.value
    }
  }

  step "headers" {
    for_each = length(var.gems) > 0 ? toset(["headers"]) : toset([])
    package {
      name = data.conn3x_host.facts[each.key].os_family == "debian" ? "ruby-dev" : "ruby-devel"
    }
  }

  # Named by path because sudo's secure_path leaves out /usr/local/bin on
  # the Red Hat family, and to get the distribution's gem whatever else is
  # installed.
  step "gem" {
    for_each = var.gems
    command {
      command = "/usr/bin/gem install --no-document '${item.key}' -v '${item.value}'"
      unless  = "/usr/bin/gem list --installed --exact '${item.key}' --version '${item.value}' >/dev/null"
    }
  }
}
