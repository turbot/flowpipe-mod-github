# TODO: Remove defaults once the bug in dependency mods is fixed
variable "access_token" {
  type        = string
  description = "The GitHub personal access token to authenticate to the GitHub APIs."
  default     = ""
}

variable "repository_full_name" {
  type        = string
  description = "The full name of the GitHub repository. Examples: turbot/steampipe, turbot/flowpipe"
  default     = ""
}
