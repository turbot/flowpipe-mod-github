mod "github" {
  title         = "GitHub"
  description   = "Run pipelines to supercharge your GitHub workflows using Flowpipe."
  color         = "#191717"
  documentation = file("./README.md")
  icon          = "/images/mods/turbot/github.svg"
  categories    = ["library", "software development"]

  opengraph {
    title       = "GitHub Mod for Flowpipe"
    description = "Run pipelines to supercharge your GitHub workflows using Flowpipe."
    image       = "/images/mods/turbot/github-social-graphic.png"
  }

  require {
    flowpipe {
      min_version = "1.0.0"
    }
  }
}
