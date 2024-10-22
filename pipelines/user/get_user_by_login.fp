pipeline "get_user_by_login" {
  title       = "Get User by Login"
  description = "Get the details of a user by login."

  param "conn" {
    type        = connection.github
    description = local.conn_param_description
    default     = connection.github.default
  }

  param "user_login" {
    type        = string
    description = "The user's GitHub login."
  }

  step "http" "get_user_by_login" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.conn.token}"
    }

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

    throw {
      if      = can(result.response_body.errors)
      message = join(", ", flatten([for error in result.response_body.errors : error.message]))
    }
  }

  output "user" {
    description = "User details."
    value       = step.http.get_user_by_login.response_body.data.user
  }

}
