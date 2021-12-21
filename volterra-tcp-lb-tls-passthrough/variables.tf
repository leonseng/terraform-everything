variable "api_endpoint" {
  description = "Tenant API url"
  type        = string
}

variable "api_p12_file" {
  description = "API credential p12 file path"
  type        = string
}

variable "namespace" {
  description = "Namespace to create objects in"
  type        = string
}

variable "origin_server_public_ips" {
  description = "Public IP addresses of origin server"
  type        = list(string)
}

variable "origin_server_port" {
  description = "Port of origin server"
  type        = number
  default     = 443
}

variable "lb_domain" {
  description = "Domain for load balancer. E.g.: foo.bar.com"
  type        = string
}

variable "lb_idle_timeout" {
  description = "The amount of time that a stream can exist without upstream or downstream activity, in milliseconds"
  type        = number
  default     = 3600
}
