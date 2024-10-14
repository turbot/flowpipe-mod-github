pipeline "test_get_repository_owner" {
  title       = "Test Get Repository Owner"
  description = "Test the get_repository_owner pipeline."

  tags = {
    type = "test"
  }

  param "conn" {
    type        = connection.github
    description = local.conn_param_description
    default     = connection.github.default
  }

  step "pipeline" "get_repository_owner" {
    pipeline = pipeline.get_repository_owner
    args = {
      conn             = param.conn
      repository_owner = "turbot"
    }
  }

  output "get_repository_owner" {
    description = "Check for pipeline.get_repository_owner."
    value       = !is_error(step.pipeline.get_repository_owner) ? "pass" : "fail: ${step.pipeline.get_repository_owner.error}"
  }
}
