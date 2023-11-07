// usage: flowpipe pipeline run get_repository_owner --pipeline-arg "repository_owner=steampipe"
pipeline "get_repository_owner" {
  title = "Get Repository Owner"
  description = "Get the details of a repository owner (ie. either a User or an Organization) by login."

  param "access_token" {
    type    = string
    default = var.access_token
  }

  param "repository_owner" {
    type    = string
    default = local.repository_owner
  }

  step "http" "get_repository_owner" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.access_token}"
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

  output "repository_owner" {
    value = step.http.get_repository_owner.response_body.data.repositoryOwner
  }

}
