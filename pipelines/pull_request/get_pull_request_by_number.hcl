// usage: flowpipe pipeline run get_pull_request_by_number --pipeline-arg pull_request_number=160
// usage: flowpipe pipeline run get_pull_request_by_number --pipeline-arg 'pull_request_number=160'
pipeline "get_pull_request_by_number" {
  title       = "Get Pull Request by Number"
  description = "Get the details of a Pull Request."

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

  param "pull_request_number" {
    type = number
  }

  step "http" "get_pull_request_by_number" {
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
            pullRequest(number: ${param.pull_request_number}) {
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

  output "pull_request_id" {
    value = step.http.get_pull_request_by_number.response_body.data.repository.pullRequest.id
  }
  output "pull_request_url" {
    value = step.http.get_pull_request_by_number.response_body.data.repository.pullRequest.url
  }
  output "response_body" {
    value = step.http.get_pull_request_by_number.response_body
  }
  output "response_headers" {
    value = step.http.get_pull_request_by_number.response_headers
  }
  output "status_code" {
    value = step.http.get_pull_request_by_number.status_code
  }

}
