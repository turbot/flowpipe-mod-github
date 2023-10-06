// usage: flowpipe pipeline run pull_request_create --pipeline-arg "title=new PR title" --pipeline-arg "body=pr body" --pipeline-arg "base_branch=main" --pipeline-arg "head_branch=demo-branch"
pipeline "pull_request_create" {
  description = "Create a Pull request."

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

  param "title" {
    type = string
  }

  param "body" {
    type = string
  }

  param "base_branch" {
    type = string
  }

  param "head_branch" {
    type = string
  }

  step "pipeline" "repository_get" {
    pipeline = pipeline.repository_get
    args = {
      github_token = var.github_token
      github_owner = param.github_owner
      github_repo  = param.github_repo
    }
  }

  step "http" "pull_request_create" {
    title  = "Create Pull Request"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          createPullRequest(
            input: {title: "${param.title}", repositoryId: "${step.pipeline.repository_get.repository_id}", 
            baseRefName: "${param.base_branch}", headRefName: "${param.head_branch}", body: "${param.body}"}
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
