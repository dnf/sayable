# Human-friendly clock time formatting.
#
# Tells time the way people talk: "a quarter past three",
# "half past seven", "midnight".
# Zero runtime dependencies.

# A clock time (H:MM or HH:MM, optional :SS and fraction, optional zone
# suffix, which is ignored), alone or after the T of an ISO datetime.
CLOCK_TIME_PATTERN <- paste0(
  "^(?:([0-9]{4})-([0-9]{2})-([0-9]{2})T)?([0-9]{1,2}):([0-9]{2})",
  "(?::([0-9]{2})(?:\\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\\z"
)

is_real_date_time <- function(year, month, day) {
  if (month < 1 || month > 12 || day < 1) return(FALSE)
  leap <- (year %% 4 == 0 && year %% 100 != 0) || year %% 400 == 0
  last <- if (month == 2) (if (leap) 29 else 28) else if (month %in% c(4, 6, 9, 11)) 30 else 31
  day <= last
}

parse_time_str <- function(input) {
  if (!is.character(input) || length(input) != 1 || is.na(input)) return(NULL)
  m <- regmatches(input, regexec(CLOCK_TIME_PATTERN, input, perl = TRUE))[[1]]
  if (length(m) == 0) return(NULL)
  if (m[2] != "" && !is_real_date_time(as.integer(m[2]), as.integer(m[3]), as.integer(m[4]))) {
    return(NULL)
  }
  hour <- as.integer(m[5])
  minute <- as.integer(m[6])
  second <- if (m[7] == "") 0L else as.integer(m[7])
  if (hour > 23 || minute > 59 || second > 59) return(NULL)

  list(hour = hour, minute = minute)
}

round_to_5 <- function(minute) {
  floor((minute + 2) / 5) * 5
}

#' Create a new SayableTime formatter.
#'
#' @param locale The locale list to use
#' @param compactness "normal", "short", or "compact" (default: "normal")
#' @return A list with a format_time function
sayable_time_new <- function(locale, compactness = "normal") {
  short_clock <- NULL
  ovr <- NULL
  if (compactness == "short") {
    ovr <- locale$short
  } else if (compactness == "compact") {
    ovr <- locale$compact
  }
  if (!is.null(ovr)) {
    short_clock <- ovr$clock
  }

  format_natural <- function(hour, minute) {
    clock <- locale$clock
    rounded <- round_to_5(minute)
    h <- hour
    if (rounded == 60) {
      rounded <- 0
      h <- (h + 1) %% 24
    }
    if (rounded == 0) {
      if (h == 0) return(clock$midnight)
      if (h == 12) return(clock$noon)
    }
    h12 <- h %% 12
    next_h12 <- (h + 1) %% 12
    # R is 1-indexed: hours[1] = "twelve" (index 0 in other langs)
    h_name <- clock$hours[h12 + 1]
    next_h_name <- clock$hours[next_h12 + 1]
    key <- as.character(rounded)
    pattern <- clock$patterns[[key]]
    if (is.null(pattern)) pattern <- clock$patterns[["0"]]
    if (is.null(pattern)) pattern <- "{h}"
    result <- gsub("{h}", h_name, pattern, fixed = TRUE)
    result <- gsub("{next_h}", next_h_name, result, fixed = TRUE)
    result
  }

  format_digital <- function(hour, minute) {
    sc <- short_clock
    fmt <- sc$format
    if (isTRUE(sc$use24h)) {
      result <- gsub("{h}", as.character(hour), fmt, fixed = TRUE)
      result <- gsub("{mm}", sprintf("%02d", minute), result, fixed = TRUE)
      return(result)
    }
    h12 <- hour %% 12
    if (h12 == 0) h12 <- 12
    am_pm <- sc$am_pm
    if (is.null(am_pm)) am_pm <- c("AM", "PM")
    ampm_str <- if (hour < 12) am_pm[1] else am_pm[2]
    result <- gsub("{h}", as.character(h12), fmt, fixed = TRUE)
    result <- gsub("{mm}", sprintf("%02d", minute), result, fixed = TRUE)
    result <- gsub("{ampm}", ampm_str, result, fixed = TRUE)
    result
  }

  format_time_fn <- function(input) {
    if (is.null(input) || !is.character(input) || nchar(input) == 0) return(NULL)
    parsed <- parse_time_str(input)
    if (is.null(parsed)) return(NULL)

    if (!is.null(short_clock)) {
      return(format_digital(parsed$hour, parsed$minute))
    }
    format_natural(parsed$hour, parsed$minute)
  }

  list(format_time = format_time_fn)
}

#' Format a time as a natural language clock reading.
#'
#' @param input "HH:MM" or ISO datetime string
#' @param locale Locale list (defaults to English)
#' @param compactness "normal", "short", or "compact" (default: "normal")
#' @return Formatted time string, or NULL
format_time <- function(input, locale = NULL, compactness = "normal") {
  if (is.null(locale)) {
    locale <- load_default_time_locale()
  }
  st <- sayable_time_new(locale, compactness)
  st$format_time(input)
}

load_default_time_locale <- function() {
  pkg_dir <- find.package("sayabletime", quiet = TRUE)
  if (length(pkg_dir) > 0) {
    locale_path <- file.path(pkg_dir, "locales", "en.R")
  } else {
    locale_path <- file.path(getwd(), "locales", "en.R")
  }
  env <- new.env(parent = baseenv())
  source(locale_path, local = env)
  env$locale_en
}
