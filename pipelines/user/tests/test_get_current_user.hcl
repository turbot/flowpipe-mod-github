pipeline "test_get_current_user" {
  title       = "Test Get Current User"
  description = "Test the get_current_user pipeline."

  param "access_token" {
    type        = string
    description = local.access_token_param_description
    default     = var.access_token
  }

  step "pipeline" "get_current_user" {
    pipeline = pipeline.get_current_user
    args = {
      access_token = param.access_token
    }
  }

  output "returned_current_user" {
    description = "The current user returned by the pipeline."
    value       = step.pipeline.get_current_user.output.user
  }

  output "get_current_user" {
    description = "Check for pipeline.get_current_user."
    value       = !is_error(step.pipeline.get_current_user) ? "pass" : "fail: ${step.pipeline.get_current_user.errors}"
  }

}
