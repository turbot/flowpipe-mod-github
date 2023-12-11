pipeline "test_get_repository_owner" {
  title       = "Test Get Repository Owner"
  description = "Test the get_repository_owner pipeline."

  tags = {
    type = "test"
  }

  param "cred" {
    type        = string
    description = local.cred_param_description
    default     = "default"
  }

  step "pipeline" "get_repository_owner" {
    pipeline = pipeline.get_repository_owner
    args = {
      cred = param.cred
    }
  }

  output "get_repository_owner" {
    description = "Check for pipeline.get_repository_owner."
    value       = !is_error(step.pipeline.get_repository_owner) ? "pass" : "fail: ${step.pipeline.get_repository_owner.error}"
  }
}
