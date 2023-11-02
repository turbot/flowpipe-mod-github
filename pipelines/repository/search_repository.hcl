// usage: flowpipe pipeline run search_repository  --pipeline-arg "search_value=steampipe"
// usage: flowpipe pipeline run search_repository  --pipeline-arg "search_value=owner:turbot steampipe"
// usage: flowpipe pipeline run search_repository  --pipeline-arg "search_value=repo:vkumbha/deleteme"
pipeline "search_repository" {
  title = "Search Repository"
  description = "Find a repository."

  param "token" {
    type    = string
    default = var.token
  }

  param "repository_owner" {
    type    = string
    default = local.repository_owner
  }

  param "repository_name" {
    type    = string
    default = local.repository_name
  }

  param "search_value" {
    type    = string
    default = ""
  }

  param "search_limit" {
    type    = number
    default = 20
  }

  step "http" "search_repository" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        query {
          search(type: REPOSITORY, query: "${param.search_value}", last: ${param.search_limit}) {
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

  output "repositories" {
    value = step.http.search_repository.response_body.data.search.node
  }

}
