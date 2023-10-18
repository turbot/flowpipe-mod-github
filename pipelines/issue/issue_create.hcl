// usage: flowpipe pipeline run issue_create --pipeline-arg "issue_title=[SUPPORT] please help" --pipeline-arg "issue_body=I need help with..."
pipeline "issue_create" {
  description = "Create a new issue."

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

  param "issue_title" {
    type = string
  }

  param "issue_body" {
    type = string
  }

  step "pipeline" "repository_get_by_full_name" {
    pipeline = pipeline.repository_get_by_full_name
    args = {
      token = var.token
      repository_owner = param.repository_owner
      repository_name  = param.repository_name
    }
  }

  step "http" "issue_create" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          createIssue(
            input: {repositoryId: "${step.pipeline.repository_get_by_full_name.repository_id}", title: "${param.issue_title}", body: "${param.issue_body}"}
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
    value = step.http.issue_create.response_body.data.createIssue.issue.url
  }
  output "issue_id" {
    value = step.http.issue_create.response_body.data.createIssue.issue.id
  }
  output "response_body" {
    value = step.http.issue_create.response_body
  }
  output "response_headers" {
    value = step.http.issue_create.response_headers
  }
  output "status_code" {
    value = step.http.issue_create.status_code
  }

}
