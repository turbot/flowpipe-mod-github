trigger "schedule" "my_weekly_triggers" {
    schedule = "0 0 * * MON"
    pipeline = pipeline.my_notification_pipeline
    args = {
        github_token = var.github_token
        github_owner = "vkumbha"
        github_repo = "deleteme"
    }
}