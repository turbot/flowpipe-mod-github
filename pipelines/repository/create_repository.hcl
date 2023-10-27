// usage: flowpipe pipeline run create_repository --pipeline-arg "repository_name=my-first-repo" --pipeline-arg "visibility=PRIVATE"
pipeline "create_repository" {
  title = "Create Repository"
  description = "Creates a new repository."

  param "token" {
    type    = string
    default = var.token
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
      token            = var.token
      repository_owner = param.repository_owner
    }
  }

  step "http" "create_repository" {
    method = "post"
    url    = "https://api.github.com/graphql"
    request_headers = {
      Content-Type  = "application/json"
      Authorization = "Bearer ${param.token}"
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

  output "repository_url" {
    value = step.http.create_repository.response_body.data.createRepository.repository.url
  }
  output "repository_id" {
    value = step.http.create_repository.response_body.data.createRepository.repository.id
  }
  output "response_body" {
    value = step.http.create_repository.response_body
  }
  output "response_headers" {
    value = step.http.create_repository.response_headers
  }
  output "status_code" {
    value = step.http.create_repository.status_code
  }

}
