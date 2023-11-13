# usage: flowpipe pipeline run create_repository --pipeline-arg "repository_name=my-first-repo" --pipeline-arg "visibility=PRIVATE"
pipeline "create_repository" {
  title       = "Create Repository"
  description = "Creates a new repository."

  param "access_token" {
    type        = string
    description = local.access_token_param_description
    default     = var.access_token
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
      access_token     = param.access_token
      repository_owner = param.repository_owner
    }
  }

  step "http" "create_repository" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.access_token}"
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

  }

  output "repository" {
    description = "Repository details."
    value       = step.http.create_repository.response_body.data.createRepository.repository
  }

}
