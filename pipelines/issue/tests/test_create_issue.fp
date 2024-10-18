pipeline "test_create_issue" {
  title       = "Test Create Issue"
  description = "Test the create issue pipeline."

  tags = {
    folder = "Tests"
  }

  param "conn" {
    type        = connection.github
    description = local.conn_param_description
    default     = connection.github.default
  }

  param "issue_title" {
    type    = string
    default = "Test Issue"
  }

  param "issue_body" {
    type    = string
    default = "This is a test issue."
  }

  step "pipeline" "create_issue" {
    pipeline = pipeline.create_issue
    args = {
      conn             = param.conn
      issue_body       = param.issue_body
      issue_title      = param.issue_title
      repository_name  = "deleteme"
      repository_owner = "vkumbha"
    }
  }

  step "pipeline" "get_issue_by_number" {
    if       = !is_error(step.pipeline.create_issue)
    pipeline = pipeline.get_issue_by_number
    args = {
      conn             = param.conn
      issue_number     = step.pipeline.create_issue.output.issue.number
      repository_name  = "deleteme"
      repository_owner = "vkumbha"
    }

    # Ignore errors so we can delete
    error {
      ignore = true
    }
  }

  step "pipeline" "close_issue" {
    if = !is_error(step.pipeline.create_issue)
    # Don't run before we've had a chance to get the issue
    depends_on = [step.pipeline.get_issue_by_number]

    pipeline = pipeline.close_issue
    args = {
      conn             = param.conn
      issue_number     = step.pipeline.create_issue.output.issue.number
      repository_name  = "deleteme"
      repository_owner = "vkumbha"
    }
  }

  output "created_issue" {
    description = "Created issue."
    value       = step.pipeline.create_issue.output.issue
  }

  output "create_issue" {
    description = "Check for pipeline.create_issue."
    value       = !is_error(step.pipeline.create_issue) ? "pass" : "fail: ${step.pipeline.create_issue.errors}"
  }

  output "get_issue_by_number" {
    description = "Check for pipeline.get_issue_by_number."
    value       = !is_error(step.pipeline.get_issue_by_number) ? "pass" : "fail: ${step.pipeline.get_issue_by_number.errors}"
  }

  output "close_issue" {
    description = "Check for pipeline.close_issue."
    value       = !is_error(step.pipeline.close_issue) ? "pass" : "fail: ${step.pipeline.close_issue.errors}"
  }

}
