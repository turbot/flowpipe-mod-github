pipeline "get_current_user" {

  param "github_token" {
    type = string
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
}

pipeline "list_issues" {

  param "github_token" {
    type = string
  }

  param "github_owner" {
    type = string
    // default = var.github_owner // TODO: This is not implemented yet, check later!
    default = "octocat"
  }

  param "github_repo" {
    type = string
    // default = var.github_repo // TODO: This is not implemented yet, check later!
    default = "hello-world"
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
                  issues(first: 20, states:OPEN) {
                    totalCount
                    edges {
                      node {
                        number
                        url
                        title
                        body
                      }
                    }
                  }
                }
              }
            EOM
    })
  }
}

pipeline "get_issue" {

  param "github_token" {
    type = string
  }

  param "github_owner" {
    type = string
    // default = var.github_owner // TODO: This is not implemented yet, check later!
    default = "octocat"
  }

  param "github_repo" {
    type = string
    // default = var.github_repo // TODO: This is not implemented yet, check later!
    default = "hello-world"
  }

  // param "github_issue_number" {
  //   type = number
  // }

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
                  issue(number: 2174) {
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
}


pipeline "get_repository_id" {

  param "github_token" {
    type = string
  }

  param "github_owner" {
    type = string
    // default = var.github_owner // TODO: This is not implemented yet, check later!
    default = "vkumbha"
  }

  param "github_repo" {
    type = string
    // default = var.github_repo // TODO: This is not implemented yet, check later!
    default = "deleteme"
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
}

pipeline "create_issue" {

  param "github_token" {
    type = string
  }

  param "github_owner" {
    type = string
    // default = var.github_owner // TODO: This is not implemented yet, check later!
    default = "vkumbha"
  }

  param "github_repo" {
    type = string
    // default = var.github_repo // TODO: This is not implemented yet, check later!
    default = "deleteme"
  }

  param "issue_title" {
    type = string
  }

  param "issue_body" {
    type = string
  }

  step "pipeline" "call_other_pipeline" {
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
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
    }

    request_body = jsonencode({
      query = <<EOM
              mutation {
                createIssue(input: 
                  { 
                    repositoryId: "${step.pipeline.call_other_pipeline.repository_id}",
                    title: "${param.issue_title}",
                    body: "${param.issue_body}"
                  }) {
                  clientMutationId
                }
              }
            EOM
    })
  }

}
