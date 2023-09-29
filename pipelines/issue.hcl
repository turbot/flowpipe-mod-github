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

pipeline "get_user" {
  description = "Get the details of the current authenticated user."

  param "github_token" {
    type    = string
    default = var.github_token
  }

  param "user_login" {
    type = string
  }

  step "http" "get_user" {
    title  = "Get the details of a user"
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
                user(login: "${param.user_login}") {
                  id
                  name
                  email
                  location
                  login
                  company
                  socialAccounts(first: 5) {
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

  output "user_node_id" {
    value = jsondecode(step.http.get_user.response_body).data.user.id
  }

  output "response_body" {
    value = step.http.get_user.response_body
  }
  output "response_headers" {
    value = step.http.get_user.response_headers
  }
  output "status_code" {
    value = step.http.get_user.status_code
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

  param "issues_limit" {
    type    = number
    default = 20
  }

  step "http" "list_issues" {
    title  = "List the first (oldest) Open Issues"
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

// NOTE: Make sure the github plugin is installed and steampipe service is up and running.
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
    type = number
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
  description = "Creates a comment on an Issue."

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
    type = number
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

  step "http" "create_comment_on_issue" {
    title  = "Creates a comment on an Issue"
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

    request_body = jsonencode({
      query = <<EOM
              query find_issue {
                search(type: ISSUE, query: "owner:${param.github_owner} repo:${param.github_repo} state:open ${param.search_value}", last: 20) {
                  issueCount
                  nodes {
                    ... on Issue {
                      createdAt
                      title
                      number
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

  param "github_issue_number" {
    type = number
  }

  param "new_body" {
    type = string
  }

  param "new_title" {
    type = string
  }

  param "assignee_ids" {
    type    = list(string)
    default = ["U_kgDOAnE2Jw"]
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

  step "http" "update_issue" {
    title  = "Update an Issue"
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
                    id: "${step.pipeline.get_issue_node.issue_node_id}", 
                    body: "${param.new_body}",
                    title: "${param.new_title}",
                    assigneeIds: ${jsonencode(param.assignee_ids)}
                  }) {
                  clientMutationId
                }
              }
            EOM
    })
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

// usage: flowpipe pipeline run add_issue_assignee  --pipeline-arg "github_issue_number=143" --pipeline-arg 'assignee_ids=["MDQ6VXNlcjQwOTczODYz", "MDQ6VXNlcjM4MjE4NDE4"]'
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

  param "github_issue_number" {
    type = number
  }

  param "assignee_ids" {
    type = list(string)
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

  step "http" "add_issue_assignee" {
    title  = "Update an Issue"
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
                    assignableId: "${step.pipeline.get_issue_node.issue_node_id}", 
                    assigneeIds: ${jsonencode(param.assignee_ids)},
                  }) {
                  clientMutationId
                }
              }
            EOM
    })
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

  param "github_issue_number" {
    type = number
  }

  param "state_reason" {
    type    = set(string) //TODO
    default = ["COMPLETED", "NOT_PLANNED"]
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

  step "http" "close_issue" {
    title  = "Close an Issue"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOM
              mutation {
                closeIssue(
                  input: {
                    issueId: "${step.pipeline.get_issue_node.issue_node_id}", 
                    #stateReason: ${jsonencode(param.state_reason)}
                  }
                ) {
                  clientMutationId
                  issue {
                    url
                    id
                  }
                }
              }
            EOM
    })
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
