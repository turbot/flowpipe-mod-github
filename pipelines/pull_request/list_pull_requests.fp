# usage: flowpipe pipeline run list_pull_requests --arg pull_request_limit=10 --arg pull_request_state="OPEN,CLOSED"
pipeline "list_pull_requests" {
  title       = "List Pull Requests"
  description = "List pull requests in the repository."

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

  param "pull_request_limit" {
    type        = number
    description = "Returns the first n elements from the list."
    default     = 20
  }

  param "pull_request_state" {
    type        = string
    description = "The state to filter the pull requests by. Allowed values are CLOSED, MERGED and OPEN. Defaults to OPEN."
    default     = "OPEN"
  }

  step "http" "list_pull_requests" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        query {
          repository(owner: "${param.repository_owner}", name: "${param.repository_name}") {
            pullRequests(first: ${param.pull_request_limit}, states: [${param.pull_request_state}]) {
              nodes {
                baseRepository {
                  name
                }
                baseRef {
                  name
                }
                headRepository {
                  name
                }
                headRef {
                  name
                }
                isDraft
                number
                state
                title
                url
              }
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

  output "pull_requests" {
    description = "List of pull requests."
    value       = step.http.list_pull_requests.response_body.data.repository.pullRequests.nodes
  }

}
