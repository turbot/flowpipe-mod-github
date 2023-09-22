trigger "schedule" "my_weekly_triggers" {
    schedule = "0 0 * * MON"
    pipeline = pipeline.my_notification_pipeline
    args = {
        github_token = "github_pat_abcdefghijklmnopqrstuvwxtz"
        github_owner = "vkumbha"
        github_repo = "deleteme"
    }
}