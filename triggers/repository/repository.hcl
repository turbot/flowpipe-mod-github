// These are just examples to showcase how to use the triggers. The logs or output for these scheduled runs are to be found in the output folder (~/.flowpipe/output) - Its very hard to search for the right log file though!
// Should we instead use slack mod as dependent and send slack notifications???

// Schedule Trigger (Cron)
// Usecase: To get the count of stargazers of a repository everyweek.
// These results are saved in your output folder (~/.flowpipe/output)

trigger "schedule" "stargazer_count" {
  description = "Get the stargazers count of a repository (on cron) at 9AM every Monday UTC."
  schedule = "0 9 * * MON"
  pipeline = pipeline.repository_get
  args = {
    github_owner = "turbot"
    github_repo = "steampipe"
  }
}
