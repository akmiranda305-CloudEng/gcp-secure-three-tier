terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    bucket = "portfolio-site-514615-tfstate"
    prefix = "secure-three-tier"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
