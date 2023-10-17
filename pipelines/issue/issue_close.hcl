// usage: flowpipe pipeline run issue_close --pipeline-arg issue_number=151
pipeline "issue_close" {
  description = "Close an issue with the given ID."

  param "token" {
    type    = string
    default = var.token
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

  param "state_reason" {
    // type    = set(string) //TODO
    // default = ["COMPLETED", "NOT_PLANNED"]
    type = string
    default = "COMPLETED"
  }

  step "pipeline" "issue_get_by_number" {
    pipeline = pipeline.issue_get_by_number

    args = {
      token = param.token
      repository_owner = param.repository_owner
      repository_name  = param.repository_name
      issue_number = param.issue_number
    }
  }

  step "http" "issue_close" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          closeIssue(
            input: {issueId: "${step.pipeline.issue_get_by_number.issue_id}", stateReason: ${param.state_reason}}
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
    value = jsondecode(step.http.issue_close.response_body).data.closeIssue.issue.url
  }
  output "issue_id" {
    value = jsondecode(step.http.issue_close.response_body).data.closeIssue.issue.id
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
