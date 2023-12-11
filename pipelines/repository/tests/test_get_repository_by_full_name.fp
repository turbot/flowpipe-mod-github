pipeline "test_get_repository_by_full_name" {
  title       = "Test Get Repository by Full Name"
  description = "Test the get_repository_by_full_name pipeline."

  tags = {
    type = "test"
  }

  param "cred" {
    type        = string
    description = local.cred_param_description
    default     = "default"
  }

  step "pipeline" "get_repository_by_full_name" {
    pipeline = pipeline.get_repository_by_full_name
    args = {
      cred = param.cred
    }
  }

  output "get_repository_by_full_name" {
    description = "Check for pipeline.get_repository_by_full_name."
    value       = !is_error(step.pipeline.get_repository_by_full_name) ? "pass" : "fail: ${step.pipeline.get_repository_by_full_name.error}"
  }
}
