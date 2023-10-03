// NOTE: Make sure the github plugin is installed and steampipe service is up and running.
pipeline "issue_list_by_query" {
  description = "List of all Open issues in the repository using steampipe query."

  param "github_token" {
    type    = string
    default = var.github_token
  }

  param "github_owner" {
    type    = string
    default = local.github_owner
  }

  param "github_repo" {
    type    = string
    default = local.github_repo
  }

  // TODO: use params in the where clause. Causes a panic error right now. Check later!
  // https://github.com/turbot/flowpipe/issues/82
  step "query" "issue_list_by_query" {
    connection_string = "postgres://steampipe@localhost:9193/steampipe"
    sql               = "select number,url,title,body from github_issue where repository_full_name ='turbot/steampipe' and state = 'OPEN'"
  }

  output "rows" {
    value = step.query.issue_list_by_query.rows
  }

}
