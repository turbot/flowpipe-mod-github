pipeline "block_user_in_organization" {
  title       = "Block User in Organization"
  description = "Blocks a specified user from an organization, preventing them from collaborating on any repositories within that organization."

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

  step "http" "block_user_in_organization" {
    method = "put"
    url    = "https://api.github.com/orgs/${param.organization}/blocks/${param.username}"

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
