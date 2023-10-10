// usage: flowpipe pipeline run repository_create --pipeline-arg "repository_name=my-first-repo" --pipeline-arg "visibility=PRIVATE"
pipeline "repository_create" {
  description = "Create a new repository."

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

  step "pipeline" "repository_get_owner" {
    pipeline = pipeline.repository_get_owner
    args = {
      token            = var.token
      repository_owner = param.repository_owner
    }
  }

  step "http" "repository_create" {
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
            input: {name: "${param.repository_name}", ownerId: "${step.pipeline.repository_get_owner.owner_id}", visibility: ${param.visibility}}
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
    value = jsondecode(step.http.repository_create.response_body).data.createRepository.repository.url
  }
  output "repository_id" {
    value = jsondecode(step.http.repository_create.response_body).data.createRepository.repository.id
  }
  output "response_body" {
    value = step.http.repository_create.response_body
  }
  output "response_headers" {
    value = step.http.repository_create.response_headers
  }
  output "status_code" {
    value = step.http.repository_create.status_code
  }

}
