// Instant trigger
// Usecase: Trigger a pipeline based on a live event. The trigger in this case is new issue creation and the action is calling the issue_comment pipeline

trigger "http" "notify_on_public_repo_creation_make_it_private_on_demand" {
  description = "Notify organization owner on public repository creation and provide them option to make it private"

  pipeline = pipeline.notify_in_slack_for_public_repo_creation
  args = {
    request_body          = self.request_body
    is_private_repository = join(".", [self.request_headers["X-Github-Event"], jsondecode(self.request_body).action]) == "repository.created" ? jsondecode(self.request_body).repository.private : false
    github_login          = jsondecode(self.request_body).repository.owner.login
    github_repo           = jsondecode(self.request_body).repository.name
    event                 = join(".", [self.request_headers["X-Github-Event"], jsondecode(self.request_body).action])
    msg                   = "Here! \t\t"
  }
}

pipeline "notify_in_slack_for_public_repo_creation" {
  description = "Triggers are light weight and do not support conditions. Using an additional pipeline to customize the actions."

  param "event" {
    type = string
  }

  param "request_body" {
    type = string
  }

  param "msg" {
    type = string
  }
  param "github_repo" {
    type = string
  }
  param "is_private_repository" {
    type    = bool
    default = false
  }
  param "github_login" {
    type = string
  }
  param "github_token" {
    type    = string
    default = var.github_token
  }

  // Only if the event is issues.opened i.e a new issue is created.
  step "pipeline" "get_gitub_repository_event_data" {
    if       = contains(["repository.created"], param.event)
    pipeline = slack.pipeline.chat_post_message
    args = {
      message = "A repository named '${param.github_repo}' has been created with in the organization '${param.github_login}' with visibility ${param.is_private_repository == false ? "PUBLIC" : "PRIVATE"}."
    }
  }

  step "http" "make_repo_private" {
    if     = (param.is_private_repository == false && contains(["repository.created"], param.event))
    method = "post"
    url    = "https://api.github.com/repos/${param.github_login}/${param.github_repo}"
    request_headers = {
      Accept               = "application/vnd.github+json"
      Authorization        = "Bearer ${param.github_token}"
      X-GitHub-Api-Version = "2022-11-28"
    }
    request_body = jsonencode({
      name    = jsondecode(param.request_body).repository.name
      private = true
    })
  }

  step "pipeline" "notify_user_after_taking_action" {
    if         = (param.is_private_repository == false && contains(["repository.created"], param.event))
    depends_on = [step.http.make_repo_private]
    pipeline   = slack.pipeline.chat_post_message
    args = {
      message = "The repo visibility successfully changed to private!."
    }
  }
  step "pipeline" "notify_user_with__no_action" {
    if       = param.is_private_repository == true
    pipeline = slack.pipeline.chat_post_message
    args = {
      message = "No action needed!!"
    }
  }
}