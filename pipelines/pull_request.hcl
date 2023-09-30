pipeline "get_pull_request" {
  description = "Get the details of a Pull Request."

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

  param "pull_request_number" {
    type = number
  }

  step "http" "get_pull_request" {
    title  = "Get the details of a Pull Request."
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
                  pullRequest(number: ${param.pull_request_number}) {
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

  output "pull_request_id" {
    value = jsondecode(step.http.get_pull_request.response_body).data.repository.pullRequest.id
  }
  output "pull_request_url" {
    value = jsondecode(step.http.get_pull_request.response_body).data.repository.pullRequest.url
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

// usage: flowpipe pipeline run create_pull_request --pipeline-arg "title=new PR title" --pipeline-arg "body=pr body" --pipeline-arg "base_branch=main" --pipeline-arg "head_branch=demo-branch"
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

  param "title" {
    type = string
  }

  param "body" {
    type = string
  }

  param "base_branch" {
    type = string
  }

  param "head_branch" {
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
                  title: "${param.title}", 
                  repositoryId: "${step.pipeline.get_repository.repository_id}",
                  baseRefName: "${param.base_branch}", 
                  headRefName: "${param.head_branch}",
                  body: "${param.body}"
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

  output "pull_request_id" {
    value = jsondecode(step.http.create_pull_request.response_body).data.createPullRequest.pullRequest.id
  }
  output "pull_request_url" {
    value = jsondecode(step.http.create_pull_request.response_body).data.createPullRequest.pullRequest.url
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
  description = "Create a comment on pull request."

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

  param "pull_request_number" {
    type = number
  }

  param "comment" {
    type = string
  }

  step "pipeline" "get_pull_request" {
    pipeline = pipeline.get_pull_request
    args = {
      github_token        = param.github_token
      github_owner        = param.github_owner
      github_repo         = param.github_repo
      pull_request_number = param.pull_request_number
    }
  }

  step "http" "create_comment_on_pull_request" {
    title  = "Create a comment on pull request."
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
                    subjectId: "${step.pipeline.get_pull_request.pull_request_id}", 
                    body: "${param.comment}"
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

  output "pull_request_id" {
    value = jsondecode(step.http.create_comment_on_pull_request.response_body).data.addComment.commentEdge.node.pullRequest.id
  }
  output "pull_request_url" {
    value = jsondecode(step.http.create_comment_on_pull_request.response_body).data.addComment.commentEdge.node.pullRequest.url
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

  param "pull_request_number" {
    type = number
  }

  param "body" {
    type = string
  }

  param "title" {
    type = string
  }

  param "assignee_ids" {
    type = list(string)
  }

  step "pipeline" "get_pull_request" {
    pipeline = pipeline.get_pull_request
    args = {
      github_token        = param.github_token
      github_owner        = param.github_owner
      github_repo         = param.github_repo
      pull_request_number = param.pull_request_number
    }
  }

  step "http" "update_pull_request" {
    title  = "Update a Pull Request in a repository."
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
                  pullRequestId: "${step.pipeline.get_pull_request.pull_request_id}",
                  title: "${param.title}",
                  body: "${param.body}",
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

  output "pull_request_id" {
    value = jsondecode(step.http.update_pull_request.response_body).data.updatePullRequest.pullRequest.id
  }
  output "pull_request_url" {
    value = jsondecode(step.http.update_pull_request.response_body).data.updatePullRequest.pullRequest.url
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
    title  = "Find a pull request in a repository."
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
                search(type: ISSUE, query: "type:pr owner:${param.github_owner} repo:${param.github_repo} ${param.search_value}", last: 20) {
                  issueCount
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

  output "pull_request_count" {
    value = jsondecode(step.http.search_pull_request.response_body).data.search.issueCount
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

  param "pull_request_number" {
    type = number
  }

  step "pipeline" "get_pull_request" {
    pipeline = pipeline.get_pull_request
    args = {
      github_token        = param.github_token
      github_owner        = param.github_owner
      github_repo         = param.github_repo
      pull_request_number = param.pull_request_number
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
                    pullRequestId: "${step.pipeline.get_pull_request.pull_request_id}"
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

  output "pull_request_id" {
    value = jsondecode(step.http.close_pull_request.response_body).data.closePullRequest.pullRequest.id
  }
  output "pull_request_url" {
    value = jsondecode(step.http.close_pull_request.response_body).data.closePullRequest.pullRequest.url
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

// usage: flowpipe pipeline run search_issues_pull_requests --pipeline-arg "search_value=owner:vkumbha repo:deleteme state:open unencrypted"
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
    title  = "Find Issues and pull requests by state and keyword in a repository."
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }
    // TODO: last:20? should that be a parameter? is there performance issue or rate limit if we do beyond 20
    request_body = jsonencode({
      query = <<EOM
              query find_issue {
                search(type: ISSUE, query: "${param.search_value}", last: 20) {
                  issueCount
                  repositoryCount
                  wikiCount
                  discussionCount
                  codeCount
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
                    ... on PullRequest {
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
