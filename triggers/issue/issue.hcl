// Instant trigger
// Usecase: Trigger a pipeline based on a live event. The trigger in this case is new issue creation and the action is calling the issue_comment pipeline

trigger "http" "create_issue_event_add_comment" {
  description = "Add a comment on a newly opened issue based on live event issues.opened"

  pipeline = pipeline.router_issue_create
  args = {
    request_body = self.request_body
    event        = join(".", [self.request_headers["X-Github-Event"], jsondecode(self.request_body).action])
  }
}

pipeline "router_issue_create" {
  description = "Triggers are light weight and do not support conditions. Using an additional pipeline to customize the actions."

  param "event" {
    type = string
  }

  param "request_body" {
    type = string
  }

  // Only if the event is issues.opened i.e a new issue is created.
  step "pipeline" "to_comment_or_not" {
    if       = "${param.event}" == "issues.opened"
    pipeline = pipeline.issue_comment
    args = {
      github_owner = split("/", jsondecode(param.request_body).repository.full_name)[0]
      github_repo  = split("/", jsondecode(param.request_body).repository.full_name)[1]
      issue_number = jsondecode(param.request_body).issue.number
      comment      = "Hello @${jsondecode(param.request_body).sender.login}. Thanks for raising the issue, we will take a look and respond at the earliest! Thank you!"
    }

  }
}

// NOT IMPLEMENTED YET
// trigger "query" "stale_issues" {
//   description = "Look for stale issue and trigger only when a stale issue is found."
//   // schedule = "hourly"
//   // schedule = "* * * * THU"
//   schedule = "0 9 * * MON"
//   sql      = <<EOQ
//         select
//           number,
//           url,
//           title,
//           created_at
//         from
//           github_issue
//         where
//           repository_full_name = 'vkumbha/deleteme'
//           and state = 'OPEN'
//           and updated_at > now() - interval '1 days'
//     EOQ

//   # Only run the pipeline when keys are newly discovered to have expired
//   events      = ["insert"]
//   primary_key = "number"

//   pipeline = pipeline.echo_stale_issues
//   args = {
//     stale_issues = self.inserted_rows
//   }
// }

// pipeline "echo_stale_issues" {

//   param "stale_issues" {
//     type = string
//   }
//   step "echo" "echo_stale_issues" {
//     text = "These are the stale issues: ${param.stale_issues}"
//   }
// }
