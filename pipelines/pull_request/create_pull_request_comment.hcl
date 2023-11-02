//usage: flowpipe pipeline run create_pull_request_comment --pipeline-arg pull_request_number=160 --pipeline-arg "pull_request_comment=this is a comment with spaces and alphanumerics 12345."
pipeline "create_pull_request_comment" {
  title = "Create Pull Request Comment"
  description = "Create a comment on pull request."

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

  param "pull_request_number" {
    type = number
  }

  param "pull_request_comment" {
    type = string
  }

  step "pipeline" "get_pull_request_by_number" {
    pipeline = pipeline.get_pull_request_by_number
    args = {
      token               = param.token
      repository_owner    = param.repository_owner
      repository_name     = param.repository_name
      pull_request_number = param.pull_request_number
    }
  }

  step "http" "create_pull_request_comment" {
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
            input: {subjectId: "${step.pipeline.get_pull_request_by_number.pull_request_id}", body: "${param.pull_request_comment}"}
          ) {
            clientMutationId
            commentEdge {
              node {
                pullRequest {
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

  output "pull_request" {
    value = step.http.create_pull_request_comment.response_body.data.addComment.commentEdge.node.pullRequest
  }

}
