terraform {
    backend "gcs" {
        bucket = "terraform-state-staging-ajwlicm56y"
        prefix = "terraform/state"
    }

    required_providers {
      google = {
        source = "hashicorp/google"
      }
    }
}

provider "google" {
    project = "agh-project-443322"
    region = "europe-central2"
    zone = "europe-central2-c"
}
