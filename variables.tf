variable "name" {
  description = "Unique name to be used as bucket name, tag and origin id"
  type        = string
}

variable "target_hostname" {
  description = "The target hostname of the web bucket (e.g. app.srop.co)"
  type        = string
}

variable "region" {
  description = "The region to have the web bucket on"
  type        = string
  default     = "eu-west-1"
}

variable "zone_id" {
  description = "The AWS Route 53 Zone ID to create the records on"
  type        = string
}

variable "authentication" {
  type        = list(string)
  description = "List of username:password for Basic Authentication"
  default     = []
}
