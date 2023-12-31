resource "yandex_compute_instance" "ansible" {

  name     = "ansible"
  hostname = "ansible"

  resources {
    cores  = 2
    memory = 2
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet01.id
    nat       = true
  }

  metadata = {
    ssh-keys = "cloud-user:${tls_private_key.ssh.public_key_openssh}"
  }

  connection {
    type        = "ssh"
    user        = "cloud-user"
    private_key = tls_private_key.ssh.private_key_pem
    host        = self.network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'host is up'",
      "sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm",
      "sudo dnf install wget -y",
      "sudo dnf update -y",
      "sudo dnf install -y ansible"
    ]
  }

  provisioner "file" {
    source      = "ansible"
    destination = "/home/cloud-user"
  }

  provisioner "file" {
    source      = "id_rsa"
    destination = "/home/cloud-user/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = "id_rsa.pub"
    destination = "/home/cloud-user/.ssh/id_rsa.pub"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/cloud-user/.ssh/id_rsa"
    ]
  }

  provisioner "file" {
    source      = "./ansible/ansible.cfg"
    destination = "/home/cloud-user/ansible.cfg"
  }

  provisioner "remote-exec" {
    inline = [
      "wget -P ansible/roles/kibana/files https://mirrors.huaweicloud.com/kibana/7.15.1/kibana-7.15.1-x86_64.rpm",
      "wget -P ansible/roles/elasticsearch/files https://mirrors.huaweicloud.com/elasticsearch/7.15.1/elasticsearch-7.15.1-x86_64.rpm",
      "wget -P ansible/roles/logstash/files https://mirrors.huaweicloud.com/logstash/7.17.2/logstash-7.17.2-x86_64.rpm",
      "ansible-playbook -u cloud-user -i /home/cloud-user/ansible/hosts /home/cloud-user/ansible/playbooks/main.yml",
    ]
  }

  depends_on = [
    yandex_compute_instance.nginx,
    yandex_compute_instance.db,
    yandex_compute_instance.iscsi,
    yandex_compute_instance.backend,
    yandex_compute_instance.els,
    yandex_compute_instance.kibana
  ]
}
