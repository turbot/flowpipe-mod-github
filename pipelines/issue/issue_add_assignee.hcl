// usage: flowpipe pipeline run issue_add_assignee  --pipeline-arg "issue_number=151" --pipeline-arg 'assignee_ids=["MDQ6VXNlcjQwOTczODYz", "MDQ6VXNlcjM4MjE4NDE4"]'
pipeline "issue_add_assignee" {
  description = "Add assignee(s) to an issue in a repository."

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

  param "assignee_ids" {
    type = list(string)
  }

  step "pipeline" "issue_get_by_number" {
    pipeline = pipeline.issue_get_by_number
    args = {
      github_token = param.github_token
      github_owner = param.github_owner
      github_repo  = param.github_repo
      issue_number = param.issue_number
    }
  }

  step "http" "issue_add_assignee" {
    title  = "Add assignee(s) to an issue in a repository."
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOM
              mutation {
                addAssigneesToAssignable(input: 
                  {
                    assignableId: "${step.pipeline.issue_get_by_number.issue_id}", 
                    assigneeIds: ${jsonencode(param.assignee_ids)},
                  }) {
                  clientMutationId
                  assignable {
                    ... on Issue{
                      id
                      url
                    }
                  }
                }
              }
            EOM
    })
  }

  output "issue_url" {
    value = jsondecode(step.http.issue_add_assignee.response_body).data.addAssigneesToAssignable.assignable.url
  }
  output "issue_id" {
    value = jsondecode(step.http.issue_add_assignee.response_body).data.addAssigneesToAssignable.assignable.id
  }
  output "response_body" {
    value = step.http.issue_add_assignee.response_body
  }
  output "response_headers" {
    value = step.http.issue_add_assignee.response_headers
  }
  output "status_code" {
    value = step.http.issue_add_assignee.status_code
  }

}
