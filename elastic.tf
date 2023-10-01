resource "yandex_compute_instance" "els" {

  count    = 3
  name     = "els${count.index}"
  hostname = "els${count.index}"

  resources {
    cores  = 2
    memory = 4
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
    # nat       = true
  }

  metadata = {
    ssh-keys = "cloud-user:${tls_private_key.ssh.public_key_openssh}"
  }

}
