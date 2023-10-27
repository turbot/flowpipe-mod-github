// usage: flowpipe pipeline run search_pull_request --pipeline-arg "search_value=160"
// usage: flowpipe pipeline run search_pull_request --pipeline-arg 'search_value=[URGENTFIX]'
pipeline "search_pull_request" {
  title       = "Search Pull Request"
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

  step "http" "search_pull_request" {
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
    value = step.http.search_pull_request.response_body.data.search.issueCount
  }
  output "response_body" {
    value = step.http.search_pull_request.response_body
  }
  output "response_headers" {
    value = step.http.search_pull_request.response_headers
  }
  output "status_code" {
    value = step.http.search_pull_request.status_code
  }

}
