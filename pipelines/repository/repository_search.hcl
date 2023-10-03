// usage: flowpipe pipeline run repository_search  --pipeline-arg "search_value=steampipe"
// usage: flowpipe pipeline run repository_search  --pipeline-arg "search_value=owner:turbot steampipe"
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

  step "http" "repository_search" {
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
