pipeline "close_pull_request" {
  title       = "Close Pull Request"
  description = "Closes a pull request."

  param "conn" {
    type        = connection.github
    description = local.conn_param_description
    default     = connection.github.default
  }

  param "repository_owner" {
    type        = string
    description = local.repository_owner_param_description
  }

  param "repository_name" {
    type        = string
    description = local.repository_name_param_description
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
      Authorization = "Bearer ${param.conn.token}"
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
      if      = can(result.response_body.errors)
      message = join(", ", flatten([for error in result.response_body.errors : error.message]))
    }
  }

  output "pull_request" {
    description = "Closed pull request details."
    value       = step.http.close_pull_request.response_body.data.closePullRequest.pullRequest
  }

}
