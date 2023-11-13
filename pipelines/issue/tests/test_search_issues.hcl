pipeline "test_search_issues" {
  title       = "Test Search Issues"
  description = "Test the search_issues pipeline."

  param "access_token" {
    type        = string
    description = local.access_token_param_description
    default     = var.access_token
  }

  param "search_value" {
    type    = string
    default = "test"
  }

  step "pipeline" "search_issues" {
    pipeline = pipeline.search_issues
    args = {
      access_token = param.access_token
      search_value = param.search_value
    }
  }

  output "search_issues" {
    description = "Check for pipeline.search_issues."
    value       = !is_error(step.pipeline.search_issues) ? "pass" : "fail: ${step.pipeline.search_issues.errors}"
  }

}
