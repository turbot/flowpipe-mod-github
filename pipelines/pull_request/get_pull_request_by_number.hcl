# usage: flowpipe pipeline run get_pull_request_by_number --pipeline-arg pull_request_number=160
# usage: flowpipe pipeline run get_pull_request_by_number --pipeline-arg 'pull_request_number=160'
pipeline "get_pull_request_by_number" {
  title       = "Get Pull Request By Number"
  description = "Get the details of a Pull Request."

  param "access_token" {
    type        = string
    description = local.access_token_param_description
    default     = var.access_token
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

  step "http" "get_pull_request_by_number" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.access_token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        query {
          repository(owner: "${param.repository_owner}", name: "${param.repository_name}") {
            pullRequest(number: ${param.pull_request_number}) {
              body
              id
              number
              title
              url
            }
          }
        }
        EOQ
    })
  }

  output "pull_request" {
    description = "Pull request details."
    value       = step.http.get_pull_request_by_number.response_body.data.repository.pullRequest
  }

}
