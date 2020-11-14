resource "random_string" "random" {
  length  = 16
  special = false
  upper   = false
}

resource "google_storage_bucket" "kops-state" {
  name          = "lcb-kops-state-${random_string.random.result}"
  location      = var.location
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_binding" "admin_role" {
  bucket = google_storage_bucket.kops-state.name
  role   = "roles/storage.admin"
  members = [
    "user:loganballard@gmail.com",
  ]
}
