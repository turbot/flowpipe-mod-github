pipeline "test_list_pull_requests" {
  title       = "Test List Pull Requests"
  description = "Test the list_pull_requests pipeline."

  tags = {
    type = "test"
  }

  param "cred" {
    type        = string
    description = local.cred_param_description
    default     = "default"
  }

  step "pipeline" "list_pull_requests" {
    pipeline = pipeline.list_pull_requests
    args = {
      cred             = param.cred
      repository_name  = "flowpipe"
      repository_owner = "turbot"
    }
  }

  output "list_pull_requests" {
    description = "Check for pipeline.list_pull_requests."
    value       = !is_error(step.pipeline.list_pull_requests) ? "pass" : "fail: ${step.pipeline.list_pull_requests.errors}"
  }
}