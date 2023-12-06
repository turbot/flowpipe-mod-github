pipeline "get_current_user" {
  title       = "Get Current User"
  description = "Get the details of currently authenticated user."

  param "cred" {
    type        = string
    description = local.cred_param_description
    default     = "default"
  }

  step "http" "get_current_user" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${credential.github[param.cred].token}"
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
    description = "Current user details."
    value       = step.http.get_current_user.response_body.data.viewer
  }

}
