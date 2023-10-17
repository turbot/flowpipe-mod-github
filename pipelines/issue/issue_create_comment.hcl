// usage: flowpipe pipeline run issue_create_comment --pipeline-arg "issue_number=151" --pipeline-arg "issue_comment=please provide update on the issue, Thanks."
pipeline "issue_create_comment" {
  description = "Add a comment in an issue."

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

  param "issue_number" {
    type = number
  }

  param "issue_comment" {
    type = string
  }

  step "pipeline" "issue_get_by_number" {
    pipeline = pipeline.issue_get_by_number
    args = {
      token = param.token
      repository_owner = param.repository_owner
      repository_name  = param.repository_name
      issue_number = param.issue_number
    }
  }

  step "http" "issue_create_comment" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          addComment(
            input: {subjectId: "${step.pipeline.issue_get_by_number.issue_id}", body: "${param.issue_comment}"}
          ) {
            clientMutationId
            commentEdge {
              node {
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

  output "issue_url" {
    value = jsondecode(step.http.issue_create_comment.response_body).data.addComment.commentEdge.node.issue.url
  }
  output "issue_id" {
    value = jsondecode(step.http.issue_create_comment.response_body).data.addComment.commentEdge.node.issue.id
  }
  output "response_body" {
    value = step.http.issue_create_comment.response_body
  }
  output "response_headers" {
    value = step.http.issue_create_comment.response_headers
  }
  output "status_code" {
    value = step.http.issue_create_comment.status_code
  }

}
