provider "google" {
  project = "k8s-monitoring-project"
  region  = "us-west1"
  version = "~> 3.47"
}

provider "random" {
  version = "~> 3.0"
}
