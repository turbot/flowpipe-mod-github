// usage: flowpipe pipeline run issue_delete_comment --pipeline-arg "issue_comment_id=IC_kwDOKdfCIs5pTwoh"
pipeline "issue_delete_comment" {
  description = "Delete a comment in an issue."

  param "token" {
    type    = string
    default = var.token
  }

  param "repository_owner" {
    type    = string
    default = local.repository_owner
  }

  param "repository_name" {
    type    = string
    default = local.repository_name
  }

  param "issue_comment_id" {
    type = string
  }

  step "http" "issue_delete_comment" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation add_comment {
          deleteIssueComment(input: {id: "${param.issue_comment_id}"}) {
            clientMutationId
          }
        }
        EOQ
    })
  }

  output "response_body" {
    value = step.http.issue_delete_comment.response_body
  }
  output "response_headers" {
    value = step.http.issue_delete_comment.response_headers
  }
  output "status_code" {
    value = step.http.issue_delete_comment.status_code
  }

}
