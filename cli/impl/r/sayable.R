# Sayable CLI -- unified command-line interface to all four Sayable components.
#
# See cli/SPEC.md for the full specification.

VERSION <- "0.5.0"

# Resolve project root relative to this script
get_script_dir <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    return(dirname(normalizePath(sub("^--file=", "", file_arg[1]))))
  }
  getwd()
}

script_dir <- get_script_dir()
project_root <- normalizePath(file.path(script_dir, "..", "..", ".."))

# Source all component libraries
source(file.path(project_root, "age", "impl", "r", "R", "format_age.R"))
source(file.path(project_root, "age", "impl", "r", "R", "locale.R"))
source(file.path(project_root, "date", "impl", "r", "R", "format_date.R"))
source(file.path(project_root, "date", "impl", "r", "R", "locale.R"))
source(file.path(project_root, "time", "impl", "r", "R", "format_time.R"))
source(file.path(project_root, "time", "impl", "r", "R", "locale.R"))
source(file.path(project_root, "duration", "impl", "r", "R", "format_duration.R"))
source(file.path(project_root, "duration", "impl", "r", "R", "locale.R"))

HELP_TEXT <- "Usage: sayable <command> [arguments] [options]

Commands:
  age <dob>              Format an age
  stage <dob>            Get developmental stage
  date <date>            Format a calendar date
  relative <date>        Format a relative date
  time <time>            Format a clock time
  duration <value> [end] Format a duration
  since <start>          Format elapsed time
  until <target>         Format remaining time
  locales                List available locale codes
  version                Show version
  help                   Show this help

Options:
  -l, --locale <code>    Locale code (default: en)
  -d, --as-of <value>    Reference date/timestamp
      --short            Short compactness
      --compact          Compact compactness
  -g, --gender <m|f>     Gender for stage labels
      --with-year        Include year (date only)
  -h, --help             Show this help
  -v, --version          Show version"

cli_error <- function(msg) {
  write(paste0("error: ", msg), stderr())
  write("Run 'sayable help' for usage.", stderr())
  quit(status = 2, save = "no")
}

nullify <- function(value) {
  if (identical(value, "null")) return(NULL)
  value
}

get_today <- function() {
  format(Sys.Date(), "%Y-%m-%d")
}

parse_args <- function(argv) {
  if (length(argv) == 0) {
    return(list(command = NULL, positionals = character(0), options = list()))
  }

  # Global flags as first argument
  if (argv[1] %in% c("-h", "--help", "help")) {
    return(list(command = "help", positionals = character(0), options = list()))
  }
  if (argv[1] %in% c("-v", "--version", "version")) {
    return(list(command = "version", positionals = character(0), options = list()))
  }

  command <- argv[1]
  positionals <- character(0)
  options <- list(
    locale = "en",
    as_of = NULL,
    compactness = "normal",
    gender = NULL,
    with_year = FALSE
  )

  i <- 2
  stop_opts <- FALSE
  while (i <= length(argv)) {
    arg <- argv[i]

    if (identical(arg, "--") && !stop_opts) {
      stop_opts <- TRUE
      i <- i + 1
      next
    }

    if (!stop_opts && startsWith(arg, "-")) {
      if (arg %in% c("-l", "--locale")) {
        if (i + 1 > length(argv)) cli_error(paste0("'", arg, "' requires a value"))
        i <- i + 1
        options$locale <- argv[i]
      } else if (arg %in% c("-d", "--as-of")) {
        if (i + 1 > length(argv)) cli_error(paste0("'", arg, "' requires a value"))
        i <- i + 1
        options$as_of <- argv[i]
      } else if (arg %in% c("-g", "--gender")) {
        if (i + 1 > length(argv)) cli_error(paste0("'", arg, "' requires a value"))
        i <- i + 1
        options$gender <- argv[i]
      } else if (identical(arg, "--short")) {
        options$compactness <- "short"
      } else if (identical(arg, "--compact")) {
        options$compactness <- "compact"
      } else if (identical(arg, "--with-year")) {
        options$with_year <- TRUE
      } else if (arg %in% c("-h", "--help")) {
        return(list(command = "help", positionals = character(0), options = list()))
      } else if (arg %in% c("-v", "--version")) {
        return(list(command = "version", positionals = character(0), options = list()))
      } else {
        cli_error(paste0("unknown option '", arg, "'"))
      }
    } else {
      positionals <- c(positionals, arg)
    }

    i <- i + 1
  }

  list(command = command, positionals = positionals, options = options)
}

# Locale caches (one per component)
.cli_locale_cache <- new.env(parent = emptyenv())

# Load a locale by directly sourcing the locale file.
# The registry uses sys.frame()$ofile which breaks when sourced from CLI context,
# so we bypass it and load locale files directly.
load_component_locale <- function(component, code) {
  cache_key <- paste0(component, ":", code)
  if (exists(cache_key, envir = .cli_locale_cache)) {
    return(get(cache_key, envir = .cli_locale_cache))
  }
  locale_dir <- file.path(project_root, component, "impl", "r", "locales")
  path <- file.path(locale_dir, paste0(code, ".R"))
  if (!file.exists(path)) return(NULL)
  env <- new.env(parent = baseenv())
  source(path, local = env)
  var_name <- paste0("locale_", gsub("-", "_", code))
  if (!exists(var_name, envir = env)) return(NULL)
  locale <- get(var_name, envir = env)
  assign(cache_key, locale, envir = .cli_locale_cache)
  locale
}

load_age_locale <- function(code) load_component_locale("age", code)
load_date_locale <- function(code) load_component_locale("date", code)
load_time_locale <- function(code) load_component_locale("time", code)
load_duration_locale <- function(code) load_component_locale("duration", code)

cmd_age <- function(positionals, options) {
  if (length(positionals) == 0) cli_error("age requires a date-of-birth argument")
  dob <- nullify(positionals[1])

  locale_code <- options$locale
  locale <- load_age_locale(locale_code)
  if (is.null(locale)) cli_error(paste0("unknown locale '", locale_code, "'"))

  as_of <- options$as_of
  if (!is.null(as_of)) {
    as_of <- nullify(as_of)
  } else {
    as_of <- get_today()
  }

  formatter <- sayable_age_new(locale, options$compactness)
  result <- formatter$format_age(dob, as_of)

  if (is.null(result)) quit(status = 1, save = "no")
  cat(result, "\n", sep = "")
}

cmd_stage <- function(positionals, options) {
  if (length(positionals) == 0) cli_error("stage requires a date-of-birth argument")
  dob <- nullify(positionals[1])

  locale_code <- options$locale
  locale <- load_age_locale(locale_code)
  if (is.null(locale)) cli_error(paste0("unknown locale '", locale_code, "'"))

  as_of <- options$as_of
  if (!is.null(as_of)) {
    as_of <- nullify(as_of)
  } else {
    as_of <- get_today()
  }

  gender <- options$gender

  formatter <- sayable_age_new(locale, options$compactness)
  result <- formatter$format_stage(dob, as_of, gender)

  if (is.null(result)) quit(status = 1, save = "no")
  cat(result, "\n", sep = "")
}

cmd_date <- function(positionals, options) {
  if (length(positionals) == 0) cli_error("date requires a date argument")
  date_val <- nullify(positionals[1])

  locale_code <- options$locale
  locale <- load_date_locale(locale_code)
  if (is.null(locale)) cli_error(paste0("unknown locale '", locale_code, "'"))

  formatter <- sayable_date_new(locale, options$compactness)

  if (isTRUE(options$with_year)) {
    result <- formatter$format_date_with_year(date_val)
  } else {
    result <- formatter$format_date(date_val)
  }

  if (is.null(result)) quit(status = 1, save = "no")
  cat(result, "\n", sep = "")
}

cmd_relative <- function(positionals, options) {
  if (length(positionals) == 0) cli_error("relative requires a date argument")
  date_val <- nullify(positionals[1])

  as_of <- options$as_of
  if (is.null(as_of)) cli_error("relative requires --as-of / -d option")
  as_of <- nullify(as_of)

  locale_code <- options$locale
  locale <- load_date_locale(locale_code)
  if (is.null(locale)) cli_error(paste0("unknown locale '", locale_code, "'"))

  formatter <- sayable_date_new(locale, options$compactness)
  result <- formatter$format_relative(date_val, as_of)

  if (is.null(result)) quit(status = 1, save = "no")
  cat(result, "\n", sep = "")
}

cmd_time <- function(positionals, options) {
  if (length(positionals) == 0) cli_error("time requires a time argument")
  time_val <- nullify(positionals[1])

  locale_code <- options$locale
  locale <- load_time_locale(locale_code)
  if (is.null(locale)) cli_error(paste0("unknown locale '", locale_code, "'"))

  formatter <- sayable_time_new(locale, options$compactness)
  result <- formatter$format_time(time_val)

  if (is.null(result)) quit(status = 1, save = "no")
  cat(result, "\n", sep = "")
}

cmd_duration <- function(positionals, options) {
  if (length(positionals) == 0) cli_error("duration requires a value argument")
  value <- nullify(positionals[1])

  locale_code <- options$locale
  locale <- load_duration_locale(locale_code)
  if (is.null(locale)) cli_error(paste0("unknown locale '", locale_code, "'"))

  formatter <- sayable_duration_new(locale, options$compactness)

  if (is.null(value)) {
    result <- formatter$format_duration(NULL)
  } else if (grepl("^-?[0-9]+$", value)) {
    result <- formatter$format_duration(as.integer(value))
  } else {
    # Timestamp mode
    if (length(positionals) < 2) {
      cli_error("duration with timestamps requires start and end arguments")
    }
    end_val <- nullify(positionals[2])
    result <- formatter$format_duration_iso(value, end_val)
  }

  if (is.null(result)) quit(status = 1, save = "no")
  cat(result, "\n", sep = "")
}

cmd_since <- function(positionals, options) {
  if (length(positionals) == 0) cli_error("since requires a start timestamp argument")
  start <- nullify(positionals[1])

  as_of <- options$as_of
  if (is.null(as_of)) cli_error("since requires --as-of / -d option")
  as_of <- nullify(as_of)

  locale_code <- options$locale
  locale <- load_duration_locale(locale_code)
  if (is.null(locale)) cli_error(paste0("unknown locale '", locale_code, "'"))

  formatter <- sayable_duration_new(locale, options$compactness)
  result <- formatter$format_since(start, as_of)

  if (is.null(result)) quit(status = 1, save = "no")
  cat(result, "\n", sep = "")
}

cmd_until <- function(positionals, options) {
  if (length(positionals) == 0) cli_error("until requires a target timestamp argument")
  target <- nullify(positionals[1])

  as_of <- options$as_of
  if (is.null(as_of)) cli_error("until requires --as-of / -d option")
  as_of <- nullify(as_of)

  locale_code <- options$locale
  locale <- load_duration_locale(locale_code)
  if (is.null(locale)) cli_error(paste0("unknown locale '", locale_code, "'"))

  formatter <- sayable_duration_new(locale, options$compactness)
  result <- formatter$format_until(target, as_of)

  if (is.null(result)) quit(status = 1, save = "no")
  cat(result, "\n", sep = "")
}

cmd_locales <- function() {
  locale_dir <- file.path(project_root, "age", "impl", "r", "locales")
  files <- list.files(locale_dir, pattern = "^[^.][^/]*\\.R$")
  # Exclude registry.R
  files <- files[files != "registry.R"]
  codes <- sub("\\.R$", "", files)
  codes <- sort(codes)
  for (code in codes) {
    cat(code, "\n", sep = "")
  }
}

main <- function() {
  argv <- commandArgs(trailingOnly = TRUE)
  parsed <- parse_args(argv)

  command <- parsed$command
  positionals <- parsed$positionals
  options <- parsed$options

  if (is.null(command)) {
    cat(HELP_TEXT, "\n", sep = "")
    quit(status = 2, save = "no")
  }

  if (identical(command, "help")) {
    cat(HELP_TEXT, "\n", sep = "")
    quit(status = 0, save = "no")
  }

  if (identical(command, "version")) {
    cat("sayable ", VERSION, "\n", sep = "")
    quit(status = 0, save = "no")
  }

  if (identical(command, "locales")) {
    cmd_locales()
    quit(status = 0, save = "no")
  }

  commands <- list(
    age = cmd_age,
    stage = cmd_stage,
    date = cmd_date,
    relative = cmd_relative,
    time = cmd_time,
    duration = cmd_duration,
    since = cmd_since,
    until = cmd_until
  )

  if (is.null(commands[[command]])) {
    cli_error(paste0("unknown command '", command, "'"))
  }

  commands[[command]](positionals, options)
}

main()
