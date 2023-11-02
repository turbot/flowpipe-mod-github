pipeline "test_pull_request_list" {
  title       = "Test Pull Request List"
  description = "Tests the pull_request_list pipeline."

  step "pipeline" "pull_request_list" {
    pipeline = pipeline.pull_request_list
  }

  output "pull_request_list" {
    description = "Check for pipeline.pull_request_list."
    value       = !is_error(step.pipeline.pull_request_list) ? "pass" : "fail: ${step.pipeline.pull_request_list.errors}"
  }
}
