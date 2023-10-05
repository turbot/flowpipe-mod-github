// These are just examples to showcase how to use the triggers. The logs or output for these scheduled runs are to be found in the output folder (~/.flowpipe/output) - Its very hard to search for the right log file though!
// Should we instead use slack mod as dependent and send slack notifications???

// Interval Trigger
// Usecase: To get the total count and list of open pull requests of a repository daily.
trigger "interval" "pull_request_list" {
  description = "Get the count and list of open pull requests in a repository at daily interval."
  schedule = "daily"
  pipeline = pipeline.pull_request_list
  args = {
    github_owner = "turbot"
    github_repo = "steampipe"
    pull_request_limit = 10
  }
}