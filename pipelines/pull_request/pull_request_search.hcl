// usage: flowpipe pipeline run pull_request_search --pipeline-arg "search_value=160"
// usage: flowpipe pipeline run pull_request_search --pipeline-arg 'search_value=[URGENTFIX]'
pipeline "pull_request_search" {
  description = "Search for pull requests in a repository."

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

  param "search_value" {
    type    = string
    default = ""
  }

  param "search_limit" {
    type    = number
    default = 20
  }

  step "http" "pull_request_search" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        query {
          search(
            type: ISSUE
            query: "type:pr owner:${param.repository_owner} repo:${param.repository_name} ${param.search_value}"
            last: ${param.search_limit}
          ) {
            issueCount
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

  output "pull_request_count" {
    value = jsondecode(step.http.pull_request_search.response_body).data.search.issueCount
  }
  output "response_body" {
    value = step.http.pull_request_search.response_body
  }
  output "response_headers" {
    value = step.http.pull_request_search.response_headers
  }
  output "status_code" {
    value = step.http.pull_request_search.status_code
  }

}
