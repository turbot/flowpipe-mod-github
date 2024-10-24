pipeline "update_issue" {
  title       = "Update Issue"
  description = "Update an issue's title, body, and assignees."

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
      conn             = param.conn
      issue_number     = param.issue_number
      repository_name  = param.repository_name
      repository_owner = param.repository_owner
    }
  }

  step "http" "update_issue" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.conn.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          updateIssue(
            input: {id: "${step.pipeline.get_issue_by_number.output.issue.id}", body: "${param.issue_body}", title: "${param.issue_title}", assigneeIds: ${jsonencode(param.assignee_ids)}}
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
    description = "Issue details."
    value       = step.http.update_issue.response_body.data.updateIssue.issue
  }

}
