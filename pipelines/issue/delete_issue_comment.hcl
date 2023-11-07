// usage: flowpipe pipeline run delete_issue_comment --pipeline-arg "issue_comment_id=IC_kwDOKdfCIs5pTwoh"
pipeline "delete_issue_comment" {
  title = "Delete Issue Comment"
  description = "Delete a comment in an issue."

  param "access_token" {
    type    = string
    default = var.access_token
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

  step "http" "delete_issue_comment" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.access_token}"
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

}
