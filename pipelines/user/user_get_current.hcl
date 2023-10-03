pipeline "user_get_current" {
  description = "Get the details of currently authenticated user."

  param "github_token" {
    type    = string
    default = var.github_token
  }

  step "http" "user_get_current" {
    title  = "Get the details of currently authenticated user."
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.github_token}"
      #Authorization = "Bearer ${jsonencode(param.github_token)}"
      #Authorization = "Bearer " + jsonencode(param.github_token)
    }

    // TODO: limit socialAccounts to 5 or include a param?
    request_body = jsonencode({
      query = <<EOM
              query {
                viewer {
                  company
                  email
                  id
                  location
                  login
                  name
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

  output "user_id" {
    value = jsondecode(step.http.user_get_current.response_body).data.viewer.id
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
