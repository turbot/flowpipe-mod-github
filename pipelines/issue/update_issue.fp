# usage: flowpipe pipeline run update_issue --pipeline-arg 'issue_number=153' --pipeline-arg issue_title="[bug] - there is a bug" --pipeline-arg issue_body="please fix the bug" --pipeline-arg 'assignee_ids=["MDQ6VXNlcjQwOTczODYz", "MDQ6VXNlcjM4MjE4NDE4"]'
pipeline "update_issue" {
  title       = "Update Issue"
  description = "Update an issue's title, body, and assignees."

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
    description = "The ID of the Issue to modify."
  }

  param "issue_body" {
    type        = string
    description = "The body for the issue description."
  }

  param "issue_title" {
    type        = string
    description = "The title for the issue."
  }

  param "assignee_ids" {
    type        = list(string)
    description = "An array of Node IDs of users for this issue."
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

  step "http" "update_issue" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.access_token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          updateIssue(
            input: {id: "${step.pipeline.get_issue_by_number.output.issue.id}", body: "${param.issue_body}", title: "${param.issue_title}", assigneeIds: ${jsonencode(param.assignee_ids)}}
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
    description = "Issue details."
    value       = step.http.update_issue.response_body.data.updateIssue.issue
  }

}
