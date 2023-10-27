// usage: flowpipe pipeline run list_issue --pipeline-arg issues_limit=10
pipeline "list_issue" {
  title = "List Issue"
  description = "List issues in the repository."

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

  param "issues_limit" {
    type    = number
    default = 20
  }

  param "issue_state" {
    type = string
    default = "OPEN"
  }

  step "http" "list_issue" {
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
            issues(first: ${param.issues_limit}, states: ${param.issue_state}) {
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
    value = step.http.list_issue.response_body.data.repository.issues.nodes
  }
  output "total_open_issues" {
    value = step.http.list_issue.response_body.data.repository.issues.totalCount
  }
  output "response_body" {
    value = step.http.list_issue.response_body
  }
  output "response_headers" {
    value = step.http.list_issue.response_headers
  }
  output "status_code" {
    value = step.http.list_issue.status_code
  }

}
