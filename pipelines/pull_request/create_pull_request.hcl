// usage: flowpipe pipeline run create_pull_request --pipeline-arg "pull_request_title=new PR title" --pipeline-arg "pull_request_body=pr body" --pipeline-arg "base_branch=main" --pipeline-arg "head_branch=demo-branch"
pipeline "create_pull_request" {
  title       = "Create Pull Request"
  description = "Creates a pull request."

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

  step "pipeline" "get_repository_by_full_name" {
    pipeline = pipeline.get_repository_by_full_name
    args = {
      token = var.token
      repository_owner = param.repository_owner
      repository_name  = param.repository_name
    }
  }

  step "http" "create_pull_request" {
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
            input: {title: "${param.pull_request_title}", repositoryId: "${step.pipeline.get_repository_by_full_name.repository.id}",
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

  output "pull_request" {
    value = step.http.create_pull_request.response_body.data.createPullRequest.pullRequest
  }

}
