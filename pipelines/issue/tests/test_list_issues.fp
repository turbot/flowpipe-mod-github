pipeline "test_list_issues" {
  title       = "Test List Issues"
  description = "Test the list_issues pipeline."

  param "access_token" {
    type        = string
    description = local.access_token_param_description
    default     = var.access_token
  }

  step "pipeline" "list_issues" {
    pipeline = pipeline.list_issues
    args = {
      access_token = param.access_token
    }
  }

  output "list_issues" {
    description = "Check for pipeline.list_issues."
    value       = !is_error(step.pipeline.list_issues) ? "pass" : "fail: ${step.pipeline.list_issues.errors}"
  }

}
