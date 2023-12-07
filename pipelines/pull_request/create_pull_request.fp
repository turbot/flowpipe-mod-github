# usage: flowpipe pipeline run create_pull_request --arg "pull_request_title=new PR title" --arg "pull_request_body=pr body" --arg "base_branch=main" --arg "head_branch=demo-branch"
pipeline "create_pull_request" {
  title       = "Create Pull Request"
  description = "Creates a pull request."

  tags = {
    type = "featured"
  }

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

  param "pull_request_title" {
    type        = string
    description = "The title of the pull request."
  }

  param "pull_request_body" {
    type        = string
    description = "The contents of the pull request."
  }

  param "base_branch" {
    type        = string
    description = "The name of the branch you want your changes pulled into. This should be an existing branch on the current repository. You cannot update the base branch on a pull request to point to another repository."
  }

  param "head_branch" {
    type        = string
    description = "The name of the branch where your changes are implemented. For cross-repository pull requests in the same network, namespace head_ref_name with a user like this: username:branch."
  }

  step "pipeline" "get_repository_by_full_name" {
    pipeline = pipeline.get_repository_by_full_name
    args = {
      cred             = param.cred
      repository_owner = param.repository_owner
      repository_name  = param.repository_name
    }
  }

  step "http" "create_pull_request" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          createPullRequest(
            input: {title: "${param.pull_request_title}", repositoryId: "${step.pipeline.get_repository_by_full_name.output.repository.id}",
            baseRefName: "${param.base_branch}", headRefName: "${param.head_branch}", body: "${param.pull_request_body}"}
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
      if      = can(result.response_body.errors[0].message)
      message = result.response_body.errors[0].message
    }
  }

  output "pull_request" {
    description = "Pull request details."
    value       = step.http.create_pull_request.response_body.data.createPullRequest.pullRequest
  }

}
