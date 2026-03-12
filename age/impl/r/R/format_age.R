# Human-friendly age formatting for young children.
#
# Formats ages the way parents and pediatricians talk:
# "6 weeks", "14 months", "3 1/2 years".
# Zero runtime dependencies.

MAX_AGE_MONTHS <- 6000

is_leap_year <- function(y) {
  (y %% 4 == 0 && y %% 100 != 0) || (y %% 400 == 0)
}

days_in_month <- function(y, m) {
  lengths <- c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
  if (m == 2 && is_leap_year(y)) return(29)
  lengths[m]
}

days_between <- function(y1, m1, d1, y2, m2, d2) {
  to_days <- function(y, m, d) {
    if (m <= 2) {
      y <- y - 1
      m <- m + 12
    }
    a <- floor(y / 100)
    b <- 2 - a + floor(a / 4)
    floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + d + b - 1524
  }
  to_days(y2, m2, d2) - to_days(y1, m1, d1)
}

parse_date <- function(s) {
  if (is.null(s) || !is.character(s) || nchar(s) == 0) return(NULL)
  parts <- strsplit(s, "-", fixed = TRUE)[[1]]
  if (length(parts) != 3) return(NULL)
  y <- suppressWarnings(as.integer(parts[1]))
  m <- suppressWarnings(as.integer(parts[2]))
  d <- suppressWarnings(as.integer(parts[3]))
  if (is.na(y) || is.na(m) || is.na(d)) return(NULL)
  list(year = y, month = m, day = d)
}

parse_age <- function(date_of_birth, as_of = NULL) {
  if (is.null(date_of_birth) || !is.character(date_of_birth) || nchar(date_of_birth) == 0) {
    return(NULL)
  }

  dob <- parse_date(date_of_birth)
  if (is.null(dob)) return(NULL)

  if (!is.null(as_of)) {
    ref <- parse_date(as_of)
    if (is.null(ref)) return(NULL)
  } else {
    today <- Sys.Date()
    ref <- list(
      year = as.integer(format(today, "%Y")),
      month = as.integer(format(today, "%m")),
      day = as.integer(format(today, "%d"))
    )
  }

  diff_days <- days_between(dob$year, dob$month, dob$day,
                            ref$year, ref$month, ref$day)
  if (diff_days < 0) return(NULL)

  last_day <- days_in_month(ref$year, ref$month)
  clamped_birthday <- min(dob$day, last_day)
  months <- (ref$year - dob$year) * 12 + (ref$month - dob$month)
  if (ref$day < clamped_birthday) {
    months <- months - 1
  }
  if (months > MAX_AGE_MONTHS) return(NULL)

  list(months = months, diff_days = diff_days)
}

stage_key <- function(months) {
  if (months < 2) return("newborn")
  if (months < 12) return("infant")
  if (months < 36) return("toddler")
  if (months < 156) return("child")
  if (months < 216) return("teenager")
  "adult"
}

resolve_unit <- function(count, unit_forms, locale, half = "") {
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
    category <- locale$plural(count)
    template <- unit_forms[[category]]
    if (is.null(template)) template <- unit_forms[["other"]]
  }

  result <- gsub("{n}", n, template, fixed = TRUE)

  if (!is.null(locale$format_unit)) {
    result <- locale$format_unit(count, result)
  }

  if (nchar(half) > 0 && grepl("{0}", half, fixed = TRUE)) {
    result <- gsub("{0}", result, half, fixed = TRUE)
  }

  result
}

resolve_stage <- function(label, gender = NULL) {
  if (is.character(label) && is.null(names(label))) return(label)
  if (is.list(label)) {
    if (!is.null(gender) && gender == "f") return(label$f)
    return(label$m)
  }
  label
}

pick <- function(override, attr, default) {
  if (!is.null(override)) {
    val <- override[[attr]]
    if (!is.null(val)) return(val)
  }
  default
}

#' Create a new SayableAge formatter.
#'
#' @param locale The locale list to use
#' @param compactness "normal", "short", or "compact" (default: "normal")
#' @return A list with format_age and format_stage functions
sayable_age_new <- function(locale, compactness = "normal") {
  ovr <- NULL
  if (compactness == "short") {
    ovr <- locale$short
  } else if (compactness == "compact") {
    ovr <- locale$compact
  }

  ovr_units <- if (!is.null(ovr)) ovr$units else NULL
  units <- list()
  for (k in c("day", "week", "month", "year")) {
    if (!is.null(ovr_units) && !is.null(ovr_units[[k]])) {
      units[[k]] <- ovr_units[[k]]
    } else {
      units[[k]] <- locale$units[[k]]
    }
  }

  half <- pick(ovr, "half", locale$half)
  delimiter <- pick(ovr, "delimiter", locale$delimiter)
  just_born <- pick(ovr, "just_born", locale$just_born)

  format_age <- function(date_of_birth, as_of = NULL) {
    parsed <- parse_age(date_of_birth, as_of)
    if (is.null(parsed)) return(NULL)

    months <- parsed$months
    diff_days <- parsed$diff_days

    # Tier 1: 0-6 days
    if (diff_days == 0) return(just_born)
    if (diff_days < 7) {
      return(resolve_unit(diff_days, units$day, locale))
    }

    # Tier 2: weeks + days until 3 calendar months
    if (months < 3) {
      weeks <- floor(diff_days / 7)
      days <- diff_days %% 7
      result <- resolve_unit(weeks, units$week, locale)
      if (days > 0) {
        result <- paste0(result, delimiter, resolve_unit(days, units$day, locale))
      }
      return(result)
    }

    # Tier 3: 3-23 months
    if (months < 24) {
      return(resolve_unit(months, units$month, locale))
    }

    # Tier 4: 24-35 months -> years + months
    if (months < 36) {
      years <- floor(months / 12)
      rem <- months %% 12
      if (rem == 0) {
        return(resolve_unit(years, units$year, locale))
      }
      return(paste0(
        resolve_unit(years, units$year, locale),
        delimiter,
        resolve_unit(rem, units$month, locale)
      ))
    }

    # Tier 5: 3-6 years -> years with half marker
    if (months < 84) {
      years <- floor(months / 12)
      rem <- months %% 12
      if (rem >= 6) {
        return(resolve_unit(years, units$year, locale, half))
      }
      return(resolve_unit(years, units$year, locale))
    }

    # Tier 6: 7+ years
    resolve_unit(floor(months / 12), units$year, locale)
  }

  format_stage <- function(date_of_birth, as_of = NULL, gender = NULL) {
    parsed <- parse_age(date_of_birth, as_of)
    if (is.null(parsed)) return(NULL)
    resolve_stage(locale$stages[[stage_key(parsed$months)]], gender)
  }

  list(format_age = format_age, format_stage = format_stage)
}

#' Format a human-friendly age string.
#'
#' @param date_of_birth YYYY-MM-DD date string
#' @param as_of YYYY-MM-DD reference date (defaults to today)
#' @param locale Locale list (defaults to English)
#' @param compactness "normal", "short", or "compact" (default: "normal")
#' @return Formatted age string, or NULL on invalid input
format_age <- function(date_of_birth, as_of = NULL, locale = NULL, compactness = "normal") {
  if (is.null(locale)) {
    locale <- load_default_locale("age")
  }
  sa <- sayable_age_new(locale, compactness)
  sa$format_age(date_of_birth, as_of)
}

#' Format a developmental stage label.
#'
#' @param date_of_birth YYYY-MM-DD date string
#' @param as_of YYYY-MM-DD reference date (defaults to today)
#' @param gender "m" or "f" for gendered locales (optional)
#' @param locale Locale list (defaults to English)
#' @param compactness "normal", "short", or "compact" (default: "normal")
#' @return Stage label string, or NULL on invalid input
format_stage <- function(date_of_birth, as_of = NULL, gender = NULL, locale = NULL,
                         compactness = "normal") {
  if (is.null(locale)) {
    locale <- load_default_locale("age")
  }
  sa <- sayable_age_new(locale, compactness)
  sa$format_stage(date_of_birth, as_of, gender)
}

load_default_locale <- function(component) {
  # Source the en.R locale file
  pkg_dir <- find.package("sayableage", quiet = TRUE)
  if (length(pkg_dir) > 0) {
    locale_path <- file.path(pkg_dir, "locales", "en.R")
  } else {
    locale_path <- file.path(getwd(), "locales", "en.R")
  }
  env <- new.env(parent = baseenv())
  source(locale_path, local = env)
  env$locale_en
}
