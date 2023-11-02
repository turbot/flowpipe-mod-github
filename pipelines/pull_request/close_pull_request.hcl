// usage: flowpipe pipeline run close_pull_request --pipeline-arg pull_request_number=160
pipeline "close_pull_request" {
  title       = "Close Pull Request"
  description = "Closes a pull request."

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

  step "pipeline" "get_pull_request_by_number" {
    pipeline = pipeline.get_pull_request_by_number
    args = {
      token        = param.token
      repository_owner        = param.repository_owner
      repository_name         = param.repository_name
      pull_request_number = param.pull_request_number
    }
  }

  step "http" "close_pull_request" {
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
            input: {pullRequestId: "${step.pipeline.get_pull_request_by_number.pull_request_id}"}
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

  output "pull_request" {
    value = step.http.close_pull_request.response_body.data.closePullRequest.pullRequest
  }

}
