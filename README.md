# flowpipe-mod-github

## Pipelines

| MOD        | NAME                                          | DESCRIPTION                                                                            |
|------------|-----------------------------------------------|----------------------------------------------------------------------------------------|
| github_mod | github_mod.pipeline.issue_add_assignee        | Add assignee(s) to an issue in a repository.                                           |
| github_mod | github_mod.pipeline.issue_close               | Close an Issue in a repository.                                                        |
| github_mod | github_mod.pipeline.issue_comment             | Create a comment on an Issue.                                                          |
| github_mod | github_mod.pipeline.issue_create              | Create a new issue.                                                                    |
| github_mod | github_mod.pipeline.issue_get                 | Get issue details from the current repository by number.                               |
| github_mod | github_mod.pipeline.issue_list                | List of Open issues in the repository.                                                 |
| github_mod | github_mod.pipeline.issue_search              | Find an issue in a repository.                                                         |
| github_mod | github_mod.pipeline.issue_update              | Update an Issue in a repository.                                                       |
| github_mod | github_mod.pipeline.list_issues_with_sp_query | List of all Open issues in the repository using steampipe query.                       |
| github_mod | github_mod.pipeline.pull_request_close        | Close a pull request in a repository.                                                  |
| github_mod | github_mod.pipeline.pull_request_comment      | Create a comment on pull request.                                                      |
| github_mod | github_mod.pipeline.pull_request_create       | Create a Pull request.                                                                 |
| github_mod | github_mod.pipeline.pull_request_get          | Get the details of a Pull Request.                                                     |
| github_mod | github_mod.pipeline.pull_request_list         | List of Open Pull Requests in the repository.                                          |
| github_mod | github_mod.pipeline.pull_request_search       | Find a pull request in a repository.                                                   |
| github_mod | github_mod.pipeline.pull_request_update       | Update a Pull Request in a repository.                                                 |
| github_mod | github_mod.pipeline.repository_create         | Create a new repository.                                                               |
| github_mod | github_mod.pipeline.repository_get            | Get the details of a given repository by the owner and repository name.                |
| github_mod | github_mod.pipeline.repository_get_owner      | Get the details of a repository owner (ie. either a User or an Organization) by login. |
| github_mod | github_mod.pipeline.repository_search         | Find a repository.                                                                     |
| github_mod | github_mod.pipeline.user_get_by_login         | Get the details of a user by login.                                                    |
| github_mod | github_mod.pipeline.user_get_current          | Get the details of currently authenticated user.                                       |

## Triggers

| PIPELINE                                | TYPE     | NAME                                                   | DESCRIPTION                                                                     |
|-----------------------------------------|----------|--------------------------------------------------------|---------------------------------------------------------------------------------|
| github_mod.pipeline.pull_request_list   | interval | github_mod.trigger.interval.pull_request_list          | Get the count and list of open pull requests in a repository at daily interval. |
| github_mod.pipeline.repository_get      | schedule | github_mod.trigger.schedule.stargazer_count            | Get the stargazers count of a repository (on cron) at 9AM every Monday UTC.     |
| github_mod.pipeline.router_issue_create | http     | github_mod.trigger.http.create_issue_event_add_comment | Add a comment on a newly opened issue based on live event issues.opened         |
