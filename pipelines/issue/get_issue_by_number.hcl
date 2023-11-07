// usage: flowpipe pipeline run issue_get --pipeline-arg issue_number=151
pipeline "get_issue_by_number" {
  title = "Get Issue by Number"
  description = "Get issue details by issue number."

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

  param "issue_number" {
    type = number
  }

  step "http" "get_issue_by_number" {
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

  output "issue" {
    value = step.http.get_issue_by_number.response_body.data.repository.issue
  }

}
