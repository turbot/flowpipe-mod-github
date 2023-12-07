# usage: flowpipe pipeline run get_repository_owner --arg "repository_owner=steampipe"
pipeline "get_repository_owner" {
  title       = "Get Repository Owner"
  description = "Get the details of a repository owner (ie. either a User or an Organization) by login."

  param "cred" {
    type        = string
    description = local.cred_param_description
    default     = "default"
  }

  param "repository_owner" {
    type        = string
    description = local.repository_owner_param_description
    default     = local.repository_owner
  }

  step "http" "get_repository_owner" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        query {
          repositoryOwner(login: "${param.repository_owner}") {
            id
            login
            url
          }
        }
        EOQ
    })

    throw {
      if      = can(result.response_body.errors[0].message)
      message = result.response_body.errors[0].message
    }
  }

  output "repository_owner" {
    description = "Repository owner details."
    value       = step.http.get_repository_owner.response_body.data.repositoryOwner
  }

}
