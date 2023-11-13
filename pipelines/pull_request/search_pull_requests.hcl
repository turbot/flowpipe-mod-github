# usage: flowpipe pipeline run search_pull_requests --pipeline-arg "search_value=160"
# usage: flowpipe pipeline run search_pull_requests --pipeline-arg 'search_value=[URGENTFIX]'
pipeline "search_pull_requests" {
  title       = "Search Pull Requests"
  description = "Search for pull requests in a repository."

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

  param "search_value" {
    type        = string
    description = "The search string to look for. Examples: Bug, [URGENTFIX]"
  }

  param "search_limit" {
    type        = number
    description = "Returns the last n elements from the list."
    default     = 20
  }

  step "http" "search_pull_requests" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.access_token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        query {
          search(
            type: ISSUE
            query: "type:pr owner:${param.repository_owner} repo:${param.repository_name} ${param.search_value}"
            last: ${param.search_limit}
          ) {
            nodes {
              ... on PullRequest {
                createdAt
                number
                repository {
                  name
                }
                title
                url
              }
            }
          }
        }
        EOQ
    })
  }

  output "pull_requests" {
    description = "Pull request details."
    value       = step.http.search_pull_requests.response_body.data.search.nodes
  }

}
