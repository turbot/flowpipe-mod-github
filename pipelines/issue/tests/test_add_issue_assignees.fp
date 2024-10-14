pipeline "test_add_issue_assignees" {
  title       = "Test Add Issue Assignees"
  description = "Test the add_issue_assignees pipeline."

  tags = {
    type = "test"
  }

  param "conn" {
    type        = connection.github
    description = local.conn_param_description
    default     = connection.github.default
  }

  param "issue_number" {
    type        = number
    default     = 53
    description = "The number of the issue."
  }

  param "assignee_ids" {
    type    = list(string)
    default = ["MDQ6VXNlcjQwOTczODYz", "MDQ6VXNlcjM4MjE4NDE4"]
  }

  step "pipeline" "add_issue_assignees" {
    pipeline = pipeline.add_issue_assignees
    args = {
      assignee_ids     = param.assignee_ids
      conn             = param.conn
      issue_number     = param.issue_number
      repository_name  = "deleteme"
      repository_owner = "vkumbha"
    }
  }

  output "add_issue_assignees" {
    description = "Check for pipeline.add_issue_assignees."
    value       = !is_error(step.pipeline.add_issue_assignees) ? "pass" : "fail: ${step.pipeline.add_issue_assignees.errors}"
  }

}
