# usage: flowpipe pipeline run get_repository_by_full_name
pipeline "get_repository_by_full_name" {
  title       = "Get Repository by Full Name"
  description = "Get the details of a given repository by the owner and repository name."

  param "access_token" {
    type        = string
    description = local.access_token_param_description
    default     = var.access_token
  }

  param "repository_owner" {
    type        = string
    description = local.repository_owner_param_description
    default     = local.repository_owner
  }

  param "repository_name" {
    type        = string
    description = local.repository_name_param_description
    default     = local.repository_name
  }

  step "http" "get_repository_by_full_name" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.access_token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        query {
          repository(owner: "${param.repository_owner}", name: "${param.repository_name}") {
            description
            forkCount
            id
            name
            owner {
              id
            }
            stargazerCount
            url
            visibility
          }
        }
        EOQ
    })
  }

  output "repository" {
    description = "Repository details."
    value       = step.http.get_repository_by_full_name.response_body.data.repository
  }

}
