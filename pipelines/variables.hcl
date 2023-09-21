variable "github_owner" {
  type        = string
  description = "The account owner of the repository. The name is not case sensitive."
  default     = "octocat"
}

variable "github_repo" {
  type        = string
  description = "The name of the repository without the .git extension. The name is not case sensitive."
  default     = "hello-world"
}

