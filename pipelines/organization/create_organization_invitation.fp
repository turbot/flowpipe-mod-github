pipeline "create_organization_invitation" {
  title       = "Create Organization Invitation"
  description = "Invites a user to an organization."

  param "conn" {
    type        = connection.github
    description = local.conn_param_description
    default     = connection.github.default
  }

  param "organization" {
    type        = string
    description = "The organization name. The name is not case sensitive."
  }

  param "email" {
    type        = string
    description = "Email address of the person you are inviting, which can be an existing GitHub user."
  }

  param "role" {
    type        = string
    description = <<EOD
      "The role for the new member."
        `admin` - Organization owners with full administrative rights to the organization and complete access to all repositories and teams.
        `direct_member` - Non-owner organization members with ability to see other members and join teams by invitation.
        `billing_manager` - Non-owner organization members with ability to manage the billing settings of your organization."
      EOD
    default     = "direct_member"
  }

  step "http" "create_organization_invitation" {
    url    = "https://api.github.com/orgs/${param.organization}/invitations"
    method = "post"
    request_headers = {
      Accept               = "application/vnd.github+json"
      Authorization        = "Bearer ${param.conn.token}"
      X-GitHub-Api-Version = "2022-11-28"
    }

    request_body = jsonencode({
      email = param.email
      role  = param.role
    })

    throw {
      if      = can(result.response_body.errors)
      message = join(", ", flatten([for error in result.response_body.errors : error.message]))
    }
  }

  output "invitation" {
    description = "Invitation details."
    value       = step.http.create_organization_invitation.response_body
  }

}
