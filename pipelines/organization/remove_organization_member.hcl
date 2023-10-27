pipeline "remove_organization_member" {
  title       = "Remove organization member"
  description = "Removes a member from an organization."

  param "token" {
    type        = string
    description = "The GitHub personal access token to authenticate to the GitHub APIs."
    default     = var.token
  }

  param "organization" {
    type        = string
    description = "The organization name. The name is not case sensitive."
  }

  param "username" {
    type        = string
    description = "The handle for the GitHub user account."
  }

  step "http" "remove_organization_member" {
    title  = "Remove an organization member"
    url    = "https://api.github.com/orgs/${param.organization}/members/${param.username}"
    method = "DELETE"
    request_headers = {
      Accept               = "application/vnd.github+json"
      Authorization        = "Bearer ${param.token}"
      X-GitHub-Api-Version = "2022-11-28"
    }

  }

  output "response_body" {
    value = step.http.remove_organization_member.response_body
  }
  output "response_headers" {
    value = step.http.remove_organization_member.response_headers
  }
  output "status_code" {
    value = step.http.remove_organization_member.status_code
  }
}
