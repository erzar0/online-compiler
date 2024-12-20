terraform {
  backend "gcs" {
    bucket = "agh-project-sabre-2-terraform"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.12.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}