# This pipeline requires that Steampipe is installed, the service is started, and the github plugin is installed.
# usage: flowpipe pipeline run list_issues_by_query --pipeline-arg repository_owner=turbot --pipeline-arg repository_name=steampipe-plugin-azure
pipeline "list_issues_by_query" {
  title       = "List Issues by Query"
  description = "List issues in the repository using a Steampipe query."

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

  param "issue_state" {
    type    = string
    default = "OPEN"
  }

  step "query" "list_issues_by_query" {
    connection_string = "postgres://steampipe@localhost:9193/steampipe"
    sql               = <<EOQ
      select
        number,
        url,
        title
      from
        github_issue
      where
        repository_full_name = '${param.repository_owner}/${param.repository_name}'
        and state = '${param.issue_state}'
      EOQ
  }

  output "rows" {
    description = "List of Issues."
    value       = step.query.list_issues_by_query.rows
  }

}
