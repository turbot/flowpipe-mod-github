pipeline "user_get_by_login" {
  description = "Get the details of a user by login."

  param "github_token" {
    type    = string
    default = var.github_token
  }

  param "user_login" {
    type = string
  }

  step "http" "user_get_by_login" {
    title  = "Get the details of a user by login."
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
                  company
                  email
                  id
                  location
                  login
                  name
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

  output "user_id" {
    value = jsondecode(step.http.user_get_by_login.response_body).data.user.id
  }

  output "response_body" {
    value = step.http.user_get_by_login.response_body
  }
  output "response_headers" {
    value = step.http.user_get_by_login.response_headers
  }
  output "status_code" {
    value = step.http.user_get_by_login.status_code
  }

}
