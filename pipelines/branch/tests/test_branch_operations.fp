pipeline "test_branch_operations" {
  title       = "Test Branch Operations"
  description = "Test the create_branch, exists_branch, and delete_branch pipelines."

  tags = {
    type = "test"
  }

  param "cred" {
    type        = string
    description = local.cred_param_description
    default     = "default"
  }

  param "repository_owner" {
    type    = string
  }

  param "repository_name" {
    type    = string
  }

  param "branch_name" {
    type    = string
  }

  step "transform" "args" {
    value = {
      cred             = param.cred
      repository_owner = param.repository_owner
      repository_name  = param.repository_name
      branch_name      = param.branch_name
    }
  }

  step "pipeline" "create_branch" {
    pipeline = pipeline.create_branch
    args = step.transform.args.value
  }

  step "pipeline" "exists_branch_after_creation" {
    pipeline = pipeline.exists_branch
    depends_on = [step.pipeline.create_branch]
    args = step.transform.args.value
  }

  step "pipeline" "delete_branch" {
    depends_on = [step.pipeline.exists_branch_after_creation]
    pipeline = pipeline.delete_branch
    args = step.transform.args.value
  }

  step "pipeline" "exists_branch_after_deletion" {
    depends_on = [step.pipeline.delete_branch]
    pipeline = pipeline.exists_branch
    args = step.transform.args.value
  }

  output "branch_created" {
    description = "Check for pipeline.create_branch."
    value       = step.pipeline.exists_branch_after_creation.output.branch_exists ? "pass" : "fail"
  }

  output "branch_deleted" {
    description = "Check for pipeline.delete_branch."
    value       = !step.pipeline.exists_branch_after_deletion.output.branch_exists ? "pass" : "fail"
  }

}