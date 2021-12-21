variable "region" {
  description = "Region to deploy resources in"
  type        = string
  default     = "ap-southeast-2"
}

variable "target" {
  description = "Target URL to run Apache Benchmark against"
  type        = string
}
