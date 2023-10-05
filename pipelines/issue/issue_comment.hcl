// usage: flowpipe pipeline run issue_comment --pipeline-arg "issue_number=151" --pipeline-arg "comment=please provide update on the issue, Thanks."
pipeline "issue_comment" {
  description = "Create a comment on an Issue."

  param "github_token" {
    type    = string
    default = var.github_token
  }

  param "github_owner" {
    type    = string
    default = local.github_owner
  }

  param "github_repo" {
    type    = string
    default = local.github_repo
  }

  param "issue_number" {
    type = number
  }

  param "comment" {
    type = string
  }

  step "pipeline" "issue_get" {
    pipeline = pipeline.issue_get
    args = {
      github_token = param.github_token
      github_owner = param.github_owner
      github_repo  = param.github_repo
      issue_number = param.issue_number
    }
  }

  step "http" "issue_comment" {
    title  = "Create a comment on an Issue."
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOM
              mutation {
                addComment(input: 
                  {
                    subjectId: "${step.pipeline.issue_get.issue_id}", 
                    body: "${param.comment}"
                  }) {
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
            EOM
    })
  }

  output "issue_url" {
    value = jsondecode(step.http.issue_comment.response_body).data.addComment.commentEdge.node.issue.url
  }
  output "issue_id" {
    value = jsondecode(step.http.issue_comment.response_body).data.addComment.commentEdge.node.issue.id
  }
  output "response_body" {
    value = step.http.issue_comment.response_body
  }
  output "response_headers" {
    value = step.http.issue_comment.response_headers
  }
  output "status_code" {
    value = step.http.issue_comment.status_code
  }

}
