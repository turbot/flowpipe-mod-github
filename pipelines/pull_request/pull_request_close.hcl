// usage: flowpipe pipeline run pull_request_close --pipeline-arg pull_request_number=160
pipeline "pull_request_close" {
  description = "Close a pull request in a repository."

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

  step "pipeline" "pull_request_get" {
    pipeline = pipeline.pull_request_get
    args = {
      github_token        = param.github_token
      github_owner        = param.github_owner
      github_repo         = param.github_repo
      pull_request_number = param.pull_request_number
    }
  }

  step "http" "pull_request_close" {
    title  = "Close a Pull Request"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          closePullRequest(
            input: {pullRequestId: "${step.pipeline.pull_request_get.pull_request_id}"}
          ) {
            clientMutationId
            pullRequest {
              url
              id
            }
          }
        }
        EOQ
    })
  }

  output "pull_request_id" {
    value = jsondecode(step.http.pull_request_close.response_body).data.closePullRequest.pullRequest.id
  }
  output "pull_request_url" {
    value = jsondecode(step.http.pull_request_close.response_body).data.closePullRequest.pullRequest.url
  }
  output "response_body" {
    value = step.http.pull_request_close.response_body
  }
  output "response_headers" {
    value = step.http.pull_request_close.response_headers
  }
  output "status_code" {
    value = step.http.pull_request_close.status_code
  }

}
