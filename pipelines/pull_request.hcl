pipeline "get_pull_request" {
  description = "Get details of a Pull request."

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

  param "github_pull_request_number" {
    type = number
  }

  step "http" "get_pull_request" {
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
                  pullRequest(number: ${param.github_pull_request_number}) {
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

  output "pull_request_node_id" {
    value = jsondecode(step.http.get_pull_request.response_body).data.repository.pullRequest.id
  }

  output "response_body" {
    value = step.http.get_pull_request.response_body
  }
  output "response_headers" {
    value = step.http.get_pull_request.response_headers
  }
  output "status_code" {
    value = step.http.get_pull_request.status_code
  }


}

pipeline "create_pull_request" {
  description = "Create a Pull request."

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

  param "pull_request_title" {
    type = string
  }

  param "pull_request_base_branch" {
    type = string
  }

  param "pull_request_head_branch" {
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

  step "http" "create_pull_request" {
    title  = "Create Pull Request"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOM
              mutation {
                createPullRequest(input: 
                {
                  title: "${param.pull_request_title}", 
                  repositoryId: "${step.pipeline.get_repository_id.repository_id}",
                  baseRefName: "${param.pull_request_base_branch}", 
                  headRefName: "${param.pull_request_head_branch}"
                }) {
                  clientMutationId
                  pullRequest {
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
    value = step.http.create_pull_request.response_body
  }
  output "response_headers" {
    value = step.http.create_pull_request.response_headers
  }
  output "status_code" {
    value = step.http.create_pull_request.status_code
  }

}

pipeline "create_comment_on_pull_request" {
  description = "Creates a comment on pull request."

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

  param "github_pull_request_number" {
    type = number
  }

  param "comment_body" {
    type = string
  }

  step "pipeline" "get_pull_request_node" {
    pipeline = pipeline.get_pull_request
    args = {
      github_token               = param.github_token
      github_owner               = param.github_owner
      github_repo                = param.github_repo
      github_pull_request_number = param.github_pull_request_number
    }
  }

  step "http" "create_comment_on_pull_request" {
    title  = "Creates a comment on pull request"
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
                    subjectId: "${step.pipeline.get_pull_request_node.pull_request_node_id}", 
                    body: "${param.comment_body}"
                  }) {
                  clientMutationId
                  commentEdge {
                    node {
                      pullRequest {
                        url
                        id
                      }
                    }
                  }
                }
              }
            EOM
    })
  }

  output "response_body" {
    value = step.http.create_comment_on_pull_request.response_body
  }
  output "response_headers" {
    value = step.http.create_comment_on_pull_request.response_headers
  }
  output "status_code" {
    value = step.http.create_comment_on_pull_request.status_code
  }

}

pipeline "update_pull_request" {
  description = "Update a Pull Request in a repository."

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

  param "github_pull_request_number" {
    type = number
  }

  param "new_body" {
    type = string
  }

  param "new_title" {
    type = string
  }

  param "assignee_ids" {
    type = list(string)
  }

  step "pipeline" "get_pull_request_node" {
    pipeline = pipeline.get_pull_request
    args = {
      github_token               = param.github_token
      github_owner               = param.github_owner
      github_repo                = param.github_repo
      github_pull_request_number = param.github_pull_request_number
    }
  }

  step "http" "update_pull_request" {
    title  = "Update a pull request"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOM
              mutation {
                updatePullRequest(input:
                {
                  pullRequestId: "${step.pipeline.get_pull_request_node.pull_request_node_id}",
                  title: "${param.new_title}",
                  body: "${param.new_body}",
                  assigneeIds: ${jsonencode(param.assignee_ids)}
                }) {
                  clientMutationId
                  pullRequest{
                    url
                    id
                  }
                }

              }
            EOM
    })
  }

  output "response_body" {
    value = step.http.update_pull_request.response_body
  }
  output "response_headers" {
    value = step.http.update_pull_request.response_headers
  }
  output "status_code" {
    value = step.http.update_pull_request.status_code
  }

}

pipeline "search_pull_request" {
  description = "Find a pull request in a repository."

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

  step "http" "search_pull_request" {
    title  = "Finds a pull request in a repository using search value"
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
                  nodes {
                    ... on PullRequest {
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
    value = step.http.search_pull_request.response_body
  }
  output "response_headers" {
    value = step.http.search_pull_request.response_headers
  }
  output "status_code" {
    value = step.http.search_pull_request.status_code
  }

}

pipeline "close_pull_request" {
  description = "Close a pull request in a repository."

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

  param "github_pull_request_number" {
    type = number
  }

  step "pipeline" "get_pull_request_node" {
    pipeline = pipeline.get_pull_request
    args = {
      github_token               = param.github_token
      github_owner               = param.github_owner
      github_repo                = param.github_repo
      github_pull_request_number = param.github_pull_request_number
    }
  }

  step "http" "close_pull_request" {
    title  = "Close a Pull Request"
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOM
              mutation {
                closePullRequest(
                  input: {
                    pullRequestId: "${step.pipeline.get_pull_request_node.pull_request_node_id}"
                  }) {
                  clientMutationId
                  pullRequest {
                    url
                    id
                  }
                }
              }
            EOM
    })
  }

  output "response_body" {
    value = step.http.close_pull_request.response_body
  }
  output "response_headers" {
    value = step.http.close_pull_request.response_headers
  }
  output "status_code" {
    value = step.http.close_pull_request.status_code
  }

}

pipeline "search_issues_pull_requests" {
  description = "Find Issues and pull requests by state and keyword in a repository."

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

  step "http" "search_issues_pull_requests" {
    title  = "Finds a pull request in a repository using search value"
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
                    ... on PullRequest {
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
    value = step.http.search_issues_pull_requests.response_body
  }
  output "response_headers" {
    value = step.http.search_issues_pull_requests.response_headers
  }
  output "status_code" {
    value = step.http.search_issues_pull_requests.status_code
  }

}
