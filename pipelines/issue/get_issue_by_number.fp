# usage: flowpipe pipeline run get_issue_by_number --pipeline-arg issue_number=151
pipeline "get_issue_by_number" {
  title       = "Get Issue by Number"
  description = "Get issue details by issue number."

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

  param "issue_number" {
    type        = number
    description = "The number of the issue."
  }

  step "http" "get_issue_by_number" {
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
            issue(number: ${param.issue_number}) {
              author {
                  login
                }
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
  }

  output "issue" {
    description = "Issue details."
    value       = step.http.get_issue_by_number.response_body.data.repository.issue
  }

}
