// usage: flowpipe pipeline run update_issue_comment --pipeline-arg "issue_comment_id=IC_kwDOKdfCIs5pfQv-" --pipeline-arg "issue_comment=new comment goes here."
pipeline "update_issue_comment" {
  title = "Update Issue Comment"
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

  step "http" "update_issue_comment" {
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
    value = step.http.update_issue_comment.response_body
  }
  output "response_headers" {
    value = step.http.update_issue_comment.response_headers
  }
  output "status_code" {
    value = step.http.update_issue_comment.status_code
  }

}
