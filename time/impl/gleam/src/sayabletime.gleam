/// Formats clock times the way people talk -- "a quarter past three", "half past seven".

import sayabletime/formatter
import sayabletime/locales/locales
import sayabletime/types.{type Compactness, type TimeLocale}

pub fn format_time(
  locale: TimeLocale,
  compactness: Compactness,
  input: String,
) -> Result(String, Nil) {
  formatter.format_time(locale, compactness, input)
}

pub fn get_locale(code: String) -> Result(TimeLocale, Nil) {
  locales.get(code)
}
