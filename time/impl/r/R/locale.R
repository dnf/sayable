# Locale loading for sayabletime.
#
# Loads generated locale files from the locales/ directory using the
# registry pattern (lazy-loading with caching).

get_time_locale <- function(code) {
  registry_path <- system.file("locales", "registry.R", package = "sayabletime")
  if (registry_path == "") {
    pkg_dir <- find.package("sayabletime", quiet = TRUE)
    if (length(pkg_dir) == 0) {
      script_dir <- getwd()
      registry_path <- file.path(script_dir, "locales", "registry.R")
    } else {
      registry_path <- file.path(pkg_dir, "locales", "registry.R")
    }
  }
  env <- new.env(parent = baseenv())
  source(registry_path, local = env)
  env$get_time_locale(code)
}
