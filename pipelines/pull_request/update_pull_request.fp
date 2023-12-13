pipeline "update_pull_request" {
  title       = "Update Pull Request"
  description = "Update a pull request's body, title, and assignees."

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
  param "pull_request_number" {
    type        = number
    description = "The pull request number."
  }

  param "pull_request_body" {
    type        = string
    description = "The contents of the pull request."
  }

  param "pull_request_title" {
    type        = string
    description = "The title of the pull request."
  }

  param "assignee_ids" {
    type        = list(string)
    description = "An array of Node IDs of users for this pull request."
  }

  step "pipeline" "get_pull_request_by_number" {
    pipeline = pipeline.get_pull_request_by_number
    args = {
      cred                = param.cred
      repository_owner    = param.repository_owner
      repository_name     = param.repository_name
      pull_request_number = param.pull_request_number
    }
  }

  step "http" "update_pull_request" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          updatePullRequest(
            input: {pullRequestId: "${step.pipeline.get_pull_request_by_number.output.pull_request.id}", title: "${param.pull_request_title}",
            body: "${param.pull_request_body}", assigneeIds: ${jsonencode(param.assignee_ids)}}
          ) {
            pullRequest {
              id
              url
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

  output "pull_request" {
    description = "Pull request details."
    value       = step.http.update_pull_request.response_body.data.updatePullRequest.pullRequest
  }

}
