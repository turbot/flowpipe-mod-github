// usage: flowpipe pipeline run issue_update --pipeline-arg 'issue_number=153' --pipeline-arg issue_title="[bug] - there is a bug" --pipeline-arg issue_body="please fix the bug" --pipeline-arg 'assignee_ids=["MDQ6VXNlcjQwOTczODYz", "MDQ6VXNlcjM4MjE4NDE4"]'
pipeline "issue_update" {
  description = "Update an issue's title, body, and assignees."

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

  param "issue_body" {
    type = string
  }

  param "issue_title" {
    type = string
  }

  param "assignee_ids" {
    type = list(string)
    // default = ["U_kgDOAnE2Jw"]
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

  step "http" "issue_update" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          updateIssue(
            input: {id: "${step.pipeline.issue_get_by_number.issue_id}", body: "${param.issue_body}", title: "${param.issue_title}", assigneeIds: ${jsonencode(param.assignee_ids)}}
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
    value = jsondecode(step.http.issue_update.response_body).data.updateIssue.issue.url
  }
  output "issue_id" {
    value = jsondecode(step.http.issue_update.response_body).data.updateIssue.issue.id
  }
  output "response_body" {
    value = step.http.issue_update.response_body
  }
  output "response_headers" {
    value = step.http.issue_update.response_headers
  }
  output "status_code" {
    value = step.http.issue_update.status_code
  }

}
