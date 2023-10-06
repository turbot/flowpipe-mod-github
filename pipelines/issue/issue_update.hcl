// usage: flowpipe pipeline run issue_update --pipeline-arg 'issue_number=153' --pipeline-arg title="[bug] - there is a bug" --pipeline-arg body="please fix the bug" --pipeline-arg 'assignee_ids=["MDQ6VXNlcjQwOTczODYz", "MDQ6VXNlcjM4MjE4NDE4"]'
pipeline "issue_update" {
  description = "Update an Issue in a repository."

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

  param "body" {
    type = string
  }

  param "title" {
    type = string
  }

  param "assignee_ids" {
    type = list(string)
    // default = ["U_kgDOAnE2Jw"]
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

  step "http" "issue_update" {
    title  = "Update an Issue in a repository."
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          updateIssue(
            input: {id: "${step.pipeline.issue_get.issue_id}", body: "${param.body}", title: "${param.title}", assigneeIds: ${jsonencode(param.assignee_ids)}}
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
