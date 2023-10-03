// usage: flowpipe pipeline run pull_request_search --pipeline-arg "search_value=160"
// usage: flowpipe pipeline run pull_request_search --pipeline-arg 'search_value=[URGENTFIX]'
pipeline "pull_request_search" {
  description = "Find a pull request in a repository."

  param "github_token" {
    type    = string
    default = var.github_token
  }

  param "github_owner" {
    type    = string
    default = local.github_owner
  }

  param "github_repo" {
    type    = string
    default = local.github_repo
  }

  param "search_value" {
    type    = string
    default = ""
  }

  step "http" "pull_request_search" {
    title  = "Find a pull request in a repository."
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }
    // TODO: last:20? should that be a parameter? is there performance issue or rate limit if we do beyond 20
    request_body = jsonencode({
      query = <<EOM
              query {
                search(type: ISSUE, query: "type:pr owner:${param.github_owner} repo:${param.github_repo} ${param.search_value}", last: 20) {
                  issueCount
                  nodes {
                    ... on PullRequest {
                      createdAt
                      title
                      number
                      url
                      repository {
                        name
                      }
                    }
                  }
                }
              }
            EOM
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
