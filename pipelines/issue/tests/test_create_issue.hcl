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
      issue_number     = tonumber(regex("https://github.com/.*/issues/([0-9]+)", step.pipeline.create_issue.issue_url)[0])
    }

    # Ignore errors so we can delete
    error {
      ignore = true
    }
  }

  step "pipeline" "close_issue" {
    if = step.pipeline.create_issue.status_code == 200
    # Don't run before we've had a chance to get the issue
    depends_on = [step.pipeline.get_issue_by_number]

    pipeline = pipeline.close_issue
    args = {
      issue_number = tonumber(regex("https://github.com/.*/issues/([0-9]+)", step.pipeline.create_issue.issue_url)[0])
    }
  }

  output "created_issue" {
    description = "Created issue."
    value       = step.pipeline.create_issue.issue_url
  }

  output "create_issue" {
    description = "Check for pipeline.create_issue."
    value       = step.pipeline.create_issue.status_code == 200 ? "pass" : "fail: ${step.pipeline.create_issue.status_code}"
  }

  output "get_issue_by_number" {
    description = "Check for pipeline.get_issue_by_number."
    value       = step.pipeline.get_issue_by_number.status_code == 200 ? "pass" : "fail: ${step.pipeline.get_issue_by_number.status_code}"
  }

  output "close_issue" {
    description = "Check for pipeline.close_issue."
    value       = step.pipeline.close_issue.status_code == 200 ? "pass" : "fail: ${step.pipeline.create_issue.status_code}"
  }

}
