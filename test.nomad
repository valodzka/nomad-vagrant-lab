variable "redeploy" {
  type = string
}

job "fail" {
  datacenters = ["toronto"]

  
 # constraint {
 #   attribute = "${attr.unique.consul.name}"
 #   operator = "regexp"
 #   value = "^(nomad-a-3)$"
 # }

  update {
    healthy_deadline = "30s"
    progress_deadline = "40s"
    min_healthy_time = "0s"
  }

  meta {
    redeploy = "${var.redeploy}"
  }

  group "fail-failed" {
    count = "50"

    update {
      max_parallel = 50
    }

    network {
      port "http" {
        to = 8080
      }
      port "test1" { }
      port "test2" { }
      port "test3" { }
      port "test4" { }
      port "test5" { }
      port "test6" { }
      port "test7" { }
      port "test8" { }
      port "test9" { }
      port "test0" { }
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
        #cores = 1
	memory = 64
	cpu = 64
      }

      env {
        # unhealhy config
        #HEALTHY_FOR   = 60
        #UNHEALTHY_FOR = -1
	# healthy config
	HEALTHY_FOR = -1
      }
    }
  }
}