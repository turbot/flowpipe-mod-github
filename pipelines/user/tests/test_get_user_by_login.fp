pipeline "test_get_user_by_login" {
  title       = "Test Get User By Login"
  description = "Test the get_user_by_login pipeline."

  param "cred" {
    type        = string
    description = local.cred_param_description
    default     = "default"
  }

  param "user_login" {
    type    = string
    default = "luisffc"
  }

  step "pipeline" "get_user_by_login" {
    pipeline = pipeline.get_user_by_login
    args = {
      cred       = param.cred
      user_login = param.user_login
    }
  }

  output "returned_user" {
    description = "The current user returned by the pipeline."
    value       = step.pipeline.get_user_by_login.output.user
  }

  output "get_user_by_login" {
    description = "Check for pipeline.get_user_by_login."
    value       = !is_error(step.pipeline.get_user_by_login) ? "pass" : "fail: ${step.pipeline.get_user_by_login.errors}"
  }

}
