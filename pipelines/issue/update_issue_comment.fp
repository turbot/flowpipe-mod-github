pipeline "update_issue_comment" {
  title       = "Update Issue Comment"
  description = "Update a comment in an issue."

  param "cred" {
    type        = string
    description = local.cred_param_description
    default     = "default"
  }

  param "repository_owner" {
    type        = string
    description = local.repository_owner_param_description
  }

  param "repository_name" {
    type        = string
    description = local.repository_name_param_description
  }

  param "issue_comment_id" {
    type        = string
    description = "The ID of the IssueComment to modify."
  }

  param "issue_comment" {
    type        = string
    description = "The updated text of the comment."
  }

  step "http" "update_issue_comment" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          updateIssueComment(input: {id: "${param.issue_comment_id}", body: "${param.issue_comment}"}) {
            issueComment {
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
        EOQ
    })

    throw {
      if      = can(result.response_body.errors)
      message = join(", ", flatten([for error in result.response_body.errors : error.message]))
    }
  }

  output "issue_comment" {
    description = "The updated issue comment."
    value       = step.http.update_issue_comment.response_body.data.updateIssueComment.issueComment
  }

}
