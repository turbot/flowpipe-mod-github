pipeline "test_get_repository_owner" {
  title       = "Test Get Repository Owner"
  description = "Tests the get_repository_owner pipeline."

  step "pipeline" "get_repository_owner" {
    pipeline = pipeline.get_repository_owner
  }

  output "get_repository_owner" {
    description = "Check for pipeline.get_repository_owner."
    value       = step.pipeline.get_repository_owner.status_code == 200 ? "pass" : "fail: ${step.pipeline.get_repository_owner.status_code}"
  }
}
