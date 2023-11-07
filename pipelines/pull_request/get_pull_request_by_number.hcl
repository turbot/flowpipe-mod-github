// usage: flowpipe pipeline run get_pull_request_by_number --pipeline-arg pull_request_number=160
// usage: flowpipe pipeline run get_pull_request_by_number --pipeline-arg 'pull_request_number=160'
pipeline "get_pull_request_by_number" {
  title       = "Get Pull Request by Number"
  description = "Get the details of a Pull Request."

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

  param "pull_request_number" {
    type = number
  }

  step "http" "get_pull_request_by_number" {
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

  output "pull_request" {
    value = step.http.get_pull_request_by_number.response_body.data.repository.pullRequest
  }

}
