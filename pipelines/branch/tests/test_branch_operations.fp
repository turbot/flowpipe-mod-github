pipeline "test_branch_operations" {
  title       = "Test Branch Operations"
  description = "Test the create_branch, get_branch, and delete_branch pipelines."

  tags = {
    type = "test"
  }

  param "cred" {
    type        = string
    description = local.cred_param_description
    default     = "default"
  }

  param "repository_owner" {
    type = string
  }

  param "repository_name" {
    type = string
  }

  param "branch_name" {
    type = string
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
    args     = step.transform.args.value
  }

  step "pipeline" "get_branch" {
    depends_on = [step.pipeline.create_branch]
    pipeline   = pipeline.get_branch
    args       = step.transform.args.value
  }

  step "pipeline" "delete_branch" {
    depends_on = [step.pipeline.get_branch]
    pipeline   = pipeline.delete_branch
    args       = step.transform.args.value
  }

  output "check_create_branch" {
    value      = step.pipeline.create_branch.output.branch.status_code == 201 ? "pass" : "fail"
  }

  output "check_get_branch" {
    value      = step.pipeline.get_branch.output.branch.status_code == 200 ? "pass" : "fail"
  }

  output "check_delete_branch" {
    value      = step.pipeline.delete_branch.output.branch.status_code == 204 ? "pass" : "fail"
  }

}