// usage: flowpipe pipeline run repository_search  --pipeline-arg "search_value=steampipe"
// usage: flowpipe pipeline run repository_search  --pipeline-arg "search_value=owner:turbot steampipe"
// usage: flowpipe pipeline run repository_search  --pipeline-arg "search_value=repo:vkumbha/deleteme"
pipeline "repository_search" {
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

  param "search_limit" {
    type    = number
    default = 20
  }

  step "http" "repository_search" {
    title  = "Find a repository."
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        query {
          search(type: REPOSITORY, query: "${param.search_value}", last: ${param.search_limit}) {
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
        EOQ
    })
  }

  output "repository_count" {
    value = jsondecode(step.http.repository_search.response_body).data.search.repositoryCount
  }
  output "response_body" {
    value = step.http.repository_search.response_body
  }
  output "response_headers" {
    value = step.http.repository_search.response_headers
  }
  output "status_code" {
    value = step.http.repository_search.status_code
  }

}
