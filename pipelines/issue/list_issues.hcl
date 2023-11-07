// usage: flowpipe pipeline run list_issues --pipeline-arg issues_limit=10
pipeline "list_issues" {
  title = "List Issues"
  description = "List issues in the repository."

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

  param "issues_limit" {
    type    = number
    default = 20
  }

  param "issue_state" {
    type = string
    default = "OPEN"
  }

  step "http" "list_issues" {
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
            issues(first: ${param.issues_limit}, states: ${param.issue_state}) {
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

  output "issues" {
    value = step.http.list_issues.response_body.data.repository.issues.nodes
  }

}
