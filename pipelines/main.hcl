pipeline "get_repository_id" {
  description = "Get the repository node ID."

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

  step "http" "get_repository_id" {
    title  = "Get repository Id"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOM
              query {
                repository(owner:"${param.github_owner}", name:"${param.github_repo}") {
                  id
                }
              }
            EOM
    })
  }

  output "repository_id" {
    value = jsondecode(step.http.get_repository_id.response_body).data.repository.id
  }
  output "response_body" {
    value = step.http.get_repository_id.response_body
  }
  output "response_headers" {
    value = step.http.get_repository_id.response_headers
  }
  output "status_code" {
    value = step.http.get_repository_id.status_code
  }

}
