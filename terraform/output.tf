output "kops_bucket" {
  value = google_storage_bucket.kops-state.name
}
