// usage: flowpipe pipeline run pull_request_update --pipeline-arg pull_request_number=160 --pipeline-arg "pull_request_body=a very new and updated body" --pipeline-arg "pull_request_title=brand new title" --pipeline-arg 'assignee_ids=["MDQ6VXNlcjQwOTczODYz", "MDQ6VXNlcjM4MjE4NDE4"]' 
pipeline "pull_request_update" {
  description = "Update a pull request's body, title, and assignees."

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

  param "pull_request_number" {
    type = number
  }

  param "pull_request_body" {
    type = string
  }

  param "pull_request_title" {
    type = string
  }

  param "assignee_ids" {
    type = list(string)
  }

  step "pipeline" "pull_request_get_by_number" {
    pipeline = pipeline.pull_request_get_by_number
    args = {
      token        = param.token
      repository_owner        = param.repository_owner
      repository_name         = param.repository_name
      pull_request_number = param.pull_request_number
    }
  }

  step "http" "pull_request_update" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          updatePullRequest(
            input: {pullRequestId: "${step.pipeline.pull_request_get_by_number.pull_request_id}", title: "${param.pull_request_title}",
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

  output "pull_request_id" {
    value = step.http.pull_request_update.response_body.data.updatePullRequest.pullRequest.id
  }
  output "pull_request_url" {
    value = step.http.pull_request_update.response_body.data.updatePullRequest.pullRequest.url
  }
  output "response_body" {
    value = step.http.pull_request_update.response_body
  }
  output "response_headers" {
    value = step.http.pull_request_update.response_headers
  }
  output "status_code" {
    value = step.http.pull_request_update.status_code
  }

}
