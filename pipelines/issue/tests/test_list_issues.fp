pipeline "test_list_issues" {
  title       = "Test List Issues"
  description = "Test the list_issues pipeline."

  tags = {
    folder = "Tests"
  }

  param "conn" {
    type        = connection.github
    description = local.conn_param_description
    default     = connection.github.default
  }

  step "pipeline" "list_issues" {
    pipeline = pipeline.list_issues
    args = {
      conn             = param.conn
      repository_name  = "flowpipe"
      repository_owner = "turbot"
    }
  }

  output "list_issues" {
    description = "Check for pipeline.list_issues."
    value       = !is_error(step.pipeline.list_issues) ? "pass" : "fail: ${step.pipeline.list_issues.errors}"
  }

}
