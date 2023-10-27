pipeline "test_create_issue" {
  title       = "Test Create Issue"
  description = "Test the create issue pipeline."

  param "token" {
    type    = string
    default = var.token
  }

  param "issue_title" {
    type = string
    default = "Test Issue"
  }

  param "issue_body" {
    type = string
    default = "This is a test issue."
  }

  param "repository_owner" {
    type    = string
    default = local.repository_owner
  }

  param "repository_name" {
    type    = string
    default = local.repository_name
  }

  param "issue_number" {
    type = number
  }

  step "pipeline" "create_issue" {
    pipeline = pipeline.create_issue
    args = {
      token       = param.token
      issue_title = param.issue_title
      issue_body  = param.issue_body
    }
  }

  step "pipeline" "get_issue_by_number" {
    if = step.pipeline.create_issue.status_code == 200
    pipeline = pipeline.get_issue_by_number
    args = {
      repository_owner = param.repository_owner
      repository_name  = param.repository_name
      issue_number     = param.issue_number
    }

    # Ignore errors so we can delete
    error {
      ignore = true
    }
  }

  // step "pipeline" "delete_issue" {
  //   if = step.pipeline.create_issue.stderr == ""
  //   # Don't run before we've had a chance to describe the instance
  //   depends_on = [step.pipeline.get_issue_by_number]

  //   pipeline = pipeline.delete_issue
  //   args = {
  //       repository_owner = param.repository_owner
  //       repository_name  = param.repository_name
  //       issue_number     = param.issue_number
  //   }
  // }

  output "create_issue" {
    description = "Check for pipeline.create_issue."
    value       = step.pipeline.create_issue.status_code == 200 ? "succeeded" : "failed: ${step.pipeline.create_issue.status_code}"
  }

  // output "get_issue_by_number" {
  //   description = "Check for pipeline.get_issue_by_number."
  //   value       = step.pipeline.get_issue_by_number.stderr == "" ? "succeeded" : "failed: ${step.pipeline.get_issue_by_number.stderr}"
  // }

  // output "delete_issue" {
  //   description = "Check for pipeline.delete_issue."
  //   value       = step.pipeline.delete_issue.stderr == "" ? "succeeded" : "failed: ${step.pipeline.create_issue.stderr}"
  // }

}
