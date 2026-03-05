package sayabledate_test

import (
	"testing"

	sd "github.com/dnf/sayable/date/impl/go"
	"github.com/dnf/sayable/date/impl/go/locales"
)

// assertNil checks that the result is nil.
func assertNil(t *testing.T, result *string) {
	t.Helper()
	if result != nil {
		t.Errorf("expected nil, got %q", *result)
	}
}

// assertEqual checks that the result matches the expected string.
func assertEqual(t *testing.T, result *string, expected string) {
	t.Helper()
	if result == nil {
		t.Errorf("expected %q, got nil", expected)
		return
	}
	if *result != expected {
		t.Errorf("expected %q, got %q", expected, *result)
	}
}

// ── Section 1: Null / edge cases ────────────────────────────────────

func TestNullEdgeCases(t *testing.T) {
	f := sd.NewSayableDate(locales.EN)

	// 1.1
	t.Run("format_date null", func(t *testing.T) {
		assertNil(t, f.FormatDate(""))
	})

	// 1.2
	t.Run("format_date empty", func(t *testing.T) {
		assertNil(t, f.FormatDate(""))
	})

	// 1.3
	t.Run("format_date invalid", func(t *testing.T) {
		assertNil(t, f.FormatDate("invalid"))
	})

	// 1.4
	t.Run("format_relative null asOf", func(t *testing.T) {
		assertNil(t, f.FormatRelative("2025-03-15", ""))
	})

	// 1.5
	t.Run("format_relative null date", func(t *testing.T) {
		assertNil(t, f.FormatRelative("", "2025-03-15"))
	})
}

// ── Section 2: format_date — normal compactness (English) ───────────

func TestFormatDateNormalEnglish(t *testing.T) {
	f := sd.NewSayableDate(locales.EN)

	// 2.1
	t.Run("March 15th", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-03-15"), "March 15th")
	})

	// 2.2
	t.Run("January 1st", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-01-01"), "January 1st")
	})

	// 2.3
	t.Run("May 22nd", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-05-22"), "May 22nd")
	})

	// 2.4
	t.Run("July 3rd", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-07-03"), "July 3rd")
	})

	// 2.5
	t.Run("December 31st", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-12-31"), "December 31st")
	})

	// 2.6
	t.Run("June 11th", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-06-11"), "June 11th")
	})

	// 2.7
	t.Run("ISO datetime input", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-03-15T14:30:00"), "March 15th")
	})
}

// ── Section 3: format_date — short compactness (English) ────────────

func TestFormatDateShortEnglish(t *testing.T) {
	f := sd.NewSayableDate(locales.EN, sd.Short)

	// 3.1
	t.Run("Mar 15", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-03-15"), "Mar 15")
	})

	// 3.2
	t.Run("Jan 1", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-01-01"), "Jan 1")
	})

	// 3.3
	t.Run("Dec 25", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-12-25"), "Dec 25")
	})
}

// ── Section 4: format_date — compact (English) ──────────────────────

func TestFormatDateCompactEnglish(t *testing.T) {
	f := sd.NewSayableDate(locales.EN, sd.Compact)

	// 4.1
	t.Run("3/15", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-03-15"), "3/15")
	})

	// 4.2
	t.Run("1/1", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-01-01"), "1/1")
	})
}

// ── Section 5: format_relative — proximity tiers (English) ──────────

func TestFormatRelativeEnglish(t *testing.T) {
	f := sd.NewSayableDate(locales.EN)

	// 5.1
	t.Run("today", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-15", "2025-03-15"), "today")
	})

	// 5.2
	t.Run("tomorrow", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-16", "2025-03-15"), "tomorrow")
	})

	// 5.3
	t.Run("yesterday", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-14", "2025-03-15"), "yesterday")
	})

	// 5.4
	t.Run("day after tomorrow", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-17", "2025-03-15"), "the day after tomorrow")
	})

	// 5.5
	t.Run("day before yesterday", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-13", "2025-03-15"), "the day before yesterday")
	})

	// 5.6
	t.Run("this Wednesday", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-19", "2025-03-15"), "this Wednesday")
	})

	// 5.7
	t.Run("this Thursday", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-20", "2025-03-15"), "this Thursday")
	})

	// 5.8
	t.Run("last Tuesday", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-11", "2025-03-15"), "last Tuesday")
	})

	// 5.9
	t.Run("next Saturday", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-22", "2025-03-15"), "next Saturday")
	})

	// 5.10
	t.Run("next Thursday", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-27", "2025-03-15"), "next Thursday")
	})

	// 5.11
	t.Run("calendar same year past", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-01", "2025-03-15"), "March 1st")
	})

	// 5.12
	t.Run("calendar same year future", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-04-10", "2025-03-15"), "April 10th")
	})

	// 5.13
	t.Run("different year future", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2026-01-05", "2025-03-15"), "January 5th, 2026")
	})

	// 5.14
	t.Run("different year past", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2024-12-25", "2025-03-15"), "December 25th, 2024")
	})
}

// ── Section 6: format_relative — compact skips weekday tiers ────────

func TestFormatRelativeCompactEnglish(t *testing.T) {
	f := sd.NewSayableDate(locales.EN, sd.Compact)

	// 6.1
	t.Run("today", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-15", "2025-03-15"), "today")
	})

	// 6.2
	t.Run("tomorrow", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-16", "2025-03-15"), "tomorrow")
	})

	// 6.3
	t.Run("compact numeric", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-19", "2025-03-15"), "3/19")
	})

	// 6.4
	t.Run("compact different year", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2026-01-05", "2025-03-15"), "1/5/26")
	})
}

// ── Section 7: Locale — German ──────────────────────────────────────

func TestLocaleGerman(t *testing.T) {
	f := sd.NewSayableDate(locales.DE)

	// 7.1
	t.Run("format_date", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-03-15"), "15. März")
	})

	// 7.2
	t.Run("tomorrow", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-16", "2025-03-15"), "morgen")
	})

	// 7.3
	t.Run("day after tomorrow", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-17", "2025-03-15"), "übermorgen")
	})

	// 7.4
	t.Run("this Wednesday", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-19", "2025-03-15"), "diesen Mittwoch")
	})
}

// ── Section 8: Locale — French ──────────────────────────────────────

func TestLocaleFrench(t *testing.T) {
	f := sd.NewSayableDate(locales.FR)

	// 8.1
	t.Run("1er mars", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-03-01"), "1er mars")
	})

	// 8.2
	t.Run("15 mars", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-03-15"), "15 mars")
	})

	// 8.3
	t.Run("tomorrow", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-16", "2025-03-15"), "demain")
	})
}

// ── Section 9: Locale — Japanese ────────────────────────────────────

func TestLocaleJapanese(t *testing.T) {
	f := sd.NewSayableDate(locales.JA)

	// 9.1
	t.Run("format_date", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-03-15"), "3月15日")
	})

	// 9.2
	t.Run("tomorrow", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-16", "2025-03-15"), "明日")
	})

	// 9.3
	t.Run("this Wednesday", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-19", "2025-03-15"), "今度の水曜日")
	})
}

// ── Section 10: Locale — Russian (genitive months) ──────────────────

func TestLocaleRussian(t *testing.T) {
	f := sd.NewSayableDate(locales.RU)

	// 10.1
	t.Run("format_date genitive", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-03-15"), "15 марта")
	})

	// 10.2
	t.Run("tomorrow", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-16", "2025-03-15"), "завтра")
	})
}

// ── Section 11: Locale — Arabic ─────────────────────────────────────

func TestLocaleArabic(t *testing.T) {
	f := sd.NewSayableDate(locales.AR)

	// 11.1
	t.Run("format_date", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-03-15"), "15 مارس")
	})

	// 11.2
	t.Run("tomorrow", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-16", "2025-03-15"), "غداً")
	})
}

// ── Section 12: Locale — Spanish ────────────────────────────────────

func TestLocaleSpanish(t *testing.T) {
	f := sd.NewSayableDate(locales.ES)

	// 12.1
	t.Run("format_date", func(t *testing.T) {
		assertEqual(t, f.FormatDate("2025-03-15"), "15 de marzo")
	})

	// 12.2
	t.Run("day after tomorrow", func(t *testing.T) {
		assertEqual(t, f.FormatRelative("2025-03-17", "2025-03-15"), "pasado mañana")
	})
}

// ── Version ─────────────────────────────────────────────────────────

func TestVersion(t *testing.T) {
	if sd.Version != "0.5.0" {
		t.Errorf("expected version %q, got %q", "0.5.0", sd.Version)
	}
}
