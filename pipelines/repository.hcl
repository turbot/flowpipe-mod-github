pipeline "get_repository" {
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

  step "http" "get_repository" {
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
    value = jsondecode(step.http.get_repository.response_body).data.repository.id
  }
  output "response_body" {
    value = step.http.get_repository.response_body
  }
  output "response_headers" {
    value = step.http.get_repository.response_headers
  }
  output "status_code" {
    value = step.http.get_repository.status_code
  }

}

pipeline "get_repository_owner" {
  description = "Get the details of a repository owner (ie. either a User or an Organization) by login."

  param "github_token" {
    type    = string
    default = var.github_token
  }

  param "github_login" {
    type    = string
    default = local.github_owner
  }

  step "http" "get_repository_owner" {
    title  = "Get repository Owner Id"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOM
              query {
                repositoryOwner(login: "${param.github_login}") {
                  id
                  login
                  url
                }

              }
            EOM
    })
  }

  output "owner_id" {
    value = jsondecode(step.http.get_repository_owner.response_body).data.repositoryOwner.id
  }
  output "response_body" {
    value = step.http.get_repository_owner.response_body
  }
  output "response_headers" {
    value = step.http.get_repository_owner.response_headers
  }
  output "status_code" {
    value = step.http.get_repository_owner.status_code
  }

}

// search repo

// create repo