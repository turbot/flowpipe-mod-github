pipeline "test_get_repository_by_full_name" {
  title       = "Test Get Repository by Full Name"
  description = "Test the get_repository_by_full_name pipeline."

  tags = {
    folder = "Tests"
  }

  param "conn" {
    type        = connection.github
    description = local.conn_param_description
    default     = connection.github.default
  }

  step "pipeline" "get_repository_by_full_name" {
    pipeline = pipeline.get_repository_by_full_name
    args = {
      conn             = param.conn
      repository_name  = "flowpipe"
      repository_owner = "turbot"
    }
  }

  output "get_repository_by_full_name" {
    description = "Check for pipeline.get_repository_by_full_name."
    value       = !is_error(step.pipeline.get_repository_by_full_name) ? "pass" : "fail: ${step.pipeline.get_repository_by_full_name.error}"
  }
}
