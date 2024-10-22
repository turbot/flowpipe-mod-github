pipeline "create_issue" {
  title       = "Create Issue"
  description = "Create a new issue."

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

  param "issue_title" {
    type        = string
    description = "The title for the issue."
  }

  param "issue_body" {
    type        = string
    description = "The body for the issue description."
  }

  step "pipeline" "get_repository_by_full_name" {
    pipeline = pipeline.get_repository_by_full_name
    args = {
      conn             = param.conn
      repository_owner = param.repository_owner
      repository_name  = param.repository_name
    }
  }

  step "http" "create_issue" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.conn.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          createIssue(
            input: {repositoryId: "${step.pipeline.get_repository_by_full_name.output.repository.id}", title: "${param.issue_title}", body: "${param.issue_body}"}
          ) {
            issue {
              id
              number
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
    value       = step.http.create_issue.response_body.data.createIssue.issue
  }

}
