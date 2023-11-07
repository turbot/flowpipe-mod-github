// usage: flowpipe pipeline run pull_request_list --pipeline-arg pull_request_limit=10
pipeline "list_pull_requests" {
  title       = "List Pull Requests"
  description = "List pull requests in the repository."

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

  param "pull_request_limit" {
    type    = number
    default = 20
  }

  param "pull_request_state" {
    type = string
    default = "OPEN"
  }

  step "http" "list_pull_requests" {
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
            pullRequests(first: ${param.pull_request_limit}, states: ${param.pull_request_state}) {
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

  output "pull_requests" {
    value = step.http.list_pull_requests.response_body.data.repository.pullRequests.nodes
  }

}
