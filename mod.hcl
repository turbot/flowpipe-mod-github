mod "github_mod" {
  title = "GitHub Flowpipe Mod"
  description   = "Run pipelines and triggers that interact with Github."
  color         = "#7C2852"
  documentation = file("./docs/index.md")
  icon          = "/images/flowpipe/mods/turbot/github.svg"
  categories    = ["github"]

  opengraph {
    title       = "Github"
    description = "Run pipelines and triggers that interact with github."
    image       = "/images/flowpipe/mods/turbot/github-social-graphic.png"
  }

  require {
    mod "github.com/turbot/flowpipe-mod-slack" {
      version = "*"
      args = {
        token   = var.slack_token
        channel = var.slack_channel
      }
    }
  }
}
