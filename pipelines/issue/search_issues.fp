# usage: flowpipe pipeline run search_issues --arg "search_value=[BUG]"
# usage: flowpipe pipeline run search_issues --arg "search_value=151"
pipeline "search_issues" {
  title       = "Search Issues"
  description = "Search for issues in a repository."

  param "cred" {
    type        = string
    description = local.cred_param_description
    default     = "default"
  }

  param "repository_owner" {
    type        = string
    description = local.repository_owner_param_description
    default     = local.repository_owner
  }

  param "repository_name" {
    type        = string
    description = local.repository_name_param_description
    default     = local.repository_name
  }

  param "search_value" {
    type        = string
    description = "The search string to look for."
  }

  param "search_limit" {
    type        = number
    description = "Returns the last n elements from the list."
    default     = 20
  }

  step "http" "search_issues" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        query {
          search(
            type: ISSUE
            query: "type:issue owner:${param.repository_owner} repo:${param.repository_name} ${param.search_value}"
            last: ${param.search_limit}
          ) {
            nodes {
              ... on Issue {
                createdAt
                number
                title
                url
                repository {
                  name
                }
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

  output "issues" {
    description = "List of search issue results."
    value       = step.http.search_issues.response_body.data.search.nodes
  }

}
