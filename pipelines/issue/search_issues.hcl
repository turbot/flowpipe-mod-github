// usage: flowpipe pipeline run search_issues --pipeline-arg "search_value=[BUG]"
// usage: flowpipe pipeline run search_issues --pipeline-arg "search_value=151"
pipeline "search_issues" {
  title = "Search Issues"
  description = "Search for issues in a repository."

  param "access_token" {
    type    = string
    default = var.access_token
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

  step "http" "search_issues" {
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
            query: "type:issue owner:${param.repository_owner} repo:${param.repository_name} ${param.search_value}"
            last: ${param.search_limit}
          ) {
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

  output "issues" {
    value = step.http.search_issues.response_body.data.search.nodes
  }

}