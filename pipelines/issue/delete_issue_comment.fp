# usage: flowpipe pipeline run delete_issue_comment --arg "issue_comment_id=IC_kwDOKdfCIs5pTwoh"
pipeline "delete_issue_comment" {
  title       = "Delete Issue Comment"
  description = "Delete a comment in an issue."

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

  param "issue_comment_id" {
    type        = string
    description = "The ID of the IssueComment to delete."
  }

  step "http" "delete_issue_comment" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          deleteIssueComment(input: {id: "${param.issue_comment_id}"}) {
            clientMutationId
          }
        }
        EOQ
    })

    throw {
      if      = can(result.response_body.errors)
      message = join(", ", flatten([for error in result.response_body.errors : error.message]))
    }
  }

}
