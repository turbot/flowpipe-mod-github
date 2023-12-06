# usage: flowpipe pipeline run create_pull_request_comment --arg pull_request_number=160 --arg "pull_request_comment=this is a comment with spaces and alphanumerics 12345."
pipeline "create_pull_request_comment" {
  title       = "Create Pull Request Comment"
  description = "Create a comment on pull request."

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

  param "pull_request_number" {
    type        = number
    description = "The pull request number."
  }

  param "pull_request_comment" {
    type        = string
    description = "The contents of the comment."
  }

  step "pipeline" "get_pull_request_by_number" {
    pipeline = pipeline.get_pull_request_by_number
    args = {
      cred                = param.cred
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
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          addComment(
            input: {subjectId: "${step.pipeline.get_pull_request_by_number.output.pull_request.id}", body: "${param.pull_request_comment}"}
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
    description = "Pull request comment details."
    value       = step.http.create_pull_request_comment.response_body.data.addComment.commentEdge.node.pullRequest
  }

}