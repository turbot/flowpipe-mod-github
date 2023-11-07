pipeline "test_search_repositories" {
  title       = "Test Search Repositories"
  description = "Tests the search_repositories pipeline."

  param "search_value" {
    type        = "string"
    default     = "test"
  }

  step "pipeline" "search_repositories" {
    pipeline = pipeline.search_repositories
    args     = {
      search_value = param.search_value
    }
  }

  output "search_repositories" {
    description = "Check for pipeline.search_repositories."
    value       = !is_error(step.pipeline.search_repositories) ? "pass" : "fail: ${step.pipeline.search_repositories.errors}"
  }
}
