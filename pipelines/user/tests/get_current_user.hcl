pipeline "test_get_current_user" {
  title       = "Test Get Current User"
  description = "Tests the get_current_user pipeline."

  param "token" {
    type    = string
    default = var.token
  }

  step "pipeline" "get_current_user" {
    pipeline = pipeline.get_current_user
    args = {
      token = param.token
    }
  }

  output "returned_current_user" {
    description = "The current user returned by the pipeline."
    value       = step.pipeline.get_current_user.user_id
  }

  output "get_current_user" {
    description = "Check for pipeline.get_current_user."
    value       = step.pipeline.get_current_user.user_id != "" ? "pass" : "fail: ${step.pipeline.get_current_user.status_code}"
  }

}
