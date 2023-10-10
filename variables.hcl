# TODO: Should these have defaults?
# Right now they do due to :
# panic: missing 2 variable values:
# repository_full_name not set
# token not set

variable "repository_full_name" {
  type        = string
  description = "The full name of the GitHub repository. Examples: turbot/steampipe, turbot/flowpipe"
  default     = "cbruno10/github-api-test"
}

variable "token" {
  type        = string
  description = "The GitHub personal access token to authenticate to the GitHub APIs, e.g., `github_pat_a1b2c3d4e5f6g7h8i9j10k11l12m13n14o15p16q17r18s19t20u21v22w23x24y25z26`. Please see https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens for more information."
  default     = ""
}
