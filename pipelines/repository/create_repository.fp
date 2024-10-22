pipeline "create_repository" {
  title       = "Create Repository"
  description = "Creates a new repository."

  param "conn" {
    type        = connection.github
    description = local.conn_param_description
    default     = connection.github.default
  }

  param "repository_owner" {
    type        = string
    description = local.repository_owner_param_description
  }

  param "repository_name" {
    type        = string
    description = local.repository_name_param_description
  }

  param "visibility" {
    type        = string
    description = "The visibility of the repository. Allowed values are PRIVATE, PUBLIC, or INTERNAL. Defaults to PRIVATE."
  }

  step "pipeline" "get_repository_owner" {
    pipeline = pipeline.get_repository_owner
    args = {
      conn             = param.conn
      repository_owner = param.repository_owner
    }
  }

  step "http" "create_repository" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.conn.token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          createRepository(
            input: {name: "${param.repository_name}", ownerId: "${step.pipeline.get_repository_owner.output.repository_owner.id}", visibility: ${param.visibility}}
          ) {
            repository {
              id
              name
              url
              visibility
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

  output "repository" {
    description = "Repository details."
    value       = step.http.create_repository.response_body.data.createRepository.repository
  }

}
