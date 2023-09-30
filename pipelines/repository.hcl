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

pipeline "search_repository" {
  description = "Find a repository."

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

  param "search_value" {
    type    = string
    default = ""
  }

  step "http" "search_repository" {
    title  = "Find a repository."
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    // TODO: last:20? should that be a parameter? is there performance issue or rate limit if we do beyond 20
    request_body = jsonencode({
      query = <<EOM
              query {
                search(type: REPOSITORY, query: "${param.search_value}", last: 20) {
                  repositoryCount
                  edges {
                    node {
                      ... on Repository {
                        createdAt
                        forkCount
                        homepageUrl
                        name
                        stargazerCount
                        url
                        visibility
                      }
                    }
                  }
                }
              }
            EOM
    })
  }

  output "repository_count" {
    value = jsondecode(step.http.search_repository.response_body).data.search.repositoryCount
  }
  output "response_body" {
    value = step.http.search_repository.response_body
  }
  output "response_headers" {
    value = step.http.search_repository.response_headers
  }
  output "status_code" {
    value = step.http.search_repository.status_code
  }

}

pipeline "create_repository" {
  description = "Create a new repository."

  param "github_token" {
    type    = string
    default = var.github_token
  }

  param "github_login" {
    type    = string
    default = local.github_owner
  }

  param "name" {
    type = string
  }

  // TODO: How to pass set(string) ?
  param "visibility" {
    type = string
    // type    = set(string)
    // default = [
    // "PRIVATE", 
    // "PUBLIC", 
    // "INTERNAL"
    // ]
    default = "PRIVATE"

    // Unsupported block type: Blocks of type "validation" are not expected here.
    // validation {
    //   condition     = contains(["PRIVATE", "PUBLIC", "INTERNAL"], param.visibility)
    //   error_message = "Allowed values for input_parameter are \"PRIVATE\", \"PUBLIC\", or \"INTERNAL\"."
    // }
  }

  step "pipeline" "get_repository_owner" {
    pipeline = pipeline.get_repository_owner
    args = {
      github_token = var.github_token
      github_login = param.github_login
    }
  }

  step "http" "create_repository" {
    title  = "Create a new repository."
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }
    // TODO: Use param for visibility
    request_body = jsonencode({
      query = <<EOM
              mutation {
                createRepository(
                  input: {name: "${param.name}", ownerId: "${step.pipeline.get_repository_owner.owner_id}", visibility: PRIVATE}
                ) {
                  clientMutationId
                  repository {
                    id
                    url
                    name
                    visibility
                  }
                }
              }
            EOM
    })

    error {
      max_retries = 3
    }

  }

  output "repository_url" {
    value = jsondecode(step.http.create_repository.response_body).data.createRepository.repository.url
  }
  output "repository_id" {
    value = jsondecode(step.http.create_repository.response_body).data.createRepository.repository.id
  }
  output "response_body" {
    value = step.http.create_repository.response_body
  }
  output "response_headers" {
    value = step.http.create_repository.response_headers
  }
  output "status_code" {
    value = step.http.create_repository.status_code
  }

}
