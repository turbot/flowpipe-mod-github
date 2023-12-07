pipeline "test_get_repository_by_full_name" {
  title       = "Test Get Repository By Full Name"
  description = "Test the get_repository_by_full_name pipeline."

  tags = {
    type = "test"
  }

  step "pipeline" "get_repository_by_full_name" {
    pipeline = pipeline.get_repository_by_full_name
  }

  output "get_repository_by_full_name" {
    description = "Check for pipeline.get_repository_by_full_name."
    value       = !is_error(step.pipeline.get_repository_by_full_name) ? "pass" : "fail: ${step.pipeline.get_repository_by_full_name.error}"
  }
}
