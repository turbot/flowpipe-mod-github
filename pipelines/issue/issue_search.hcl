// usage: flowpipe pipeline run issue_search --pipeline-arg "search_value=[BUG]"
// usage: flowpipe pipeline run issue_search --pipeline-arg "search_value=151"
pipeline "issue_search" {
  description = "Search for issues in a repository."

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

  step "http" "issue_search" {
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
            query: "type:issue owner:${param.repository_owner} repo:${param.repository_name} ${param.search_value}"
            last: ${param.search_limit}
          ) {
            issueCount
            nodes {
              ... on Issue {
                createdAt
                number
                title
                url
                repository {
                  name
                }
              }
            }
          }
        }
        EOQ
    })
  }

  output "issues_count" {
    value = jsondecode(step.http.issue_search.response_body).data.search.issueCount
  }
  output "response_body" {
    value = step.http.issue_search.response_body
  }
  output "response_headers" {
    value = step.http.issue_search.response_headers
  }
  output "status_code" {
    value = step.http.issue_search.status_code
  }

}
