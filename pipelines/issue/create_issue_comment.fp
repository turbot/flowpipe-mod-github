# usage: flowpipe pipeline run create_issue_comment --arg "issue_number=151" --arg "issue_comment=please provide update on the issue, Thanks."
pipeline "create_issue_comment" {
  title       = "Create Issue Comment"
  description = "Add a comment in an issue."

  param "cred" {
    type        = string
    description = local.cred_param_description
    default     = "default"
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
    description = "The number of the Issue to comment."
  }

  param "issue_comment" {
    type        = string
    description = "The contents of the comment."
  }

  step "pipeline" "get_issue_by_number" {
    pipeline = pipeline.get_issue_by_number
    args = {
      cred             = param.cred
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
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          addComment(
            input: {subjectId: "${step.pipeline.get_issue_by_number.output.issue.id}", body: "${param.issue_comment}"}
          ) {
            clientMutationId
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
  }

  output "issue_comment" {
    description = "Issue comment details."
    value       = step.http.create_issue_comment.response_body.data.addComment.commentEdge.node
  }

}
