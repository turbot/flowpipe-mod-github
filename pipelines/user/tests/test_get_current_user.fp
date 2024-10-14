pipeline "test_get_current_user" {
  title       = "Test Get Current User"
  description = "Test the get_current_user pipeline."

  tags = {
    type = "test"
  }

  param "conn" {
    type        = connection.github
    description = local.conn_param_description
    default     = connection.github.default
  }

  step "pipeline" "get_current_user" {
    pipeline = pipeline.get_current_user
    args = {
      conn = param.conn
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
