# Human-friendly duration formatting.
#
# Formats durations the way people speak:
# "just now", "3 minutes, 42 seconds", "2 1/2 hours", "1 year, 3 months ago".
# Zero runtime dependencies.

is_leap_year_dur <- function(y) {
  (y %% 4 == 0 && y %% 100 != 0) || (y %% 400 == 0)
}

days_in_month_dur <- function(y, m) {
  lengths <- c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
  if (m == 2 && is_leap_year_dur(y)) return(29)
  lengths[m]
}

days_since_epoch <- function(year, month, day) {
  days <- 0
  if (year >= 2000) {
    for (y in seq_len(max(0, year - 2000)) + 1999) {
      days <- days + ifelse(is_leap_year_dur(y), 366, 365)
    }
  } else {
    for (y in year:1999) {
      days <- days - ifelse(is_leap_year_dur(y), 366, 365)
    }
  }
  if (month > 1) {
    for (m in 1:(month - 1)) {
      days <- days + days_in_month_dur(year, m)
    }
  }
  days + day - 1
}

parse_iso_to_seconds <- function(iso) {
  if (is.null(iso) || !is.character(iso) || nchar(iso) == 0) return(NULL)

  t_idx <- regexpr("T", iso, fixed = TRUE)
  if (t_idx < 0) return(NULL)

  date_part <- substring(iso, 1, t_idx - 1)
  time_part <- substring(iso, t_idx + 1)

  # Parse date: YYYY-MM-DD
  dp <- strsplit(date_part, "-", fixed = TRUE)[[1]]
  if (length(dp) < 3) return(NULL)
  year <- suppressWarnings(as.integer(dp[1]))
  month <- suppressWarnings(as.integer(dp[2]))
  day <- suppressWarnings(as.integer(dp[3]))
  if (is.na(year) || is.na(month) || is.na(day)) return(NULL)

  # Strip timezone info
  plus_idx <- regexpr("+", time_part, fixed = TRUE)
  if (plus_idx > 0) time_part <- substring(time_part, 1, plus_idx - 1)
  z_idx <- regexpr("Z", time_part, fixed = TRUE)
  if (z_idx > 0) time_part <- substring(time_part, 1, z_idx - 1)

  # Parse time: HH:MM:SS
  tp <- strsplit(time_part, ":", fixed = TRUE)[[1]]
  hour <- suppressWarnings(as.integer(tp[1]))
  if (is.na(hour)) return(NULL)
  minute <- 0L
  if (length(tp) > 1) {
    minute <- suppressWarnings(as.integer(tp[2]))
    if (is.na(minute)) return(NULL)
  }
  second <- 0L
  if (length(tp) > 2) {
    # Strip fractional seconds
    sec_str <- sub("\\..*$", "", tp[3])
    second <- suppressWarnings(as.integer(sec_str))
    if (is.na(second)) return(NULL)
  }

  days <- days_since_epoch(year, month, day)
  days * 86400 + hour * 3600 + minute * 60 + second
}

resolve_unit_dur <- function(count, unit_forms, locale, half = "") {
  base_n <- as.character(count)
  if (!is.null(locale$format_number)) {
    base_n <- locale$format_number(count)
  }

  n <- base_n
  if (nchar(half) > 0 && grepl("{n}", half, fixed = TRUE)) {
    n <- gsub("{n}", base_n, half, fixed = TRUE)
  }

  if (is.character(unit_forms) && length(unit_forms) == 1 && is.null(names(unit_forms))) {
    template <- unit_forms
  } else {
    # Half-marked values use "other" plural (e.g. "1 1/2 hours" not "1 1/2 hour")
    if (nchar(half) > 0) {
      category <- "other"
    } else {
      category <- locale$plural(count)
    }
    template <- unit_forms[[category]]
    if (is.null(template)) template <- unit_forms[["other"]]
  }

  result <- gsub("{n}", n, template, fixed = TRUE)

  if (!is.null(locale$format_unit)) {
    result <- locale$format_unit(count, result)
  }

  # Apply {0}-style half marker (wraps the whole expression)
  if (nchar(half) > 0 && grepl("{0}", half, fixed = TRUE)) {
    result <- gsub("{0}", result, half, fixed = TRUE)
  }

  result
}

pick_dur <- function(override, attr, default) {
  if (!is.null(override)) {
    val <- override[[attr]]
    if (!is.null(val)) return(val)
  }
  default
}

#' Create a new SayableDuration formatter.
#'
#' @param locale The locale list to use
#' @param compactness "normal", "short", or "compact" (default: "normal")
#' @return A list with format_duration, format_since, and format_until functions
sayable_duration_new <- function(locale, compactness = "normal") {
  ovr <- NULL
  if (compactness == "short") {
    ovr <- locale$short
  } else if (compactness == "compact") {
    ovr <- locale$compact
  }

  ovr_units <- if (!is.null(ovr)) ovr$units else NULL
  units <- list()
  for (k in c("second", "minute", "hour", "day", "week", "month", "year")) {
    if (!is.null(ovr_units) && !is.null(ovr_units[[k]])) {
      units[[k]] <- ovr_units[[k]]
    } else {
      units[[k]] <- locale$units[[k]]
    }
  }

  half <- pick_dur(ovr, "half", locale$half)
  delimiter <- pick_dur(ovr, "delimiter", locale$delimiter)
  just_now <- locale$just_now
  ago <- pick_dur(ovr, "ago", locale$ago)
  in_future <- pick_dur(ovr, "in_future", locale$in_future)

  format_duration_internal <- function(total) {
    # 0 seconds
    if (total == 0) return(just_now)

    # 1-59 seconds
    if (total < 60) {
      return(resolve_unit_dur(total, units$second, locale))
    }

    total_minutes <- floor(total / 60)
    remainder_seconds <- total %% 60

    # 1-4 minutes: minutes + seconds
    if (total_minutes < 5) {
      result <- resolve_unit_dur(total_minutes, units$minute, locale)
      if (remainder_seconds > 0) {
        result <- paste0(result, delimiter,
                         resolve_unit_dur(remainder_seconds, units$second, locale))
      }
      return(result)
    }

    # 5-59 minutes
    if (total_minutes < 60) {
      return(resolve_unit_dur(total_minutes, units$minute, locale))
    }

    total_hours <- floor(total / 3600)
    remainder_minutes <- floor((total %% 3600) / 60)

    # 1-5 hours: hours + minutes (with half marker)
    if (total_hours <= 5) {
      if (remainder_minutes == 30) {
        return(resolve_unit_dur(total_hours, units$hour, locale, half))
      }
      result <- resolve_unit_dur(total_hours, units$hour, locale)
      if (remainder_minutes > 0) {
        result <- paste0(result, delimiter,
                         resolve_unit_dur(remainder_minutes, units$minute, locale))
      }
      return(result)
    }

    # 6-23 hours
    if (total_hours < 24) {
      return(resolve_unit_dur(total_hours, units$hour, locale))
    }

    total_days <- floor(total / 86400)
    remainder_hours <- floor((total %% 86400) / 3600)

    # 1-2 days: days + hours (with half marker)
    if (total_days <= 2) {
      if (remainder_hours == 12) {
        return(resolve_unit_dur(total_days, units$day, locale, half))
      }
      result <- resolve_unit_dur(total_days, units$day, locale)
      if (remainder_hours > 0) {
        result <- paste0(result, delimiter,
                         resolve_unit_dur(remainder_hours, units$hour, locale))
      }
      return(result)
    }

    # 3-6 days
    if (total_days < 7) {
      return(resolve_unit_dur(total_days, units$day, locale))
    }

    total_weeks <- floor(total_days / 7)
    remainder_days <- total_days %% 7

    # 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
    if (total_days < 30) {
      result <- resolve_unit_dur(total_weeks, units$week, locale)
      if (remainder_days > 0) {
        result <- paste0(result, delimiter,
                         resolve_unit_dur(remainder_days, units$day, locale))
      }
      return(result)
    }

    # Approximate months (30.44 days average)
    total_months <- round(total_days / 30.44)

    # 1-11 months
    if (total_months < 12) {
      if (total_months == 0) total_months <- 1
      return(resolve_unit_dur(total_months, units$month, locale))
    }

    # 12+ months: years + months
    total_years <- floor(total_months / 12)
    remainder_months <- total_months %% 12
    result <- resolve_unit_dur(total_years, units$year, locale)
    if (remainder_months > 0) {
      result <- paste0(result, delimiter,
                       resolve_unit_dur(remainder_months, units$month, locale))
    }
    result
  }

  format_duration_fn <- function(seconds) {
    if (is.null(seconds)) return(NULL)
    if (seconds < 0) return(NULL)
    format_duration_internal(seconds)
  }

  format_duration_iso_fn <- function(start_iso, end_iso) {
    if (is.null(start_iso) || !is.character(start_iso) || nchar(start_iso) == 0) return(NULL)
    if (is.null(end_iso) || !is.character(end_iso) || nchar(end_iso) == 0) return(NULL)
    s <- parse_iso_to_seconds(start_iso)
    e <- parse_iso_to_seconds(end_iso)
    if (is.null(s) || is.null(e)) return(NULL)
    total <- abs(e - s)
    format_duration_internal(total)
  }

  format_since_fn <- function(start, as_of) {
    if (is.null(start) || !is.character(start) || nchar(start) == 0) return(NULL)
    if (is.null(as_of) || !is.character(as_of) || nchar(as_of) == 0) return(NULL)
    s <- parse_iso_to_seconds(start)
    a <- parse_iso_to_seconds(as_of)
    if (is.null(s) || is.null(a)) return(NULL)
    diff <- a - s
    if (diff < 0) return(NULL)
    if (diff == 0) return(just_now)
    dur <- format_duration_internal(diff)
    gsub("{0}", dur, ago, fixed = TRUE)
  }

  format_until_fn <- function(target, as_of) {
    if (is.null(target) || !is.character(target) || nchar(target) == 0) return(NULL)
    if (is.null(as_of) || !is.character(as_of) || nchar(as_of) == 0) return(NULL)
    t_val <- parse_iso_to_seconds(target)
    a <- parse_iso_to_seconds(as_of)
    if (is.null(t_val) || is.null(a)) return(NULL)
    diff <- t_val - a
    if (diff < 0) return(NULL)
    if (diff == 0) return(just_now)
    dur <- format_duration_internal(diff)
    gsub("{0}", dur, in_future, fixed = TRUE)
  }

  list(
    format_duration = format_duration_fn,
    format_duration_iso = format_duration_iso_fn,
    format_since = format_since_fn,
    format_until = format_until_fn
  )
}

#' Format a duration in seconds as human-readable text.
#'
#' @param seconds Integer number of seconds
#' @param locale Locale list (defaults to English)
#' @param compactness "normal", "short", or "compact" (default: "normal")
#' @return Formatted duration string, or NULL
format_duration <- function(seconds, locale = NULL, compactness = "normal") {
  if (is.null(locale)) {
    locale <- load_default_duration_locale()
  }
  sd <- sayable_duration_new(locale, compactness)
  sd$format_duration(seconds)
}

#' Format elapsed time as "X ago".
#'
#' @param start ISO datetime string
#' @param as_of ISO datetime string
#' @param locale Locale list (defaults to English)
#' @param compactness "normal", "short", or "compact" (default: "normal")
#' @return Formatted string, or NULL
format_since <- function(start, as_of, locale = NULL, compactness = "normal") {
  if (is.null(locale)) {
    locale <- load_default_duration_locale()
  }
  sd <- sayable_duration_new(locale, compactness)
  sd$format_since(start, as_of)
}

#' Format time until a future event as "in X".
#'
#' @param target ISO datetime string
#' @param as_of ISO datetime string
#' @param locale Locale list (defaults to English)
#' @param compactness "normal", "short", or "compact" (default: "normal")
#' @return Formatted string, or NULL
format_until <- function(target, as_of, locale = NULL, compactness = "normal") {
  if (is.null(locale)) {
    locale <- load_default_duration_locale()
  }
  sd <- sayable_duration_new(locale, compactness)
  sd$format_until(target, as_of)
}

load_default_duration_locale <- function() {
  pkg_dir <- find.package("sayableduration", quiet = TRUE)
  if (length(pkg_dir) > 0) {
    locale_path <- file.path(pkg_dir, "locales", "en.R")
  } else {
    locale_path <- file.path(getwd(), "locales", "en.R")
  }
  env <- new.env(parent = baseenv())
  source(locale_path, local = env)
  env$locale_en
}
