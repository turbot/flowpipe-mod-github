// usage: flowpipe pipeline run pull_request_list --pipeline-arg pull_request_limit=10
pipeline "pull_request_list" {
  description = "List of Open Pull Requests in the repository."

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

  param "pull_request_limit" {
    type    = number
    default = 20
  }

  param "status" {
    type = string
    default = "OPEN"
  }

  step "http" "pull_request_list" {
    title  = "List of first (oldest) Open Pull Requests in the repository."
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        query {
          repository(owner: "${param.github_owner}", name: "${param.github_repo}") {
            pullRequests(first: ${param.pull_request_limit}, states: ${param.status}) {
              totalCount
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
  }

  output "list_nodes" {
    value = jsondecode(step.http.pull_request_list.response_body).data.repository.pullRequests.nodes
  }
  output "total_open_pull_requests" {
    value = jsondecode(step.http.pull_request_list.response_body).data.repository.pullRequests.totalCount
  }
  output "response_body" {
    value = step.http.pull_request_list.response_body
  }
  output "response_headers" {
    value = step.http.pull_request_list.response_headers
  }
  output "status_code" {
    value = step.http.pull_request_list.status_code
  }

}
