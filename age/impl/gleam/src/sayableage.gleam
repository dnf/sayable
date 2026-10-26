/// Formats ages the way parents talk -- "6 weeks", "14 months", "3 1/2 years".
import sayableage/formatter
import sayableage/locales/locales
import sayableage/types.{type AgeLocale, type Compactness, type Gender}

pub fn format_age(
  locale: AgeLocale,
  compactness: Compactness,
  dob: String,
  as_of: String,
) -> Result(String, Nil) {
  formatter.format_age(locale, compactness, dob, as_of)
}

pub fn format_stage(
  locale: AgeLocale,
  dob: String,
  as_of: String,
  gender: Result(Gender, Nil),
) -> Result(String, Nil) {
  formatter.format_stage(locale, dob, as_of, gender)
}

pub fn get_locale(code: String) -> Result(AgeLocale, Nil) {
  locales.get(code)
}

/// Every supported locale code, sorted.
pub fn locale_codes() -> List(String) {
  locales.codes
}
