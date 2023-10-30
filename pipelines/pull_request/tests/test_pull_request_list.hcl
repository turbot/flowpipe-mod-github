pipeline "test_pull_request_list" {
  title       = "Test Pull Request List"
  description = "Tests the pull_request_list pipeline."

  step "pipeline" "pull_request_list" {
    pipeline = pipeline.pull_request_list
  }

  output "pull_request_list" {
    description = "Check for pipeline.pull_request_list."
    value       = step.pipeline.pull_request_list.pull_request_count > 0 ? "pass" : "fail: ${step.pipeline.pull_request_list.pull_request_count}"
  }
}
