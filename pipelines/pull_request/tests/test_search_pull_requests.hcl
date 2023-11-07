pipeline "test_search_pull_requests" {
  title       = "Test Search Pull Requests"
  description = "Tests the search_pull_requests pipeline."

  param "search_value" {
    type    = string
    default = "test"
  }

  step "pipeline" "search_pull_requests" {
    pipeline = pipeline.search_pull_requests
    args = {
      search_value = param.search_value
    }
  }

  output "search_pull_requests" {
    description = "Check for pipeline.search_pull_requests."
    value       = !is_error(step.pipeline.search_pull_requests) ? "pass" : "fail: ${step.pipeline.search_pull_requests.errors}"
  }
}
