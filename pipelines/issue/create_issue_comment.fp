pipeline "create_issue_comment" {
  title       = "Create Issue Comment"
  description = "Add a comment in an issue."

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
    description = "The number of the Issue to comment."
  }

  param "issue_comment" {
    type        = string
    description = "The contents of the comment."
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

  step "http" "create_issue_comment" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.conn.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          addComment(
            input: {subjectId: "${step.pipeline.get_issue_by_number.output.issue.id}", body: "${param.issue_comment}"}
          ) {
            commentEdge {
              node {
                id
                body
                url
                issue {
                  id
                  url
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

  output "issue_comment" {
    description = "Issue comment details."
    value       = step.http.create_issue_comment.response_body.data.addComment.commentEdge.node
  }

}
