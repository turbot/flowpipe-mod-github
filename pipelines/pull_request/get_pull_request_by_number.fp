pipeline "get_pull_request_by_number" {
  title       = "Get Pull Request by Number"
  description = "Get the details of a Pull Request."

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

  param "pull_request_number" {
    type        = number
    description = "The pull request number."
  }

  step "http" "get_pull_request_by_number" {
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
            pullRequest(number: ${param.pull_request_number}) {
              body
              id
              number
              title
              url
            }
          }
        }
        EOQ
    })

    throw {
      if      = can(result.response_body.errors)
      message = join(", ", flatten([for error in result.response_body.errors : error.message]))
    }
  }

  output "pull_request" {
    description = "Pull request details."
    value       = step.http.get_pull_request_by_number.response_body.data.repository.pullRequest
  }

}
