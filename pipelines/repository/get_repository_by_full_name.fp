pipeline "get_repository_by_full_name" {
  title       = "Get Repository by Full Name"
  description = "Get the details of a given repository by the owner and repository name."

  param "conn" {
    type        = connection.github
    description = local.conn_param_description
    default     = connection.github.default
  }

  param "repository_owner" {
    type        = string
    description = local.repository_owner_param_description
  }

  param "repository_name" {
    type        = string
    description = local.repository_name_param_description
  }

  step "http" "get_repository_by_full_name" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.conn.token}"
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

    throw {
      if      = can(result.response_body.errors)
      message = join(", ", flatten([for error in result.response_body.errors : error.message]))
    }
  }

  output "repository" {
    description = "Repository details."
    value       = step.http.get_repository_by_full_name.response_body.data.repository
  }

}
