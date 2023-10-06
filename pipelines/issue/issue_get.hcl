// usage: flowpipe pipeline run issue_get --pipeline-arg issue_number=151
pipeline "issue_get" {
  description = "Get issue details from the current repository by number."

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

  param "issue_number" {
    type = number
  }

  step "http" "issue_get" {
    title  = "Get issue details from the current repository by number."
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
            issue(number: ${param.issue_number}) {
              body
              id
              number
              title
              url
            }
          }
        }
        EOQ
    })
  }

  output "issue_id" {
    value = jsondecode(step.http.issue_get.response_body).data.repository.issue.id
  }
  output "issue_url" {
    value = jsondecode(step.http.issue_get.response_body).data.repository.issue.url
  }
  output "response_body" {
    value = step.http.issue_get.response_body
  }
  output "response_headers" {
    value = step.http.issue_get.response_headers
  }
  output "status_code" {
    value = step.http.issue_get.status_code
  }

}
