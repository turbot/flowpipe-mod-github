// usage: flowpipe pipeline run issue_update_comment --pipeline-arg "issue_comment_id=IC_kwDOKdfCIs5pfQv-" --pipeline-arg "issue_comment=new comment goes here."
pipeline "issue_update_comment" {
  description = "Update a comment in an issue."

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

  param "issue_comment" {
    type = string
  }

  step "http" "issue_update_comment" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          updateIssueComment(input: {id: "${param.issue_comment_id}", body: "${param.issue_comment}"}) {
            clientMutationId
          }
        }
        EOQ
    })
  }

  output "response_body" {
    value = step.http.issue_update_comment.response_body
  }
  output "response_headers" {
    value = step.http.issue_update_comment.response_headers
  }
  output "status_code" {
    value = step.http.issue_update_comment.status_code
  }

}
