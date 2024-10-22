pipeline "add_issue_assignees" {
  title       = "Add Issue Assignees"
  description = "Add assignees to an issue."

  tags = {
    recommended = "true"
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

  param "assignee_ids" {
    type        = list(string)
    description = "The list of assignee IDs to add to the issue."
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

  step "http" "add_issue_assignees" {
    method = "post"
    url    = "https://api.github.com/graphql"

    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.conn.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          addAssigneesToAssignable(
            input: {assignableId: "${step.pipeline.get_issue_by_number.output.issue.id}", assigneeIds: ${jsonencode(param.assignee_ids)}}
          ) {
            assignable {
              ... on Issue {
                id
                url
                assignees(last: 5) {
                  totalCount
                  nodes {
                    id
                    login
                    url
                    name
                    email
                  }
                }
              }
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
    description = "Issue assignee details."
    value       = step.http.add_issue_assignees.response_body.data.addAssigneesToAssignable.assignable
  }

}
