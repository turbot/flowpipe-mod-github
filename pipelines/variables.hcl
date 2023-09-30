variable "repository_full_name" {
  type        = string
  description = "The full name of the GitHub repository. Exmaple1: 'owner/repository', Example2: 'turbot/flowpipe'"
  default     = "vkumbha/deleteme"
}

variable "github_token" {
  type        = string
  description = "The GitHub personal access token to authenticate to the GitHub APIs, e.g., `github_pat_a1b2c3d4e5f6g7h8i9j10k11l12m13n14o15p16q17r18s19t20u21v22w23x24y25z26`. Please see https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens for more information. Can also be set with the P_VAR_github_token environment variable."
  default     = null
}
