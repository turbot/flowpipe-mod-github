# usage: flowpipe pipeline run update_pull_request --pipeline-arg pull_request_number=160 --pipeline-arg "pull_request_body=a very new and updated body" --pipeline-arg "pull_request_title=brand new title" --pipeline-arg 'assignee_ids=["MDQ6VXNlcjQwOTczODYz", "MDQ6VXNlcjM4MjE4NDE4"]'
pipeline "update_pull_request" {
  title       = "Update Pull Request"
  description = "Update a pull request's body, title, and assignees."

  param "access_token" {
    type        = string
    description = local.access_token_param_description
    default     = var.access_token
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
      access_token        = param.access_token
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
      Authorization = "Bearer ${param.access_token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          updatePullRequest(
            input: {pullRequestId: "${step.pipeline.get_pull_request_by_number.output.pull_request.id}", title: "${param.pull_request_title}",
            body: "${param.pull_request_body}", assigneeIds: ${jsonencode(param.assignee_ids)}}
          ) {
            clientMutationId
            pullRequest {
              id
              url
            }
          }
        }
        EOQ
    })
  }

  output "pull_request" {
    description = "Pull request details."
    value       = step.http.update_pull_request.response_body.data.updatePullRequest.pullRequest
  }

}
