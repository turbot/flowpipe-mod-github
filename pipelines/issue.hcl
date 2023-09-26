locals {
  github_owner = split("/", var.repository_full_name)[0]
  github_repo  = split("/", var.repository_full_name)[1]
}

pipeline "get_current_user" {
  description = "Get the details of the current authenticated user."

  param "github_token" {
    type    = string
    default = var.github_token
  }

  step "http" "get_current_user" {
    title  = "Get the details of current logged in user"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
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

  output "response_body" {
    value = step.http.get_current_user.response_body
  }
  output "response_headers" {
    value = step.http.get_current_user.response_headers
  }
  output "status_code" {
    value = step.http.get_current_user.status_code
  }

}

pipeline "list_issues" {
  description = "List of the first 20 OPEN issues in the repository."

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

  step "http" "list_issues" {
    title  = "List the first 20 Open Issues"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
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

  output "response_body" {
    value = step.http.list_issues.response_body
  }
  output "response_headers" {
    value = step.http.list_issues.response_headers
  }
  output "status_code" {
    value = step.http.list_issues.status_code
  }

}

pipeline "list_issues_with_sp_query" {
  description = "List of all OPEN issues in the repository using steampipe query."

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

  // TODO: use params in the where clause. Causes a panic error right now. Check later!
  // https://github.com/turbot/flowpipe/issues/82
  step "query" "list_issues" {
    connection_string = "postgres://steampipe@localhost:9193/steampipe"
    sql               = "select number,url,title,body from github_issue where repository_full_name ='turbot/steampipe' and state = 'OPEN'"
  }

  output "rows" {
    value = step.query.list_issues.rows
  }
}

pipeline "get_issue" {
  description = "Get single issue details from the current repository by number."

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

  param "github_issue_number" {
    type = string //TODO: Use number once the issue is fixed. https://github.com/turbot/flowpipe/issues/87
  }

  step "http" "get_issue" {
    title  = "Get details about an issue"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
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

  output "response_body" {
    value = step.http.get_issue.response_body
  }
  output "response_headers" {
    value = step.http.get_issue.response_headers
  }
  output "status_code" {
    value = step.http.get_issue.status_code
  }

}

pipeline "get_repository_id" {
  description = "Get the repository node ID."

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

  step "http" "get_repository_id" {
    title  = "Get repository Id"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
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
  output "response_body" {
    value = step.http.get_repository_id.response_body
  }
  output "response_headers" {
    value = step.http.get_repository_id.response_headers
  }
  output "status_code" {
    value = step.http.get_repository_id.status_code
  }

}

pipeline "create_issue" {
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

  param "issue_title" {
    type = string
  }

  param "issue_body" {
    type = string
  }

  step "pipeline" "get_repository_id" {
    pipeline = pipeline.get_repository_id
    args = {
      github_token = var.github_token
      github_owner = param.github_owner
      github_repo  = param.github_repo
    }
  }

  step "http" "create_issue" {
    title  = "Create Issue"
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

    // error {
    //   max_retries = 3
    // } 
  }

  output "response_body" {
    value = step.http.create_issue.response_body
  }
  output "response_headers" {
    value = step.http.create_issue.response_headers
  }
  output "status_code" {
    value = step.http.create_issue.status_code
  }

}

pipeline "add_comment_on_issue" {
  description = "Add a comment to an Issue."

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
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
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

  output "response_body" {
    value = step.http.add_comment_on_issue.response_body
  }
  output "response_headers" {
    value = step.http.add_comment_on_issue.response_headers
  }
  output "status_code" {
    value = step.http.add_comment_on_issue.status_code
  }

}

pipeline "my_notification_pipeline" {
  description = "Send a slack notification."

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
      text = "Total Open issues: ${step.pipeline.list_issues.total_open_issues}. \n List of first 20 Issues:\n ${join("", [for issue in jsondecode(step.pipeline.list_issues.list_nodes) : format("%s - %s\n", issue.number, issue.title)])}"
    })
  }

  output "response_body" {
    value = step.http.notify_slack.response_body
  }
  output "response_headers" {
    value = step.http.notify_slack.response_headers
  }
  output "status_code" {
    value = step.http.notify_slack.status_code
  }

}

pipeline "create_issue_send_notification" {
  description = "Create a new issue and send slack notification."

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

  param "issue_title" {
    type = string
  }

  param "issue_body" {
    type = string
  }

  param "slack_token" {
    type = string
  }

  param "message" {
    type = string
  }

  param "channel" {
    type = string
    // default = "ABCD0XYZ1" // using channel ID works
    default = "test-build-slack-room" // using channel name also works
  }

  // Calling a pipeline within the mod
  step "pipeline" "get_repository_id" {
    pipeline = pipeline.get_repository_id
    args = {
      github_token = var.github_token
      github_owner = param.github_owner
      github_repo  = param.github_repo
    }
  }

  // Calling a Pipeline from a different mod
  step "pipeline" "post_message" {
    pipeline = slack_mod.pipeline.post_message
    args = {
      slack_token = param.slack_token
      channel     = param.channel
      message     = (step.http.create_issue.status_code == 200 ? "Following issue is created with the Flowpipe Pipeline: ${jsondecode(step.http.create_issue.response_body).data.createIssue.issue.url}" : "Failed to create issue with status code ${step.http.create_issue.status_code}")
    }
  }

  step "http" "create_issue" {
    title  = "Create Issue"
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
                    repositoryId: "${step.pipeline.get_repository_id.repository_id}",
                    title: "${param.issue_title}",
                    body: "${param.issue_body}"
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
      ignore = true
    }

  }
  output "issue_url" {
    value = jsondecode(step.http.create_issue.response_body).data.createIssue.issue.url
  }

  output "response_body" {
    value = step.http.create_issue.response_body
  }
  output "response_headers" {
    value = step.http.create_issue.response_headers
  }
  output "status_code" {
    value = step.http.create_issue.status_code
  }

}
