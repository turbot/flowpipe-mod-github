pipeline "list_issues" {
  title       = "List Issues"
  description = "List issues in the repository."

  param "cred" {
    type        = string
    description = local.cred_param_description
    default     = "default"
  }

  param "repository_owner" {
    type        = string
    description = local.repository_owner_param_description
  }

  param "repository_name" {
    type        = string
    description = local.repository_name_param_description
  }

  param "issues_limit" {
    type    = number
    default = 20
  }

  param "issue_state" {
    type        = string
    description = "The possible states of an issue. Allowed values are OPEN and CLOSED. Defaults to OPEN."
    default     = "OPEN"
  }

  step "http" "list_issues" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        query {
          repository(owner: "${param.repository_owner}", name: "${param.repository_name}") {
            issues(first: ${param.issues_limit}, states: [${param.issue_state}]) {
              nodes {
                body
                createdAt
                number
                state
                title
                url
                author{
                  login
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
    description = "List of Issues."
    value       = step.http.list_issues.response_body.data.repository.issues.nodes
  }

}
