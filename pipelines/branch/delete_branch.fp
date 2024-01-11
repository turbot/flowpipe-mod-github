pipeline "delete_branch" {
  title       = "Delete Branch"
  description = "Deletes a branch in a specified repository."

  param "cred" {
    type    = string
    default = "default"
    description = local.cred_param_description    
  }

  param "repository_owner" {
    type = string
    description = local.repository_owner_param_description    
  }

  param "repository_name" {
    type = string
    description = local.repository_name_param_description    
  }

  param "branch_name" {
    type        = string
    description = "The name of the branch to delete."
  }

  step "http" "delete_branch" {
    method = "delete"
    url    = "https://api.github.com/repos/${param.repository_owner}/${param.repository_name}/git/refs/heads/${param.branch_name}"
    request_headers = {
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }

    throw {
      if      = can(result.response_body.errors)
      message = join(", ", flatten([for error in result.response_body.errors : error.message]))
    }
  }

  output "branch_deleted" {
    value = param.branch_name
  }
}