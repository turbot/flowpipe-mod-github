// usage: flowpipe pipeline run issue_close --pipeline-arg issue_number=151
pipeline "issue_close" {
  description = "Close an Issue in a repository."

  param "github_token" {
    type    = string
    default = var.github_token
  }

  param "github_owner" {
    type    = string
    default = local.github_owner
  }

  param "github_repo" {
    type    = string
    default = local.github_repo
  }

  param "issue_number" {
    type = number
  }

  param "state_reason" {
    // type    = set(string) //TODO
    // default = ["COMPLETED", "NOT_PLANNED"]
    type = string
    default = "COMPLETED"
  }

  step "pipeline" "issue_get" {
    pipeline = pipeline.issue_get
    args = {
      github_token = param.github_token
      github_owner = param.github_owner
      github_repo  = param.github_repo
      issue_number = param.issue_number
    }
  }

  step "http" "issue_close" {
    title  = "Close an Issue in a repository."
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          closeIssue(
            input: {issueId: "${step.pipeline.issue_get.issue_id}", stateReason: ${param.state_reason}}
          ) {
            clientMutationId
            issue {
              id
              url
            }
          }
        }
        EOQ
    })
  }

  output "issue_url" {
    value = jsondecode(step.http.closeIssue.response_body).data.closeIssue.issue.url
  }
  output "issue_id" {
    value = jsondecode(step.http.closeIssue.response_body).data.closeIssue.issue.id
  }
  output "response_body" {
    value = step.http.issue_close.response_body
  }
  output "response_headers" {
    value = step.http.issue_close.response_headers
  }
  output "status_code" {
    value = step.http.issue_close.status_code
  }

}