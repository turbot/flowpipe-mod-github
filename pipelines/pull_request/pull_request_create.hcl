// usage: flowpipe pipeline run pull_request_create --pipeline-arg "pull_request_title=new PR title" --pipeline-arg "pull_request_body=pr body" --pipeline-arg "base_branch=main" --pipeline-arg "head_branch=demo-branch"
pipeline "pull_request_create" {
  description = "Create a pull request."

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

  param "pull_request_title" {
    type = string
  }

  param "pull_request_body" {
    type = string
  }

  param "base_branch" {
    type = string
  }

  param "head_branch" {
    type = string
  }

  step "pipeline" "repository_get_by_full_name" {
    pipeline = pipeline.repository_get_by_full_name
    args = {
      token = var.token
      repository_owner = param.repository_owner
      repository_name  = param.repository_name
    }
  }

  step "http" "pull_request_create" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          createPullRequest(
            input: {title: "${param.pull_request_title}", repositoryId: "${step.pipeline.repository_get_by_full_name.repository_id}",
            baseRefName: "${param.base_branch}", headRefName: "${param.head_branch}", body: "${param.pull_request_body}"}
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
    value = jsondecode(step.http.pull_request_create.response_body).data.createPullRequest.pullRequest.id
  }
  output "pull_request_url" {
    value = jsondecode(step.http.pull_request_create.response_body).data.createPullRequest.pullRequest.url
  }
  output "response_body" {
    value = step.http.pull_request_create.response_body
  }
  output "response_headers" {
    value = step.http.pull_request_create.response_headers
  }
  output "status_code" {
    value = step.http.pull_request_create.status_code
  }

}
