pipeline "create_branch" {
  title       = "Create Branch"
  description = "Creates a new branch in a specified repository."

  param "cred" {
    type        = string
    default     = "default"
    description = local.cred_param_description
  }

  param "repository_owner" {
    type        = string
    description = local.repository_owner_param_description
  }

  param "repository_name" {
    type        = string
    description = local.repository_name_param_description
  }

  param "branch_name" {
    type        = string
    description = "The name of the new branch."
  }

  param "source_branch" {
    type        = string
    description = "The name of the source branch to branch off. Defaults to the default branch of the repository."
    default     = "main"
  }

  step "http" "get_latest_commit_sha" {
    method = "get"
    url    = "https://api.github.com/repos/${param.repository_owner}/${param.repository_name}/branches/${param.source_branch}"
    request_headers = {
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }
  }

  step "http" "create_branch" {
    method = "post"
    url    = "https://api.github.com/repos/${param.repository_owner}/${param.repository_name}/git/refs"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }

    request_body = jsonencode({
      ref = "refs/heads/${param.branch_name}",
      sha = "${step.http.get_latest_commit_sha.response_body.commit.sha}"
    })

    throw {
      if      = can(result.response_body.errors)
      message = join(", ", flatten([for error in result.response_body.errors : error.message]))
    }
  }

  output "branch" {
    value = step.http.create_branch
  }

}
