variable "load_test_image" {
  description = "Docker image for load test containers. Currently, containers must accept CMD list containing only a single item, which is the target URL"
  type        = string
}

variable "target" {
  description = "Target URL to run Apache Benchmark against"
  type        = string
}
