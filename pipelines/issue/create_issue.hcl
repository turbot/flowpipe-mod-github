// usage: flowpipe pipeline run create_issue --pipeline-arg "issue_title=[SUPPORT] please help" --pipeline-arg "issue_body=I need help with..."
pipeline "create_issue" {
  title = "Create Issue"
  description = "Create a new issue."

  param "access_token" {
    type    = string
    default = var.access_token
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

  step "pipeline" "get_repository_by_full_name" {
    pipeline = pipeline.get_repository_by_full_name
    args = {
      access_token = var.access_token
      repository_owner = param.repository_owner
      repository_name  = param.repository_name
    }
  }

  step "http" "create_issue" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.access_token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          createIssue(
            input: {repositoryId: "${step.pipeline.get_repository_by_full_name.repository.id}", title: "${param.issue_title}", body: "${param.issue_body}"}
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
    value = step.http.create_issue.response_body.data.createIssue.issue
  }

}
