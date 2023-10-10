// NOTE: Make sure the github plugin is installed and steampipe service is up and running.
pipeline "issue_list_by_query" {
  description = "List of all Open issues in the repository using steampipe query."

  param "token" {
    type    = string
    default = var.token
  }

  param "repository_owner" {
    type    = string
    default = local.repository_owner
  }

  param "repository_name" {
    type    = string
    default = local.repository_name
  }

  param "issue_state" {
    type = string
    default = "OPEN"
  }

  param "repository_full_name" {
    type    = string
    default = var.repository_full_name
  }

  step "query" "issue_list_by_query" {
    connection_string = "postgres://steampipe@localhost:9193/steampipe"
    sql = <<EOQ
      select
        number,
        url,
        title,
        body
      from
        github_issue
      where
        repository_full_name = '${param.repository_owner}/${param.repository_name}'
        and state = '${param.issue_state}'
      EOQ
  }

  output "rows" {
    value = step.query.issue_list_by_query.rows
  }

}
