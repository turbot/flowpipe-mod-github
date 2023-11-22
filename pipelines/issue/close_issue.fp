# usage: flowpipe pipeline run close_issue --pipeline-arg issue_number=151
pipeline "close_issue" {
  title       = "Close Issue"
  description = "Close an issue with the given ID."

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

  param "state_reason" {
    // type    = set(string) //TODO
    // default = ["COMPLETED", "NOT_PLANNED"]
    type        = string
    description = "The reason for closing the issue."
    default     = "COMPLETED"
  }

  step "pipeline" "get_issue_by_number" {
    pipeline = pipeline.get_issue_by_number

    args = {
      access_token     = param.access_token
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
      Authorization = "Bearer ${param.access_token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          closeIssue(
            input: {issueId: "${step.pipeline.get_issue_by_number.output.issue.id}", stateReason: ${param.state_reason}}
          ) {
            clientMutationId
            issue {
              id
              url
            }
          }
        }
        EOQ
    })
  }

  output "issue" {
    description = "The closed issue."
    value       = step.http.close_issue.response_body.data.closeIssue.issue
  }

}
