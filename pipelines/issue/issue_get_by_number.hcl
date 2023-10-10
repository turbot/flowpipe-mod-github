// usage: flowpipe pipeline run issue_get --pipeline-arg issue_number=151
pipeline "issue_get_by_number" {
  description = "Get issue details by issue number."

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

  param "issue_number" {
    type = number
  }

  step "http" "issue_get_by_number" {
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
    value = jsondecode(step.http.issue_get_by_number.response_body).data.repository.issue.id
  }
  output "issue_url" {
    value = jsondecode(step.http.issue_get_by_number.response_body).data.repository.issue.url
  }
  output "response_body" {
    value = step.http.issue_get_by_number.response_body
  }
  output "response_headers" {
    value = step.http.issue_get_by_number.response_headers
  }
  output "status_code" {
    value = step.http.issue_get_by_number.status_code
  }

}
