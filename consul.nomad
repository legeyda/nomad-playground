job "consul" {
  datacenters = ["dc1"]

  type = "system"

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

    task "consul" {
      driver = "rkt"
      config {
        image = "docker://consul"
        volumes = ["/etc/resolv.conf:/etc/resolv.conf"]
        port_map {
          app = "8500-tcp"
        }
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
        network {
          mbits = 10
          port "app" {
            static = 8500
            host = "0.0.0.0"
          }
        }
      }

      service {
        name = "consul-system"
        tags = ["global", "cache"]
        port = "app"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
