# GitHub Mod for Flowpipe

GitHub pipeline library for [Flowpipe](https://flowpipe.io), enabling seamless integration of GitHub services into your workflows.

## Documentation

- **[Pipelines →](https://hub.flowpipe.io/mods/turbot/github/pipelines)**

## Getting Started

### Installation

Download and install Flowpipe (https://flowpipe.io/downloads). Or use Brew:

```sh
brew tap turbot/tap
brew install flowpipe
```

Clone:

```sh
git clone https://github.com/turbot/flowpipe-mod-github.git
cd flowpipe-mod-github
```

### Connections

By default, the following environment variables will be used for authentication:

- `GITHUB_TOKEN`

You can also create `connection` resources in configuration files:

```sh
vi ~/.flowpipe/config/github.fpc
```

```hcl
connection "github" "default" {
  token = "ghp_..."
}
```

For more information on connections in Flowpipe, please see [Managing Connections](https://flowpipe.io/docs/run/connections).

### Usage

[Initialize a mod](https://flowpipe.io/docs/build/index#initializing-a-mod):

```sh
mkdir my_mod
cd my_mod
flowpipe mod init
```

[Install the GitHub mod](https://flowpipe.io/docs/build/mod-dependencies#mod-dependencies) as a dependency:

```sh
flowpipe mod install github.com/turbot/flowpipe-mod-github
```

[Use the dependency](https://flowpipe.io/docs/build/write-pipelines/index) in a pipeline step:

```sh
vi my_pipeline.fp
```

```hcl
pipeline "my_pipeline" {

  step "pipeline" "list_pull_requests" {
    pipeline = github.pipeline.list_pull_requests
    args = {
      repository_owner = "turbot"
      repository_name  = "flowpipe"
    }
  }
}
```

[Run the pipeline](https://flowpipe.io/docs/run/pipelines):

```sh
flowpipe pipeline run my_pipeline
```

### Developing

Clone:

```sh
git clone https://github.com/turbot/flowpipe-mod-github.git
cd flowpipe-mod-github
```

List pipelines:

```sh
flowpipe pipeline list
```

Run a pipeline:

```sh
flowpipe pipeline run get_issue_by_number --arg 'issue_number=3997' --arg 'repository_owner=turbot' --arg 'repository_name=flowpipe'
```

To use a specific `connection`, specify the `conn` pipeline argument:

```sh
flowpipe pipeline run get_issue_by_number --arg 'issue_number=3997' --arg 'repository_owner=turbot' --arg 'repository_name=flowpipe' --arg conn=github_profile
```

For more examples on how you can run pipelines, please see [Run Pipelines](https://flowpipe.io/docs/run/pipelines).

## Open Source & Contributing

This repository is published under the [Apache 2.0 license](https://www.apache.org/licenses/LICENSE-2.0). Please see our [code of conduct](https://github.com/turbot/.github/blob/main/CODE_OF_CONDUCT.md). We look forward to collaborating with you!

[Flowpipe](https://flowpipe.io) is a product produced from this open source software, exclusively by [Turbot HQ, Inc](https://turbot.com). It is distributed under our commercial terms. Others are allowed to make their own distribution of the software, but cannot use any of the Turbot trademarks, cloud services, etc. You can learn more in our [Open Source FAQ](https://turbot.com/open-source).

## Get Involved

**[Join #flowpipe on Slack →](https://flowpipe.io/community/join)**

Want to help but not sure where to start? Pick up one of the `help wanted` issues:

- [Flowpipe](https://github.com/turbot/flowpipe/labels/help%20wanted)
- [GitHub Mod](https://github.com/turbot/flowpipe-mod-github/labels/help%20wanted)
