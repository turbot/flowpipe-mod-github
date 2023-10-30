pipeline "test_search_repository" {
  title       = "Test Search Repository"
  description = "Tests the search_repository pipeline."

  param "search_value" {
    type        = "string"
    default     = "test"
  }

  step "pipeline" "search_repository" {
    pipeline = pipeline.search_repository
    args     = {
      search_value = param.search_value
    }
  }

  output "search_repository" {
    description = "Check for pipeline.search_repository."
    value       = step.pipeline.search_repository.repository_count > 0 ? "pass" : "fail: ${step.pipeline.search_repository.repository_count}"
  }
}
