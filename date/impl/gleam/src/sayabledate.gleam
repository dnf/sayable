/// Formats dates the way people talk -- "today", "next Thursday", "March 15th".

import sayabledate/formatter
import sayabledate/locales/locales
import sayabledate/types.{type Compactness, type DateLocale}

pub fn format_date(
  locale: DateLocale,
  compactness: Compactness,
  date: String,
) -> Result(String, Nil) {
  formatter.format_date(locale, compactness, date)
}

pub fn format_date_with_year(
  locale: DateLocale,
  compactness: Compactness,
  date: String,
) -> Result(String, Nil) {
  formatter.format_date_with_year(locale, compactness, date)
}

pub fn format_relative(
  locale: DateLocale,
  compactness: Compactness,
  date: String,
  as_of: String,
) -> Result(String, Nil) {
  formatter.format_relative(locale, compactness, date, as_of)
}

pub fn get_locale(code: String) -> Result(DateLocale, Nil) {
  locales.get(code)
}
