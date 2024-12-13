build {
  sources = [
    "source.amazon-ebs.arm64",
    "source.amazon-ebs.x86_64",
  ]

  # We are adding this to avoid the failure to install aptitude during build time
  # Issue #12 has been created for this.
  provisioner "shell" {
    inline = ["sudo apt-get update"]
  }

  provisioner "ansible" {
    playbook_file = "ansible/upgrade.yml"
    use_proxy     = false
    use_sftp      = true
  }

  provisioner "ansible" {
    playbook_file = "ansible/python.yml"
    use_proxy     = false
    use_sftp      = true
  }

  provisioner "ansible" {
    ansible_env_vars = ["AWS_DEFAULT_REGION=${var.build_region}"]
    playbook_file    = "ansible/playbook.yml"
    use_proxy        = false
    use_sftp         = true
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} bash {{ .Path }} ; rm -f {{ .Path }}"
    script          = "ansible/post_setup.sh"
    skip_clean      = true
  }

  provisioner "shell" {
    # We need to call bash here because /tmp has the noexec bit on it
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} bash {{ .Path }} ; rm -f {{ .Path }}"
    inline          = ["sed --in-place '/^users:/ {N; s/users:.*/users: []/g}' /etc/cloud/cloud.cfg", "rm --force /etc/sudoers.d/90-cloud-init-users", "rm --force /root/.ssh/authorized_keys"]
    skip_clean      = true
  }
}
