// usage: flowpipe pipeline run get_user_by_login --pipeline-arg "user_login=vkumbha"
pipeline "get_user_by_login" {
  title = "Get User by Login"
  description = "Get the details of a user by login."

  param "access_token" {
    type    = string
    default = var.access_token
  }

  param "user_login" {
    type = string
  }

  step "http" "get_user_by_login" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.access_token}"
    }

    // TODO: limit socialAccounts to 5 or include a param?
    request_body = jsonencode({
      query = <<EOQ
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
        EOQ
    })
  }

  output "user" {
    value = step.http.get_user_by_login.response_body.data.user
  }

}
