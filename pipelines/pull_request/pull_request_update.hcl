// usage: flowpipe pipeline run pull_request_update --pipeline-arg pull_request_number=160 --pipeline-arg "body=a very new and updated  body" --pipeline-arg "title=brand new title" --pipeline-arg 'assignee_ids=["MDQ6VXNlcjQwOTczODYz", "MDQ6VXNlcjM4MjE4NDE4"]' 
pipeline "pull_request_update" {
  description = "Update a Pull Request in a repository."

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

  param "pull_request_number" {
    type = number
  }

  param "body" {
    type = string
  }

  param "title" {
    type = string
  }

  param "assignee_ids" {
    type = list(string)
  }

  step "pipeline" "pull_request_get" {
    pipeline = pipeline.pull_request_get
    args = {
      github_token        = param.github_token
      github_owner        = param.github_owner
      github_repo         = param.github_repo
      pull_request_number = param.pull_request_number
    }
  }

  step "http" "pull_request_update" {
    title  = "Update a Pull Request in a repository."
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          updatePullRequest(
            input: {pullRequestId: "${step.pipeline.pull_request_get.pull_request_id}", title: "${param.title}", 
            body: "${param.body}", assigneeIds: ${jsonencode(param.assignee_ids)}}
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
    value = jsondecode(step.http.pull_request_update.response_body).data.updatePullRequest.pullRequest.id
  }
  output "pull_request_url" {
    value = jsondecode(step.http.pull_request_update.response_body).data.updatePullRequest.pullRequest.url
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
