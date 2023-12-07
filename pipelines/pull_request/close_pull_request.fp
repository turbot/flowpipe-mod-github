# usage: flowpipe pipeline run close_pull_request --arg pull_request_number=160
pipeline "close_pull_request" {
  title       = "Close Pull Request"
  description = "Closes a pull request."

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

  step "pipeline" "get_pull_request_by_number" {
    pipeline = pipeline.get_pull_request_by_number
    args = {
      cred                = param.cred
      repository_owner    = param.repository_owner
      repository_name     = param.repository_name
      pull_request_number = param.pull_request_number
    }
  }

  step "http" "close_pull_request" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          closePullRequest(
            input: {pullRequestId: "${step.pipeline.get_pull_request_by_number.output.pull_request.id}"}
          ) {
            pullRequest {
              url
              id
            }
          }
        }
        EOQ
    })

    throw {
      if      = can(result.response_body.errors[0].message)
      message = result.response_body.errors[0].message
    }
  }

  output "pull_request" {
    description = "Closed pull request details."
    value       = step.http.close_pull_request.response_body.data.closePullRequest.pullRequest
  }

}
