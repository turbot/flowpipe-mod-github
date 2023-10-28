pipeline "test_list_issue" {
  title       = "Test List Issue"
  description = "Test the list issue pipeline."

  param "token" {
    type    = string
    default = var.token
  }

  step "pipeline" "list_issue" {
    pipeline = pipeline.list_issue
    args = {
      token = param.token
    }
  }

  output "total_count" {
    description = "Total count of issues."
    value       = step.pipeline.list_issue.total_count
  }

  output "list_issue" {
    description = "Check for pipeline.list_issue."
    value       = step.pipeline.list_issue.total_count != null ? "pass" : "fail: ${step.pipeline.list_issue.status_code}"
  }

}
