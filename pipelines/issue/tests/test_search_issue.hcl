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

  output "issues_count" {
    description = "Count of issues found."
    value       = step.pipeline.search_issue.issues_count
  }

  output "search_issue" {
    description = "Check for pipeline.search_issue."
    value       = step.pipeline.search_issue.issues_count != null ? "pass" : "fail: ${step.pipeline.search_issue.status_code}"
  }

}
