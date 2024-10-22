pipeline "search_repositories" {
  title       = "Search Repositories"
  description = "Find a repository."

  param "conn" {
    type        = connection.github
    description = local.conn_param_description
    default     = connection.github.default
  }

  param "search_value" {
    type        = string
    description = "The search string to look for. Examples: steampipe, owner:turbot steampipe, repo:vkumbha/deleteme."
  }

  param "search_limit" {
    type        = number
    description = "Returns the last n elements from the list."
    default     = 20
  }

  step "http" "search_repositories" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.conn.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        query {
          search(type: REPOSITORY, query: "${param.search_value}", last: ${param.search_limit}) {
            nodes {
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
        EOQ
    })

    throw {
      if      = can(result.response_body.errors)
      message = join(", ", flatten([for error in result.response_body.errors : error.message]))
    }
  }

  output "repositories" {
    description = "Repository details."
    value       = step.http.search_repositories.response_body.data.search.nodes
  }

}
