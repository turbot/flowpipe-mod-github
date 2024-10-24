pipeline "test_search_repositories" {
  title       = "Test Search Repositories"
  description = "Test the search_repositories pipeline."

  tags = {
    folder = "Tests"
  }

  param "conn" {
    type        = connection.github
    description = local.conn_param_description
    default     = connection.github.default
  }

  param "search_value" {
    type        = string
    description = "The search string to look for. Examples: steampipe, owner:turbot steampipe, repo:vkumbha/deleteme"
    default     = "test"
  }

  step "pipeline" "search_repositories" {
    pipeline = pipeline.search_repositories
    args = {
      conn         = param.conn
      search_value = param.search_value
    }
  }

  output "search_repositories" {
    description = "Check for pipeline.search_repositories."
    value       = !is_error(step.pipeline.search_repositories) ? "pass" : "fail: ${step.pipeline.search_repositories.errors}"
  }
}