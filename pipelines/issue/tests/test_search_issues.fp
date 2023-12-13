pipeline "test_search_issues" {
  title       = "Test Search Issues"
  description = "Test the search_issues pipeline."

  tags = {
    type = "test"
  }

  param "cred" {
    type        = string
    description = local.cred_param_description
    default     = "default"
  }

  param "search_value" {
    type    = string
    default = "CLI"
  }

  step "pipeline" "search_issues" {
    pipeline = pipeline.search_issues
    args = {
      cred             = param.cred
      search_value     = param.search_value
      repository_name  = "flowpipe"
      repository_owner = "turbot"
    }
  }

  output "search_issues" {
    description = "Check for pipeline.search_issues."
    value       = !is_error(step.pipeline.search_issues) ? "pass" : "fail: ${step.pipeline.search_issues.errors}"
  }

}
