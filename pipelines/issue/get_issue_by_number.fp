pipeline "get_issue_by_number" {
  title       = "Get Issue by Number"
  description = "Get issue details by issue number."

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

  param "issue_number" {
    type        = number
    description = "The number of the issue."
  }

  step "http" "get_issue_by_number" {
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
            issue(number: ${param.issue_number}) {
              body
              id
              number
              reactions {
                viewerHasReacted
              }
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

  output "issue" {
    description = "Issue details."
    value       = step.http.get_issue_by_number.response_body.data.repository.issue
  }

}
