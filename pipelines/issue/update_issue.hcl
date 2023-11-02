// usage: flowpipe pipeline run update_issue --pipeline-arg 'issue_number=153' --pipeline-arg issue_title="[bug] - there is a bug" --pipeline-arg issue_body="please fix the bug" --pipeline-arg 'assignee_ids=["MDQ6VXNlcjQwOTczODYz", "MDQ6VXNlcjM4MjE4NDE4"]'
pipeline "update_issue" {
  title = "Update Issue"
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

  step "pipeline" "get_issue_by_number" {
    pipeline = pipeline.get_issue_by_number
    args = {
      token = param.token
      repository_owner = param.repository_owner
      repository_name  = param.repository_name
      issue_number = param.issue_number
    }
  }

  step "http" "update_issue" {
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
            input: {id: "${step.pipeline.get_issue_by_number.issue_id}", body: "${param.issue_body}", title: "${param.issue_title}", assigneeIds: ${jsonencode(param.assignee_ids)}}
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

  output "issue" {
    value = step.http.update_issue.response_body.data.updateIssue.issue
  }

}
