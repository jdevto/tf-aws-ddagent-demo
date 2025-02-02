variable "use_case" {
  description = "Specifies the use case for this Terraform module."
  type        = string
}

variable "dd_api_key" {
  description = "Datadog API key used for installing and configuring the Datadog Agent."
  type        = string
}
