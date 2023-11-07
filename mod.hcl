# TODO: Add missing pipeline param descriptions
mod "github" {
  title         = "GitHub Library"
  description   = "Run pipelines to supercharge your GitHub workflows using Flowpipe."
  color         = "#191717"
  documentation = file("./docs/index.md")
  icon          = "/images/flowpipe/mods/turbot/github.svg"
  categories    = ["github", "library"]

  opengraph {
    title       = "GitHub"
    description = "Run pipelines to supercharge your GitHub workflows using Flowpipe."
    image       = "/images/flowpipe/mods/turbot/github-social-graphic.png"
  }
}
