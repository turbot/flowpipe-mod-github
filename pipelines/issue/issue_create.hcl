// usage: flowpipe pipeline run issue_create --pipeline-arg "title=[SUPPORT] please help" --pipeline-arg "body=I need help with..."
pipeline "issue_create" {
  description = "Create a new issue."

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

  param "title" {
    type = string
  }

  param "body" {
    type = string
  }

  step "pipeline" "repository_get_by_full_name" {
    pipeline = pipeline.repository_get_by_full_name
    args = {
      github_token = var.github_token
      github_owner = param.github_owner
      github_repo  = param.github_repo
    }
  }

  step "http" "issue_create" {
    title  = "Create a new issue."
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOM
              mutation {
                createIssue(input: 
                  { 
                    repositoryId: "${step.pipeline.repository_get_by_full_name.repository_id}",
                    title: "${param.title}",
                    body: "${param.body}"
                  }) {
                  clientMutationId
                  issue {
                    id
                    url
                  }
                }
              }
            EOM
    })

    error {
      max_retries = 3
    }

  }

  output "issue_url" {
    value = jsondecode(step.http.issue_create.response_body).data.createIssue.issue.url
  }
  output "issue_id" {
    value = jsondecode(step.http.issue_create.response_body).data.createIssue.issue.id
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