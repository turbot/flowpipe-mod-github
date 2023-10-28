pipeline "test_get_user_by_login" {
  title       = "Test Get User By Login"
  description = "Tests the get_user_by_login pipeline."

  param "token" {
    type    = string
    default = var.token
  }

  param "user_login" {
    type = string
    default = "turbot"
  }

  step "pipeline" "get_user_by_login" {
    pipeline = pipeline.get_user_by_login
    args = {
      token = param.token
      user_login = param.user_login
    }
  }

  output "returned_user_id" {
    description = "The current user returned by the pipeline."
    value       = step.pipeline.get_user_by_login.user_id
  }

  output "get_user_by_login" {
    description = "Check for pipeline.get_user_by_login."
    value       = step.pipeline.get_user_by_login.user_id != "" ? "pass" : "fail: ${step.pipeline.get_user_by_login.status_code}"
  }

}
