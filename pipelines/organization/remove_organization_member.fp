pipeline "remove_organization_member" {
  title       = "Remove organization member"
  description = "Removes a member from an organization."

  param "cred" {
    type        = string
    description = local.cred_param_description
    default     = "default"
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
    method = "DELETE"
    url    = "https://api.github.com/orgs/${param.organization}/members/${param.username}"

    request_headers = {
      Accept               = "application/vnd.github+json"
      Authorization        = "Bearer ${credential.github[param.cred].token}"
      X-GitHub-Api-Version = "2022-11-28"
    }

    throw {
      if      = can(result.response_body.errors[0].message)
      message = result.response_body.errors[0].message
    }
  }

}
