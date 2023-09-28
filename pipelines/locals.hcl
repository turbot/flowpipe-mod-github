locals {
  github_owner = split("/", var.repository_full_name)[0]
  github_repo  = split("/", var.repository_full_name)[1]
}
