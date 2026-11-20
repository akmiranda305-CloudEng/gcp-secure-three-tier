variable "project_id" {
  description = "Your GCP project ID"
  type        = string
}

variable "region" {
  description = "Region for all resources"
  type        = string
  default     = "us-central1"
}
