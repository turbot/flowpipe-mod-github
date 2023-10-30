pipeline "test_get_repository_by_full_name" {
  title       = "Test Get Repository By Full Name"
  description = "Tests the get_repository_by_full_name pipeline."

  step "pipeline" "get_repository_by_full_name" {
    pipeline = pipeline.get_repository_by_full_name
  }

  output "get_repository_by_full_name" {
    description = "Check for pipeline.get_repository_by_full_name."
    value       = step.pipeline.get_repository_by_full_name.status_code == 200 ? "pass" : "fail: ${step.pipeline.get_repository_by_full_name.status_code}"
  }
}
