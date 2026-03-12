/// Formats durations the way people talk -- "just now", "3 minutes", "2½ hours".

import sayableduration/formatter
import sayableduration/locales/locales
import sayableduration/types.{type Compactness, type DurationLocale}

pub fn format_duration(
  locale: DurationLocale,
  compactness: Compactness,
  seconds: Int,
) -> Result(String, Nil) {
  formatter.format_duration_seconds(locale, compactness, seconds)
}

pub fn format_duration_timestamps(
  locale: DurationLocale,
  compactness: Compactness,
  start: String,
  end: String,
) -> Result(String, Nil) {
  formatter.format_duration_timestamps(locale, compactness, start, end)
}

pub fn format_since(
  locale: DurationLocale,
  compactness: Compactness,
  start: String,
  as_of: String,
) -> Result(String, Nil) {
  formatter.format_since(locale, compactness, start, as_of)
}

pub fn format_until(
  locale: DurationLocale,
  compactness: Compactness,
  target: String,
  as_of: String,
) -> Result(String, Nil) {
  formatter.format_until(locale, compactness, target, as_of)
}

pub fn get_locale(code: String) -> Result(DurationLocale, Nil) {
  locales.get(code)
}
