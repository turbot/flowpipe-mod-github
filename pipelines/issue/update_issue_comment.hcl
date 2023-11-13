# usage: flowpipe pipeline run update_issue_comment --pipeline-arg "issue_comment_id=IC_kwDOKdfCIs5pfQv-" --pipeline-arg "issue_comment=new comment goes here."
pipeline "update_issue_comment" {
  title       = "Update Issue Comment"
  description = "Update a comment in an issue."

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
      Authorization = "Bearer ${param.access_token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          updateIssueComment(input: {id: "${param.issue_comment_id}", body: "${param.issue_comment}"}) {
            clientMutationId
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
  }

  output "issue_comment" {
    value = step.http.update_issue_comment.response_body.data.updateIssueComment.issueComment
  }

}
