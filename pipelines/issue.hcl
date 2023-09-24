locals {
  github_owner = split("/", var.repository_full_name)[0]
  github_repo  = split("/", var.repository_full_name)[1]
}

pipeline "get_current_user" {
  description = "Get the details of the current authenticated user."

  param "github_token" {
    type = string
    // default = var.github_token // TODO: This is not implemented yet, check later! // TODO: This is not implemented yet, check later!
  }

  step "http" "get_current_user" {
    title  = "Get the details of current logged in user"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type = "application/json"
      // Authorization = "Bearer ${param.github_token}" // TODO: Use param when variables are accepted.
      Authorization = "Bearer ${var.github_token}"
    }

    // TODO: limit socialAccounts to 5 or include a param?
    request_body = jsonencode({
      query = <<EOM
              query {
                viewer {
                  login
                  name
                  email
                  location
                  company
                  socialAccounts(first:5) {
                    edges {
                      node {
                        provider
                        url
                      }
                    }
                  }
                }
              }
            EOM
    })
  }
}

pipeline "list_issues" {
  description = "List of the first 20 OPEN issues in the repository."

  param "github_token" {
    type = string
    // default = var.github_token // TODO: This is not implemented yet, check later!
  }

  param "github_owner" {
    type = string
    // default = local.github_owner // TODO: This is not implemented yet, check later!
    default = "octocat"
  }

  param "github_repo" {
    type = string
    // default = local.github_repo // TODO: This is not implemented yet, check later!
    default = "hello-world"
    // default = local.github_repo
  }

  step "http" "list_issues" {
    title  = "List the first 20 Open Issues"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type = "application/json"
      // Authorization = "Bearer ${param.github_token}" // TODO: Use param when variables are accepted.
      Authorization = "Bearer ${var.github_token}"
    }

    // TODO: limit of first 20 issues?
    request_body = jsonencode({
      query = <<EOM
              query {
                repository(owner: "${param.github_owner}", name: "${param.github_repo}") {
                  issues(first: 20, states: OPEN) {
                    totalCount
                    nodes {
                      number
                      url
                      title
                      body
                      createdAt
                      state
                    }
                  }
                }
              }
            EOM
    })
  }

  output "list_nodes" {
    value = jsondecode(step.http.list_issues.response_body).data.repository.issues.nodes
  }

  output "total_open_issues" {
    value = jsondecode(step.http.list_issues.response_body).data.repository.issues.totalCount
  }

}

pipeline "list_issues_with_sp_query" {
  description = "List of all OPEN issues in the repository using steampipe query."

  param "github_token" {
    type = string
    // default = var.github_token // TODO: This is not implemented yet, check later!
  }

  param "github_owner" {
    type = string
    // default = local.github_owner // TODO: This is not implemented yet, check later!
    default = "octocat"
  }

  param "github_repo" {
    type = string
    // default = local.github_repo // TODO: This is not implemented yet, check later!
    default = "hello-world"
  }

  param "github_path" {
    type    = string
    default = "octocat/hello-world"
  }

  // TODO: use params in the where clause. Causes a panic error right now. Check later!
  // https://github.com/turbot/flowpipe/issues/82
  step "query" "list_issues" {
    connection_string = "postgres://steampipe@localhost:9193/steampipe"
    sql               = "select number,url,title,body from github_issue where repository_full_name ='turbot/steampipe' and state = 'OPEN'"

  }
}

pipeline "get_issue" {
  description = "Get single issue details from the current repository by number."

  param "github_token" {
    type = string
    // default = var.github_token // TODO: This is not implemented yet, check later!
  }

  param "github_owner" {
    type = string
    // default = local.github_owner // TODO: This is not implemented yet, check later!
    default = "octocat"
  }

  param "github_repo" {
    type = string
    // default = local.github_repo // TODO: This is not implemented yet, check later!
    default = "hello-world"
  }

  param "github_issue_number" {
    type = string
  }

  step "http" "get_issue" {
    title  = "Get details about an issue"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type = "application/json"
      // Authorization = "Bearer ${param.github_token}" // TODO: Use param when variables are accepted.
      Authorization = "Bearer ${var.github_token}"
    }

    request_body = jsonencode({
      query = <<EOM
              query {
                repository(owner: "${param.github_owner}", name: "${param.github_repo}") {
                  issue(number: ${param.github_issue_number}) {
                    id
                    number
                    url
                    title
                    body
                  }
                }
              }
            EOM
    })
  }

  output "issue_node_id" {
    value = jsondecode(step.http.get_issue.response_body).data.repository.issue.id
  }

}

pipeline "get_repository_id" {
  description = "Get the repository node ID."

  param "github_token" {
    type = string
    // default = var.github_token // TODO: This is not implemented yet, check later!
  }

  param "github_owner" {
    type = string
    // default = local.github_owner // TODO: This is not implemented yet, check later!
    default = "vkumbha"
  }

  param "github_repo" {
    type = string
    // default = local.github_repo // TODO: This is not implemented yet, check later!
    default = "deleteme"
  }

  step "http" "get_repository_id" {
    title  = "Get repository Id"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type = "application/json"
      // Authorization = "Bearer ${param.github_token}" // TODO: Use param when variables are accepted.
      Authorization = "Bearer ${var.github_token}"
    }

    request_body = jsonencode({
      query = <<EOM
              query {
                repository(owner:"${param.github_owner}", name:"${param.github_repo}") {
                  id
                }
              }
            EOM
    })
  }

  output "repository_id" {
    value = jsondecode(step.http.get_repository_id.response_body).data.repository.id
  }
}

pipeline "create_issue" {
  description = "Create a new issue."

  param "github_token" {
    type = string
    // default = var.github_token // TODO: This is not implemented yet, check later!
  }

  param "github_owner" {
    type = string
    // default = local.github_owner // TODO: This is not implemented yet, check later!
    default = "vkumbha"
  }

  param "github_repo" {
    type = string
    // default = local.github_repo // TODO: This is not implemented yet, check later!
    default = "deleteme"
  }

  param "issue_title" {
    type = string
  }

  param "issue_body" {
    type = string
  }

  step "pipeline" "get_repository_id" {
    pipeline = pipeline.get_repository_id
    args = {
      github_token = param.github_token
      github_owner = param.github_owner
      github_repo  = param.github_repo
    }
  }

  step "http" "create_issue" {
    title  = "Create Issue"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type = "application/json"
      // Authorization = "Bearer ${param.github_token}" // TODO: Use param when variables are accepted.
      Authorization = "Bearer ${var.github_token}"
    }

    request_body = jsonencode({
      query = <<EOM
              mutation {
                createIssue(input: 
                  { 
                    repositoryId: "${step.pipeline.get_repository_id.repository_id}",
                    title: "${param.issue_title}",
                    body: "${param.issue_body}"
                  }) {
                  clientMutationId
                  issue {
                    id
                  }
                }
              }
            EOM
    })
  }

}

pipeline "add_comment" {
  description = "Add a comment to an Issue."

  param "github_token" {
    type = string
    // default = var.github_token // TODO: This is not implemented yet, check later!
  }

  param "github_owner" {
    type = string
    // default = local.github_owner // TODO: This is not implemented yet, check later!
    default = "octocat"
  }

  param "github_repo" {
    type = string
    // default = local.github_repo // TODO: This is not implemented yet, check later!
    default = "hello-world"
  }

  param "github_issue_number" {
    type = string
  }

  param "comment_body" {
    type = string
  }

  step "pipeline" "get_issue_node" {
    pipeline = pipeline.get_issue
    args = {
      github_token        = param.github_token
      github_owner        = param.github_owner
      github_repo         = param.github_repo
      github_issue_number = param.github_issue_number
    }
  }

  step "http" "add_comment_on_issue" {
    title  = "Add comment on an Issue"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type = "application/json"
      // Authorization = "Bearer ${param.github_token}" // TODO: Use param when variables are accepted.
      Authorization = "Bearer ${var.github_token}"
    }

    request_body = jsonencode({
      query = <<EOM
              mutation {
                addComment(input: 
                  {
                    subjectId: "${step.pipeline.get_issue_node.issue_node_id}", 
                    body: "${param.comment_body}"
                  }) {
                  clientMutationId
                }
              }
            EOM
    })
  }

}

pipeline "my_notification_pipeline" {
  description = "Send a slack notification."

  param "github_token" {
    type = string
    // default = var.github_token // TODO: This is not implemented yet, check later!
  }

  param "github_owner" {
    type = string
    // default = local.github_owner // TODO: This is not implemented yet, check later!
    default = "octocat"
  }

  param "github_repo" {
    type = string
    // default = local.github_repo // TODO: This is not implemented yet, check later!
    default = "hello-world"
  }

  step "pipeline" "list_issues" {
    pipeline = pipeline.list_issues
    args = {
      github_token = param.github_token
      github_owner = param.github_owner
      github_repo  = param.github_repo
    }
  }

  step "http" "notify_slack" {
    url    = var.slack_webhook_url
    method = "post"
    request_headers = {
      Content-Type = "application/json"
    }

    request_body = jsonencode({
      text = "Total Open issues: ${step.pipeline.list_issues.total_open_issues}"
    })
  }

}
