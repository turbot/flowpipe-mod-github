pipeline "close_issue" {
  title       = "Close Issue"
  description = "Close an issue with the given ID."

  tags = {
    type = "featured"
  }

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

  param "state_reason" {
    type        = string
    description = "The reason for closing the issue. Supported values are COMPLETED and NOT_PLANNED."
    default     = "COMPLETED"
  }

  step "pipeline" "get_issue_by_number" {
    pipeline = pipeline.get_issue_by_number

    args = {
      conn             = param.conn
      repository_owner = param.repository_owner
      repository_name  = param.repository_name
      issue_number     = param.issue_number
    }
  }

  step "http" "close_issue" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.conn.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          closeIssue(
            input: {issueId: "${step.pipeline.get_issue_by_number.output.issue.id}", stateReason: ${param.state_reason}}
          ) {
            issue {
              id
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
    description = "The closed issue details."
    value       = step.http.close_issue.response_body.data.closeIssue.issue
  }

}
