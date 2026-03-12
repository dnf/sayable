library(testthat)

# Determine package root directory
args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("--file=", args, value = TRUE)
if (length(file_arg) > 0) {
  script_path <- sub("--file=", "", file_arg[1])
  pkg_root <- normalizePath(file.path(dirname(script_path), ".."))
} else {
  pkg_root <- normalizePath(file.path(getwd()))
}

# Set package root as working directory
setwd(pkg_root)

# Source all R files from package root
for (f in list.files("R", pattern = "\\.R$", full.names = TRUE)) {
  source(f)
}

# Store package root for test files to use
.pkg_root <- pkg_root

test_dir("tests/testthat", reporter = "summary")
