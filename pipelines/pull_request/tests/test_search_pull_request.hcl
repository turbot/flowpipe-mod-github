pipeline "test_search_pull_request" {
  title       = "Test Pull Request List"
  description = "Tests the search_pull_request pipeline."

  param "search_value" {
    type    = string
    default = "test"
  }

  step "pipeline" "search_pull_request" {
    pipeline = pipeline.search_pull_request
    args = {
      search_value = param.search_value
    }
  }

  output "search_pull_request" {
    description = "Check for pipeline.search_pull_request."
    value       = step.pipeline.search_pull_request.pull_request_count > 0 ? "pass" : "fail: ${step.pipeline.search_pull_request.pull_request_count}"
  }
}
