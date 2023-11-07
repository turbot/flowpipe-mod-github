// usage: flowpipe pipeline run create_repository --pipeline-arg "repository_name=my-first-repo" --pipeline-arg "visibility=PRIVATE"
pipeline "create_repository" {
  title = "Create Repository"
  description = "Creates a new repository."

  param "access_token" {
    type    = string
    default = var.access_token
  }

  param "repository_owner" {
    type    = string
    default = local.repository_owner
  }

  param "repository_name" {
    type = string
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
    default = "PRIVATE"

    // Unsupported block type: Blocks of type "validation" are not expected here.
    // validation {
    //   condition     = contains(["PRIVATE", "PUBLIC", "INTERNAL"], param.visibility)
    //   error_message = "Allowed values for input_parameter are \"PRIVATE\", \"PUBLIC\", or \"INTERNAL\"."
    // }
  }

  step "pipeline" "get_repository_owner" {
    pipeline = pipeline.get_repository_owner
    args = {
      access_token            = var.access_token
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
            input: {name: "${param.repository_name}", ownerId: "${step.pipeline.get_repository_owner.owner_id}", visibility: ${param.visibility}}
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
    value = step.http.create_repository.response_body.data.createRepository.repository
  }

}
