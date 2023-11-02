// usage: flowpipe pipeline run pull_request_list --pipeline-arg pull_request_limit=10
pipeline "pull_request_list" {
  title       = "List Pull Requests"
  description = "List pull requests in the repository."

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

  param "pull_request_limit" {
    type    = number
    default = 20
  }

  param "pull_request_state" {
    type = string
    default = "OPEN"
  }

  step "http" "pull_request_list" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
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
    value = step.http.pull_request_list.response_body.data.repository.pullRequests.nodes
  }

}
