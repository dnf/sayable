# Locale loading for sayableage.
#
# Loads generated locale files from the locales/ directory using the
# registry pattern (lazy-loading with caching).

get_age_locale <- function(code) {
  registry_path <- system.file("locales", "registry.R", package = "sayableage")
  if (registry_path == "") {
    # Fallback: source relative to this file's location
    pkg_dir <- find.package("sayableage", quiet = TRUE)
    if (length(pkg_dir) == 0) {
      # Development mode: look relative to R/ directory
      script_dir <- getwd()
      registry_path <- file.path(script_dir, "locales", "registry.R")
    } else {
      registry_path <- file.path(pkg_dir, "locales", "registry.R")
    }
  }
  env <- new.env(parent = baseenv())
  source(registry_path, local = env)
  env$get_age_locale(code)
}
