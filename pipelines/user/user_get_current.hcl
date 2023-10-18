// usage: flowpipe pipeline run user_get_current
pipeline "user_get_current" {
  description = "Get the details of currently authenticated user."

  param "token" {
    type    = string
    default = var.token
  }

  step "http" "user_get_current" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
      #Authorization = "Bearer ${jsonencode(param.token)}"
      #Authorization = "Bearer " + jsonencode(param.token)
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
    value = step.http.user_get_current.response_body.data.viewer.id
  }
  output "response_body" {
    value = step.http.user_get_current.response_body
  }
  output "response_headers" {
    value = step.http.user_get_current.response_headers
  }
  output "status_code" {
    value = step.http.user_get_current.status_code
  }

}
