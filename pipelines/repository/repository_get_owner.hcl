// usage: flowpipe pipeline run repository_get_owner --pipeline-arg "github_login=steampipe"
pipeline "repository_get_owner" {
  description = "Get the details of a repository owner (ie. either a User or an Organization) by login."

  param "github_token" {
    type    = string
    default = var.github_token
  }

  param "github_login" {
    type    = string
    default = local.github_owner
  }

  step "http" "repository_get_owner" {
    title  = "Get repository Owner Id"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        query {
          repositoryOwner(login: "${param.github_login}") {
            id
            login
            url
          }
        }
        EOQ
    })
  }

  output "owner_id" {
    value = jsondecode(step.http.repository_get_owner.response_body).data.repositoryOwner.id
  }
  output "response_body" {
    value = step.http.repository_get_owner.response_body
  }
  output "response_headers" {
    value = step.http.repository_get_owner.response_headers
  }
  output "status_code" {
    value = step.http.repository_get_owner.status_code
  }

}
