# Locale loading for sayabledate.
#
# Loads generated locale files from the locales/ directory using the
# registry pattern (lazy-loading with caching).

get_date_locale <- function(code) {
  registry_path <- system.file("locales", "registry.R", package = "sayabledate")
  if (registry_path == "") {
    pkg_dir <- find.package("sayabledate", quiet = TRUE)
    if (length(pkg_dir) == 0) {
      script_dir <- getwd()
      registry_path <- file.path(script_dir, "locales", "registry.R")
    } else {
      registry_path <- file.path(pkg_dir, "locales", "registry.R")
    }
  }
  env <- new.env(parent = baseenv())
  source(registry_path, local = env)
  env$get_date_locale(code)
}
