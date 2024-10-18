pipeline "test_search_pull_requests" {
  title       = "Test Search Pull Requests"
  description = "Test the search_pull_requests pipeline."

  tags = {
    folder = "Tests"
  }

  param "conn" {
    type        = connection.github
    description = local.conn_param_description
    default     = connection.github.default
  }

  param "search_value" {
    type    = string
    default = "test"
  }

  step "pipeline" "search_pull_requests" {
    pipeline = pipeline.search_pull_requests
    args = {
      cred             = param.cred
      repository_name  = "flowpipe"
      repository_owner = "turbot"
      search_value     = param.search_value
    }
  }

  output "search_pull_requests" {
    description = "Check for pipeline.search_pull_requests."
    value       = !is_error(step.pipeline.search_pull_requests) ? "pass" : "fail: ${step.pipeline.search_pull_requests.errors}"
  }
}
