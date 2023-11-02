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

  output "list_issue" {
    description = "Check for pipeline.list_issue."
    value       = !is_error(step.pipeline.list_issue) ? "pass" : "fail: ${step.pipeline.list_issue.errors}"
  }

}
