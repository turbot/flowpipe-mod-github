// usage: flowpipe pipeline run issue_add_assignee  --pipeline-arg "issue_number=151" --pipeline-arg 'assignee_ids=["MDQ6VXNlcjQwOTczODYz", "MDQ6VXNlcjM4MjE4NDE4"]'
pipeline "issue_add_assignees" {
  description = "Add assignees to an issue."

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

  param "assignee_ids" {
    type = list(string)
  }

  step "pipeline" "issue_get_by_number" {
    pipeline = pipeline.issue_get_by_number
    args = {
      token            = param.token
      repository_owner = param.owner
      repository_name  = param.repository_name
      issue_number     = param.issue_number
    }
  }

  step "http" "issue_add_assignees" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          addAssigneesToAssignable(
            input: {assignableId: "${step.pipeline.issue_get_by_number.issue_id}", assigneeIds: ${jsonencode(param.assignee_ids)}}
          ) {
            clientMutationId
            assignable {
              ... on Issue {
                id
                url
              }
            }
          }
        }
        EOQ
    })
  }

  output "issue_url" {
    value = jsondecode(step.http.issue_add_assignees.response_body).data.addAssigneesToAssignable.assignable.url
  }
  output "issue_id" {
    value = jsondecode(step.http.issue_add_assignees.response_body).data.addAssigneesToAssignable.assignable.id
  }
  output "response_body" {
    value = step.http.issue_add_assignees.response_body
  }
  output "response_headers" {
    value = step.http.issue_add_assignees.response_headers
  }
  output "status_code" {
    value = step.http.issue_add_assignees.status_code
  }

}
