// usage: flowpipe pipeline run issue_add_assignee  --pipeline-arg "issue_number=151" --pipeline-arg 'assignee_ids=["MDQ6VXNlcjQwOTczODYz", "MDQ6VXNlcjM4MjE4NDE4"]'
pipeline "add_issue_assignees" {
  title = "Add Issue Assignees"
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

  step "pipeline" "get_issue_by_number" {
    pipeline = pipeline.get_issue_by_number
    args = {
      token            = param.token
      repository_owner = param.owner
      repository_name  = param.repository_name
      issue_number     = param.issue_number
    }
  }

  step "http" "add_issue_assignees" {
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
            input: {assignableId: "${step.pipeline.get_issue_by_number.issue_id}", assigneeIds: ${jsonencode(param.assignee_ids)}}
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

  output "issue" {
    value = step.http.add_issue_assignees.response_body.data.addAssigneesToAssignable.assignable
  }

}
