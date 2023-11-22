pipeline "test_add_issue_assignees" {
  title       = "Test Add Issue Assignees"
  description = "Test the add_issue_assignees pipeline."

  param "access_token" {
    type        = string
    description = local.access_token_param_description
    default     = var.access_token
  }

  param "issue_number" {
    type        = number
    default     = 1
    description = "The number of the issue."
  }

  param "assignee_ids" {
    type    = list(string)
    default = ["MDQ6VXNlcjQwOTczODYz", "MDQ6VXNlcjM4MjE4NDE4"]
  }

  step "pipeline" "add_issue_assignees" {
    pipeline = pipeline.add_issue_assignees
    args = {
      access_token = param.access_token
      issue_number = param.issue_number
      assignee_ids = param.assignee_ids
    }
  }

  output "add_issue_assignees" {
    description = "Check for pipeline.add_issue_assignees."
    value       = !is_error(step.pipeline.add_issue_assignees) ? "pass" : "fail: ${step.pipeline.add_issue_assignees.errors}"
  }

}
