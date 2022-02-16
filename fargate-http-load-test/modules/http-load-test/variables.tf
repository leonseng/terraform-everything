####################
# Fargate settings #
####################
variable "load_test_image" {
  description = "Docker image for load test containers. Currently, containers must accept CMD list containing only a single item, which is the target URL"
  type        = string
}

variable "load_test_container_count" {
  description = "Desired number of load test containers to deploy"
  type        = number
}


################################
# Load test container settings #
################################
variable "target" {
  description = "Target URL to run Apache Benchmark against"
  type        = string
}

variable "concurrency_per_container" {
  description = "Number of concurrent requests from each instance of load test container"
  type        = number
}