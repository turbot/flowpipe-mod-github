// usage: flowpipe pipeline run issue_list --pipeline-arg issues_limit=10
pipeline "issue_list" {
  description = "List of Open issues in the repository."

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

  param "issues_limit" {
    type    = number
    default = 20
  }

  param "status" {
    type = string
    default = "OPEN"
  }

  step "http" "issue_list" {
    title  = "List of first (oldest) Open issues in the repository."
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
            issues(first: ${param.issues_limit}, states: ${param.status}) {
              totalCount
              nodes {
                body
                createdAt
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
    value = jsondecode(step.http.issue_list.response_body).data.repository.issues.nodes
  }
  output "total_open_issues" {
    value = jsondecode(step.http.issue_list.response_body).data.repository.issues.totalCount
  }
  output "response_body" {
    value = step.http.issue_list.response_body
  }
  output "response_headers" {
    value = step.http.issue_list.response_headers
  }
  output "status_code" {
    value = step.http.issue_list.status_code
  }

}
