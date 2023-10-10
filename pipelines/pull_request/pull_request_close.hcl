// usage: flowpipe pipeline run pull_request_close --pipeline-arg pull_request_number=160
pipeline "pull_request_close" {
  description = "Close a pull request."

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

  step "pipeline" "pull_request_get_by_number" {
    pipeline = pipeline.pull_request_get_by_number
    args = {
      token        = param.token
      repository_owner        = param.repository_owner
      repository_name         = param.repository_name
      pull_request_number = param.pull_request_number
    }
  }

  step "http" "pull_request_close" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          closePullRequest(
            input: {pullRequestId: "${step.pipeline.pull_request_get_by_number.pull_request_id}"}
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
