// usage: flowpipe pipeline run get_current_user
pipeline "get_current_user" {
  title       = "Get Current User"
  description = "Get the details of currently authenticated user."

  param "token" {
    type    = string
    default = var.token
  }

  step "http" "get_current_user" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
    }

    // TODO: limit socialAccounts to 5 or include a param?
    request_body = jsonencode({
      query = <<EOQ
        query {
          viewer {
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

  output "user_id" {
    value = step.http.get_current_user.response_body.data.viewer.id
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
