pipeline "test_add_issue_assignees" {
  title       = "Test Add Issue Assignees"
  description = "Test the add_issue_assignees pipeline."

  param "token" {
    type    = string
    default = var.token
  }

  param "issue_number" {
    type = number
    default = 1
  }

  param "assignee_ids" {
    type = list(string)
    default = ["MDQ6VXNlcjQwOTczODYz", "MDQ6VXNlcjM4MjE4NDE4"]
  }

  step "pipeline" "add_issue_assignees" {
    pipeline = pipeline.add_issue_assignees
    args = {
      token = param.token
      issue_number = param.issue_number
      assignee_ids = param.assignee_ids
    }
  }

  output "add_issue_assignees" {
    description = "Check for pipeline.add_issue_assignees."
    value       = step.pipeline.add_issue_assignees.status_code == 200 ? "pass" : "fail: ${step.pipeline.add_issue_assignees.status_code}"
  }

}
