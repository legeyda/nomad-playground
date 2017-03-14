job "anyorigin" {
  datacenters = ["dc1"]

  type = "service"

  # constraint {
  #   attribute = "${attr.kernel.name}"
  #   value     = "linux"
  # }

  update {
    stagger = "10s"
    max_parallel = 1
  }

  group "cache" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"

      delay = "25s"

      mode = "delay"
    }

    ephemeral_disk {
      size = 300
    }

    task "anyorigin" {
      driver = "rkt"

      config {
        image = "legeyda.com/anyorigin"
        volumes = ["/etc/resolv.conf:/etc/resolv.conf"]
        port_map {
          app = "http"
        }
      }

      resources {
        cpu    = 500
        memory = 256
        network {
          mbits = 10
          port "app" {}
        }
      }

      service {
        name = "anyorigin-service"
        tags = ["global", "cache"]
        port = "app"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      env {
        CONSUL_HTTP_ADDR = "${NOMAD_IP_app}:8500"
      }


    }
  }
}
