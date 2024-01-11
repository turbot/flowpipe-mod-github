pipeline "exists_branch" {
  title       = "Exists Branch"
  description = "Checks if a branch exists in a specified repository."

  param "cred" {
    type        = string
    default     = "default"
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
    description = "The name of the branch to check."
  }

  step "http" "check_branch" {
    method = "get"
    url    = "https://api.github.com/repos/${param.repository_owner}/${param.repository_name}/branches/${param.branch_name}"
    request_headers = {
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }
    error {
        ignore = true
    }
  }

  output "branch_exists" {
    value       = step.http.check_branch.status_code == 200
  }
  
}