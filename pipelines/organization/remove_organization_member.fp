pipeline "remove_organization_member" {
  title       = "Remove organization member"
  description = "Removes a member from an organization."

  param "conn" {
    type        = connection.github
    description = local.conn_param_description
    default     = connection.github.default
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
      Authorization        = "Bearer ${param.conn.token}"
      X-GitHub-Api-Version = "2022-11-28"
    }

    throw {
      if      = can(result.response_body.errors)
      message = join(", ", flatten([for error in result.response_body.errors : error.message]))
    }
  }

}
