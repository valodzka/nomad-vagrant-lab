job "fail" {
  datacenters = ["toronto"]

  constraint {
    attribute = "${attr.unique.consul.name}"
    operator = "regexp"
    value = "^(nomad-a-3)$"
  }

  update {
    healthy_deadline = "30s"
    progress_deadline = "40s"
    min_healthy_time = "0s"
  }

  meta {
    redeploy = 1
  }

  group "fail-failed" {
    count = "1"

    network {
      port "http" {
        to = 8080
      }
    }
    service {
      port = "http"
      check {
        port     = "http"
        type     = "http"
        path     = "/health"
        method   = "GET"
        interval = "10s"
        timeout  = "2s"
        check_restart {
          limit = 2
        }
      }
    }

    task "fail" {
      driver = "docker"
      config {
      # here https://medium.com/@obenaus.thomas/a-good-default-nomad-job-template-ea448b8a8cdd
        image = "thobe/fail_service:latest"
        ports = ["http"]
      }
      resources {
        cores = 1
      }

      env {
        # unhealhy config
        HEALTHY_FOR   = 60
        UNHEALTHY_FOR = -1
	# healthy config
	# HEALTHY_FOR = -1
      }
    }
  }
}