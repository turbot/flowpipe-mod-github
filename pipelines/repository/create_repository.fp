# usage: flowpipe pipeline run create_repository --arg "repository_name=my-first-repo" --arg "visibility=PRIVATE"
pipeline "create_repository" {
  title       = "Create Repository"
  description = "Creates a new repository."

  param "cred" {
    type        = string
    description = local.cred_param_description
    default     = "default"
  }

  param "repository_owner" {
    type        = string
    description = local.repository_owner_param_description
    default     = local.repository_owner
  }

  param "repository_name" {
    type        = string
    description = local.repository_name_param_description
    default     = local.repository_name
  }

  // TODO: How to pass set(string) ?
  param "visibility" {
    type = string
    // type    = set(string)
    // default = [
    // "PRIVATE",
    // "PUBLIC",
    // "INTERNAL"
    // ]
    description = "The visibility of the repository. Allowed values are PRIVATE, PUBLIC, or INTERNAL. Defaults to PRIVATE."
    default     = "PRIVATE"

    // Unsupported block type: Blocks of type "validation" are not expected here.
    // validation {
    //   condition     = contains(["PRIVATE", "PUBLIC", "INTERNAL"], param.visibility)
    //   error_message = "Allowed values for input_parameter are \"PRIVATE\", \"PUBLIC\", or \"INTERNAL\"."
    // }
  }

  step "pipeline" "get_repository_owner" {
    pipeline = pipeline.get_repository_owner
    args = {
      cred             = param.cred
      repository_owner = param.repository_owner
    }
  }

  step "http" "create_repository" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }

    request_body = jsonencode({
      query = <<EOQ
        mutation {
          createRepository(
            input: {name: "${param.repository_name}", ownerId: "${step.pipeline.get_repository_owner.output.repository_owner.id}", visibility: ${param.visibility}}
          ) {
            clientMutationId
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
      if      = can(result.response_body.errors[0].message)
      message = result.response_body.errors[0].message
    }
  }

  output "repository" {
    description = "Repository details."
    value       = step.http.create_repository.response_body.data.createRepository.repository
  }

}
