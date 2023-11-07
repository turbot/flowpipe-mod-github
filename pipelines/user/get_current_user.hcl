// usage: flowpipe pipeline run get_current_user
pipeline "get_current_user" {
  title       = "Get Current User"
  description = "Get the details of currently authenticated user."

  param "access_token" {
    type    = string
    default = var.access_token
  }

  step "http" "get_current_user" {
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

  output "user" {
    value = step.http.get_current_user.response_body.data.viewer
  }

}
