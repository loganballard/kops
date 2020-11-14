terraform {
  backend "gcs" {
    bucket = "lcb-tf-remote-state"
    prefix = "terraform/state"
  }
}
