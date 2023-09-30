pipeline "list_issues" {
  description = "List of OPEN issues in the repository."

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

  param "issues_limit" {
    type    = number
    default = 20
  }

  step "http" "list_issues" {
    title  = "List of first (oldest) OPEN issues in the repository."
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
                  issues(first: ${param.issues_limit}, states: OPEN) {
                    totalCount
                    nodes {
                      body
                      createdAt
                      number
                      state
                      title
                      url
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

// // NOTE: Make sure the github plugin is installed and steampipe service is up and running.
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
  description = "Get issue details from the current repository by number."

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

  step "http" "get_issue" {
    title  = "Get issue details from the current repository by number."
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
                  issue(number: ${param.issue_number}) {
                    body
                    id
                    number
                    title
                    url
                  }
                }
              }
            EOM
    })
  }

  output "issue_id" {
    value = jsondecode(step.http.get_issue.response_body).data.repository.issue.id
  }
  output "issue_url" {
    value = jsondecode(step.http.get_issue.response_body).data.repository.issue.url
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

  param "title" {
    type = string
  }

  param "body" {
    type = string
  }

  step "pipeline" "get_repository" {
    pipeline = pipeline.get_repository
    args = {
      github_token = var.github_token
      github_owner = param.github_owner
      github_repo  = param.github_repo
    }
  }

  step "http" "create_issue" {
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
                    repositoryId: "${step.pipeline.get_repository.repository_id}",
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
    value = jsondecode(step.http.create_issue.response_body).data.createIssue.issue.url
  }
  output "issue_id" {
    value = jsondecode(step.http.create_issue.response_body).data.createIssue.issue.id
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

pipeline "create_comment_on_issue" {
  description = "Create a comment on an Issue."

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

  param "comment" {
    type = string
  }

  step "pipeline" "get_issue" {
    pipeline = pipeline.get_issue
    args = {
      github_token = param.github_token
      github_owner = param.github_owner
      github_repo  = param.github_repo
      issue_number = param.issue_number
    }
  }

  step "http" "create_comment_on_issue" {
    title  = "Create a comment on an Issue."
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
                    subjectId: "${step.pipeline.get_issue.issue_id}", 
                    body: "${param.comment}"
                  }) {
                  clientMutationId
                  commentEdge {
                    node {
                      issue {
                        id
                        url
                      }
                    }
                  }
                }
              }
            EOM
    })
  }

  output "issue_url" {
    value = jsondecode(step.http.create_comment_on_issue.response_body).data.addComment.commentEdge.node.issue.url
  }
  output "issue_id" {
    value = jsondecode(step.http.create_comment_on_issue.response_body).data.addComment.commentEdge.node.issue.id
  }
  output "response_body" {
    value = step.http.create_comment_on_issue.response_body
  }
  output "response_headers" {
    value = step.http.create_comment_on_issue.response_headers
  }
  output "status_code" {
    value = step.http.create_comment_on_issue.status_code
  }

}

pipeline "search_issue" {
  description = "Find an issue in a repository."

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

  param "search_value" {
    type    = string
    default = ""
  }

  step "http" "search_issue" {
    title  = "Finds an issue in a repository using search value"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }
    // TODO: last:20? should that be a parameter? is there performance issue or rate limit if we do beyond 20
    request_body = jsonencode({
      query = <<EOM
              query {
                search(type: ISSUE, query: "type:issue owner:${param.github_owner} repo:${param.github_repo} ${param.search_value}", last: 20) {
                  issueCount
                  nodes {
                    ... on Issue {
                      createdAt
                      number
                      title
                      url
                      repository {
                        name
                      }
                    }
                  }
                }
              }
            EOM
    })
  }

  output "issues_count" {
    value = jsondecode(step.http.search_issue.response_body).data.search.issueCount
  }
  output "response_body" {
    value = step.http.search_issue.response_body
  }
  output "response_headers" {
    value = step.http.search_issue.response_headers
  }
  output "status_code" {
    value = step.http.search_issue.status_code
  }

}

// usage: flowpipe pipeline run update_issue --pipeline-arg 'issue_number=153' --pipeline-arg title="[bug] - there is a bug" --pipeline-arg body="please fix the bug" --pipeline-arg 'assignee_ids=["MDQ6VXNlcjQwOTczODYz", "MDQ6VXNlcjM4MjE4NDE4"]'
pipeline "update_issue" {
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
    type    = list(string)
    default = ["U_kgDOAnE2Jw"]
  }

  step "pipeline" "get_issue" {
    pipeline = pipeline.get_issue
    args = {
      github_token = param.github_token
      github_owner = param.github_owner
      github_repo  = param.github_repo
      issue_number = param.issue_number
    }
  }

  step "http" "update_issue" {
    title  = "Update an Issue in a repository."
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOM
              mutation {
                updateIssue(input: 
                  {
                    id: "${step.pipeline.get_issue.issue_id}", 
                    body: "${param.body}",
                    title: "${param.title}",
                    assigneeIds: ${jsonencode(param.assignee_ids)}
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
  }

  output "issue_url" {
    value = jsondecode(step.http.update_issue.response_body).data.updateIssue.issue.url
  }
  output "issue_id" {
    value = jsondecode(step.http.update_issue.response_body).data.updateIssue.issue.id
  }
  output "response_body" {
    value = step.http.update_issue.response_body
  }
  output "response_headers" {
    value = step.http.update_issue.response_headers
  }
  output "status_code" {
    value = step.http.update_issue.status_code
  }

}

// usage: flowpipe pipeline run add_issue_assignee  --pipeline-arg "issue_number=143" --pipeline-arg 'assignee_ids=["MDQ6VXNlcjQwOTczODYz", "MDQ6VXNlcjM4MjE4NDE4"]'
pipeline "add_issue_assignee" {
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

  step "pipeline" "get_issue" {
    pipeline = pipeline.get_issue
    args = {
      github_token = param.github_token
      github_owner = param.github_owner
      github_repo  = param.github_repo
      issue_number = param.issue_number
    }
  }

  step "http" "add_issue_assignee" {
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
                    assignableId: "${step.pipeline.get_issue.issue_id}", 
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
    value = jsondecode(step.http.add_issue_assignee.response_body).data.addAssigneesToAssignable.assignable.url
  }
  output "issue_id" {
    value = jsondecode(step.http.add_issue_assignee.response_body).data.addAssigneesToAssignable.assignable.id
  }
  output "response_body" {
    value = step.http.add_issue_assignee.response_body
  }
  output "response_headers" {
    value = step.http.add_issue_assignee.response_headers
  }
  output "status_code" {
    value = step.http.add_issue_assignee.status_code
  }

}

pipeline "close_issue" {
  description = "Close an Issue in a repository."

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

  param "state_reason" {
    type    = set(string) //TODO
    default = ["COMPLETED", "NOT_PLANNED"]
  }

  step "pipeline" "get_issue" {
    pipeline = pipeline.get_issue
    args = {
      github_token = param.github_token
      github_owner = param.github_owner
      github_repo  = param.github_repo
      issue_number = param.issue_number
    }
  }

  step "http" "close_issue" {
    title  = "Close an Issue in a repository."
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }
    // TODO: use param for stateReason
    request_body = jsonencode({
      query = <<EOM
              mutation {
                closeIssue(
                  input: {
                    issueId: "${step.pipeline.get_issue.issue_id}", 
                    #stateReason: ${jsonencode(param.state_reason)}
                  }
                ) {
                  clientMutationId
                  issue {
                    id
                    url
                  }
                }
              }
            EOM
    })
  }

  output "issue_url" {
    value = jsondecode(step.http.closeIssue.response_body).data.closeIssue.issue.url
  }
  output "issue_id" {
    value = jsondecode(step.http.closeIssue.response_body).data.closeIssue.issue.id
  }
  output "response_body" {
    value = step.http.close_issue.response_body
  }
  output "response_headers" {
    value = step.http.close_issue.response_headers
  }
  output "status_code" {
    value = step.http.close_issue.status_code
  }

}
