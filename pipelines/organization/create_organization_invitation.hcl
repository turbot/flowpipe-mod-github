## fp create_organization_invitation --pipeline-arg organization=fluent-cattle --pipeline-arg email=brief-ocelot@coffeetech.com.br

pipeline "create_organization_invitation" {
  title        = "Create Organization Invitation"
  description  = "Invites an user to an organization."

  param "token" {
    type        = string
    description = "The GitHub personal access token to authenticate to the GitHub APIs."
    default     = var.token
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
    title  = "Invite an user to org"
    url    = "https://api.github.com/orgs/${param.organization}/invitations"
    method = "post"
    request_headers = {
      Accept               = "application/vnd.github+json"
      Authorization        = "Bearer ${param.token}"
      X-GitHub-Api-Version = "2022-11-28"
    }

    request_body = jsonencode({
      email = "${param.email}"
      role  = "${param.role}"
    })
  }

}
