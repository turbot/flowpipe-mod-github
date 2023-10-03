// usage: flowpipe pipeline run repository_get_by_full_name
pipeline "repository_get_by_full_name" {
  description = "Get the details of a given repository by the owner and repository name."

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

  step "http" "repository_get_by_full_name" {
    title  = "Get the details of a given repository by the owner and repository name."
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
                  description
                  forkCount
                  id
                  name
                  owner {
                    id
                  }
                  stargazerCount
                  url
                  visibility
                }
              }
            EOM
    })
  }

  output "repository_id" {
    value = jsondecode(step.http.repository_get_by_full_name.response_body).data.repository.id
  }
  output "response_body" {
    value = step.http.repository_get_by_full_name.response_body
  }
  output "response_headers" {
    value = step.http.repository_get_by_full_name.response_headers
  }
  output "status_code" {
    value = step.http.repository_get_by_full_name.status_code
  }

}
