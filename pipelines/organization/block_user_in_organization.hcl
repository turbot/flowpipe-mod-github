pipeline "block_user_in_organization" {
  title       = "Block User in Organization"
  description = "Blocks a specified user from an organization, preventing them from collaborating on any repositories within that organization."

  param "access_token" {
    type        = string
    description = local.access_token_param_description
    default     = var.access_token
  }

  param "organization" {
    type        = string
    description = "The organization name. The name is not case sensitive."
  }

  param "username" {
    type        = string
    description = "The handle for the GitHub user account."
  }

  step "http" "block_user_in_organization" {
    method = "PUT"
    url    = "https://api.github.com/orgs/${param.organization}/blocks/${param.username}"

    request_headers = {
      Accept               = "application/vnd.github+json"
      Authorization        = "Bearer ${param.access_token}"
      X-GitHub-Api-Version = "2022-11-28"
    }
  }

}
