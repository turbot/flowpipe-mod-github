pipeline "test_search_issue" {
  title       = "Test Search Issue"
  description = "Test the search issue pipeline."

  param "token" {
    type    = string
    default = var.token
  }

  param "search_value" {
    type    = string
    default = "test"
  }

  step "pipeline" "search_issue" {
    pipeline = pipeline.search_issue
    args = {
      token = param.token
      search_value = param.search_value
    }
  }

  output "search_issue" {
    description = "Check for pipeline.search_issue."
    value       = !is_error(step.pipeline.search_issue) ? "pass" : "fail: ${step.pipeline.search_issue.errors}"
  }

}
