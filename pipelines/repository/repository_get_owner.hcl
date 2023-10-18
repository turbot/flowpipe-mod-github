// usage: flowpipe pipeline run repository_get_owner --pipeline-arg "repository_owner=steampipe"
pipeline "repository_get_owner" {
  description = "Get the details of a repository owner (ie. either a User or an Organization) by login."

  param "token" {
    type    = string
    default = var.token
  }

  param "repository_owner" {
    type    = string
    default = local.repository_owner
  }

  step "http" "repository_get_owner" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        query {
          repositoryOwner(login: "${param.repository_owner}") {
            id
            login
            url
          }
        }
        EOQ
    })
  }

  output "owner_id" {
    value = step.http.repository_get_owner.response_body.data.repositoryOwner.id
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
