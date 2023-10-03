//usage: flowpipe pipeline run pull_request_comment --pipeline-arg pull_request_number=160 --pipeline-arg "comment=this is a comment with spaces and alphanumerics 12345."
pipeline "pull_request_comment" {
  description = "Create a comment on pull request."

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

  param "pull_request_number" {
    type = number
  }

  param "comment" {
    type = string
  }

  step "pipeline" "pull_request_get_by_number" {
    pipeline = pipeline.pull_request_get_by_number
    args = {
      github_token        = param.github_token
      github_owner        = param.github_owner
      github_repo         = param.github_repo
      pull_request_number = param.pull_request_number
    }
  }

  step "http" "pull_request_comment" {
    title  = "Create a comment on pull request."
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
                    subjectId: "${step.pipeline.pull_request_get_by_number.pull_request_id}", 
                    body: "${param.comment}"
                  }) {
                  clientMutationId
                  commentEdge {
                    node {
                      pullRequest {
                        url
                        id
                      }
                    }
                  }
                }
              }
            EOM
    })
  }

  output "pull_request_id" {
    value = jsondecode(step.http.pull_request_comment.response_body).data.addComment.commentEdge.node.pullRequest.id
  }
  output "pull_request_url" {
    value = jsondecode(step.http.pull_request_comment.response_body).data.addComment.commentEdge.node.pullRequest.url
  }
  output "response_body" {
    value = step.http.pull_request_comment.response_body
  }
  output "response_headers" {
    value = step.http.pull_request_comment.response_headers
  }
  output "status_code" {
    value = step.http.pull_request_comment.status_code
  }

}
