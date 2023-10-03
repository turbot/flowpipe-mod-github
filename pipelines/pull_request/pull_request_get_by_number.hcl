// usage: flowpipe pipeline run pull_request_get_by_number --pipeline-arg pull_request_number=160
// usage: flowpipe pipeline run pull_request_get_by_number --pipeline-arg 'pull_request_number=160'
pipeline "pull_request_get_by_number" {
  description = "Get the details of a Pull Request."

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

  param "pull_request_number" {
    type = number
  }

  step "http" "pull_request_get_by_number" {
    title  = "Get the details of a Pull Request."
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOM
              query {
                repository(owner: "${param.github_owner}", name: "${param.github_repo}") {
                  pullRequest(number: ${param.pull_request_number}) {
                    body
                    id
                    number
                    title
                    url
                  }
                }
              }
            EOM
    })
  }

  output "pull_request_id" {
    value = jsondecode(step.http.pull_request_get_by_number.response_body).data.repository.pullRequest.id
  }
  output "pull_request_url" {
    value = jsondecode(step.http.pull_request_get_by_number.response_body).data.repository.pullRequest.url
  }
  output "response_body" {
    value = step.http.pull_request_get_by_number.response_body
  }
  output "response_headers" {
    value = step.http.pull_request_get_by_number.response_headers
  }
  output "status_code" {
    value = step.http.pull_request_get_by_number.status_code
  }

}
