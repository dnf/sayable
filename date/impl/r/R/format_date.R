# Human-friendly date formatting.
#
# Formats dates the way people reference them in conversation:
# "today", "next Thursday", "March 15th", "April 10, 2024".
# Zero runtime dependencies.

parse_date_str <- function(s) {
  if (is.null(s) || !is.character(s) || nchar(s) == 0) return(NULL)

  # Strip time part from ISO datetime
  date_part <- s
  t_idx <- regexpr("T", s, fixed = TRUE)
  if (t_idx > 0) date_part <- substring(s, 1, t_idx - 1)

  parts <- strsplit(date_part, "-", fixed = TRUE)[[1]]
  if (length(parts) != 3) return(NULL)

  year <- suppressWarnings(as.integer(parts[1]))
  month <- suppressWarnings(as.integer(parts[2]))
  day <- suppressWarnings(as.integer(parts[3]))
  if (is.na(year) || is.na(month) || is.na(day)) return(NULL)
  if (month < 1 || month > 12 || day < 1 || day > 31) return(NULL)

  list(year = year, month = month, day = day)
}

to_jdn <- function(year, month, day) {
  a <- floor((14 - month) / 12)
  y <- year + 4800 - a
  m <- month + 12 * a - 3
  day + floor((153 * m + 2) / 5) + 365 * y + floor(y / 4) - floor(y / 100) + floor(y / 400) - 32045
}

weekday_num <- function(year, month, day) {
  (to_jdn(year, month, day) + 1) %% 7
}

pick_date <- function(override, attr, default) {
  if (!is.null(override)) {
    val <- override[[attr]]
    if (!is.null(val)) return(val)
  }
  default
}

#' Create a new SayableDate formatter.
#'
#' @param locale The locale list to use
#' @param compactness "normal", "short", or "compact" (default: "normal")
#' @return A list with format_date, format_date_with_year, and format_relative functions
sayable_date_new <- function(locale, compactness = "normal") {
  ovr <- NULL
  if (compactness == "short") {
    ovr <- locale$short
  } else if (compactness == "compact") {
    ovr <- locale$compact
  }

  months <- if (!is.null(ovr) && !is.null(ovr$months)) ovr$months else locale$months
  months_in_date <- if (!is.null(ovr) && !is.null(ovr$months_in_date)) {
    ovr$months_in_date
  } else if (!is.null(locale$months_in_date)) {
    locale$months_in_date
  } else {
    NULL
  }
  weekdays_names <- if (!is.null(ovr) && !is.null(ovr$weekdays)) ovr$weekdays else locale$weekdays

  # When override provides day_format but not day_format_exceptions, clear exceptions
  if (!is.null(ovr) && !is.null(ovr$day_format) && is.null(ovr$day_format_exceptions)) {
    day_format <- ovr$day_format
    day_format_exceptions <- list()
  } else {
    day_format <- if (!is.null(ovr) && !is.null(ovr$day_format)) ovr$day_format else locale$day_format
    day_format_exceptions <- if (!is.null(ovr) && !is.null(ovr$day_format_exceptions)) {
      ovr$day_format_exceptions
    } else if (!is.null(locale$day_format_exceptions)) {
      locale$day_format_exceptions
    } else {
      list()
    }
  }

  date_pattern <- if (!is.null(ovr) && !is.null(ovr$date_pattern)) ovr$date_pattern else locale$date_pattern
  date_pattern_with_year <- if (!is.null(ovr) && !is.null(ovr$date_pattern_with_year)) {
    ovr$date_pattern_with_year
  } else {
    locale$date_pattern_with_year
  }
  today_str <- if (!is.null(ovr) && !is.null(ovr$today)) ovr$today else locale$today
  tomorrow_str <- if (!is.null(ovr) && !is.null(ovr$tomorrow)) ovr$tomorrow else locale$tomorrow
  yesterday_str <- if (!is.null(ovr) && !is.null(ovr$yesterday)) ovr$yesterday else locale$yesterday

  is_compact <- compactness == "compact"

  format_absolute <- function(year, month, day, include_year) {
    day_str <- as.character(day)
    fmt <- day_format_exceptions[[day_str]]
    if (is.null(fmt)) fmt <- day_format
    formatted_day <- gsub("{n}", day_str, fmt, fixed = TRUE)

    # Pick month name (genitive form if available)
    month_name <- if (!is.null(months_in_date)) months_in_date[month] else months[month]

    pattern <- if (include_year) date_pattern_with_year else date_pattern
    result <- gsub("{month}", month_name, pattern, fixed = TRUE)
    result <- gsub("{day}", formatted_day, result, fixed = TRUE)
    result <- gsub("{d}", as.character(day), result, fixed = TRUE)
    result <- gsub("{m}", as.character(month), result, fixed = TRUE)
    if (include_year) {
      result <- gsub("{year}", as.character(year), result, fixed = TRUE)
      yy <- year %% 100
      result <- gsub("{yy}", sprintf("%02d", yy), result, fixed = TRUE)
    }

    result
  }

  format_date_fn <- function(date) {
    if (is.null(date) || !is.character(date) || nchar(date) == 0) return(NULL)
    parsed <- parse_date_str(date)
    if (is.null(parsed)) return(NULL)
    format_absolute(parsed$year, parsed$month, parsed$day, FALSE)
  }

  format_date_with_year_fn <- function(date) {
    if (is.null(date) || !is.character(date) || nchar(date) == 0) return(NULL)
    parsed <- parse_date_str(date)
    if (is.null(parsed)) return(NULL)
    format_absolute(parsed$year, parsed$month, parsed$day, TRUE)
  }

  format_relative_fn <- function(date, as_of) {
    if (is.null(date) || !is.character(date) || nchar(date) == 0) return(NULL)
    if (is.null(as_of) || !is.character(as_of) || nchar(as_of) == 0) return(NULL)

    d <- parse_date_str(date)
    a <- parse_date_str(as_of)
    if (is.null(d) || is.null(a)) return(NULL)

    date_jdn <- to_jdn(d$year, d$month, d$day)
    asof_jdn <- to_jdn(a$year, a$month, a$day)
    diff <- date_jdn - asof_jdn

    # Today
    if (diff == 0) return(today_str)

    # Tomorrow
    if (diff == 1) return(tomorrow_str)

    # Yesterday
    if (diff == -1) return(yesterday_str)

    # Day after tomorrow (optional, skipped in compact mode)
    if (diff == 2 && !is.null(locale$day_after_tomorrow) && !is_compact) {
      return(locale$day_after_tomorrow)
    }

    # Day before yesterday (optional, skipped in compact mode)
    if (diff == -2 && !is.null(locale$day_before_yesterday) && !is_compact) {
      return(locale$day_before_yesterday)
    }

    # Compact mode: skip weekday references, go straight to calendar date
    if (is_compact) {
      return(format_absolute(d$year, d$month, d$day, d$year != a$year))
    }

    # This weekday (+2 to +6)
    if (diff >= 2 && diff <= 6 && !is.null(locale$this_weekday)) {
      dow <- weekday_num(d$year, d$month, d$day)
      # R is 1-indexed: weekdays[1] = Sunday (dow 0)
      wd_name <- weekdays_names[dow + 1]
      return(gsub("{weekday}", wd_name, locale$this_weekday, fixed = TRUE))
    }

    # Last weekday (-6 to -2)
    if (diff >= -6 && diff <= -2 && !is.null(locale$last_weekday)) {
      dow <- weekday_num(d$year, d$month, d$day)
      wd_name <- weekdays_names[dow + 1]
      return(gsub("{weekday}", wd_name, locale$last_weekday, fixed = TRUE))
    }

    # Next weekday (+7 to +13)
    if (diff >= 7 && diff <= 13 && !is.null(locale$next_weekday)) {
      dow <- weekday_num(d$year, d$month, d$day)
      wd_name <- weekdays_names[dow + 1]
      return(gsub("{weekday}", wd_name, locale$next_weekday, fixed = TRUE))
    }

    # Calendar fallback
    format_absolute(d$year, d$month, d$day, d$year != a$year)
  }

  list(
    format_date = format_date_fn,
    format_date_with_year = format_date_with_year_fn,
    format_relative = format_relative_fn
  )
}

#' Format a date using the default English locale.
#'
#' @param date "YYYY-MM-DD" or ISO datetime string
#' @param locale Locale list (defaults to English)
#' @param compactness "normal", "short", or "compact" (default: "normal")
#' @return Formatted date string, or NULL
format_date <- function(date, locale = NULL, compactness = "normal") {
  if (is.null(locale)) {
    locale <- load_default_date_locale()
  }
  sd <- sayable_date_new(locale, compactness)
  sd$format_date(date)
}

#' Format a relative date using the default English locale.
#'
#' @param date "YYYY-MM-DD" or ISO datetime string
#' @param as_of "YYYY-MM-DD" or ISO datetime string
#' @param locale Locale list (defaults to English)
#' @param compactness "normal", "short", or "compact" (default: "normal")
#' @return Formatted relative date string, or NULL
format_relative <- function(date, as_of, locale = NULL, compactness = "normal") {
  if (is.null(locale)) {
    locale <- load_default_date_locale()
  }
  sd <- sayable_date_new(locale, compactness)
  sd$format_relative(date, as_of)
}

load_default_date_locale <- function() {
  pkg_dir <- find.package("sayabledate", quiet = TRUE)
  if (length(pkg_dir) > 0) {
    locale_path <- file.path(pkg_dir, "locales", "en.R")
  } else {
    locale_path <- file.path(getwd(), "locales", "en.R")
  }
  env <- new.env(parent = baseenv())
  source(locale_path, local = env)
  env$locale_en
}
