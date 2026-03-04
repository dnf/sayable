package sayableduration_test

import (
	"testing"

	sd "github.com/dnf/sayable/duration/impl/go"
	"github.com/dnf/sayable/duration/impl/go/locales"
)

// All tests use explicit inputs for determinism.

// assertEq asserts that got is non-nil and equals want.
func assertEq(t *testing.T, name string, got *string, want string) {
	t.Helper()
	if got == nil {
		t.Errorf("%s: got nil, want %q", name, want)
		return
	}
	if *got != want {
		t.Errorf("%s: got %q, want %q", name, *got, want)
	}
}

// assertNil asserts that got is nil.
func assertNil(t *testing.T, name string, got *string) {
	t.Helper()
	if got != nil {
		t.Errorf("%s: got %q, want nil", name, *got)
	}
}

// ================================================================
// Section 1: Null / edge cases
// ================================================================
func TestNullEdgeCases(t *testing.T) {
	dur := sd.NewSayableDuration(locales.EN)

	// 1.1
	assertNil(t, "1.1 format_duration nil", dur.FormatDurationSeconds(-999))

	// 1.2
	assertNil(t, "1.2 format_duration negative", dur.FormatDurationSeconds(-1))

	// 1.3
	assertNil(t, "1.3 format_since nil start", dur.FormatSince("", "2025-01-15T10:00:00"))

	// 1.4
	assertNil(t, "1.4 format_until nil target", dur.FormatUntil("", "2025-01-15T10:00:00"))

	// 1.5
	assertNil(t, "1.5 format_since future start", dur.FormatSince("2025-01-15T10:00:00", "2025-01-15T09:00:00"))

	// 1.6
	assertNil(t, "1.6 format_until past target", dur.FormatUntil("2025-01-15T09:00:00", "2025-01-15T10:00:00"))
}

// ================================================================
// Section 2: Duration -- seconds tier (0-59s)
// ================================================================
func TestDurationSeconds(t *testing.T) {
	dur := sd.NewSayableDuration(locales.EN)

	// 2.1
	assertEq(t, "2.1 zero seconds", dur.FormatDurationSeconds(0), "just now")

	// 2.2
	assertEq(t, "2.2 one second", dur.FormatDurationSeconds(1), "1 second")

	// 2.3
	assertEq(t, "2.3 45 seconds", dur.FormatDurationSeconds(45), "45 seconds")

	// 2.4
	assertEq(t, "2.4 59 seconds", dur.FormatDurationSeconds(59), "59 seconds")
}

// ================================================================
// Section 3: Duration -- minutes + seconds tier (1-4 min)
// ================================================================
func TestDurationMinutesSeconds(t *testing.T) {
	dur := sd.NewSayableDuration(locales.EN)

	// 3.1
	assertEq(t, "3.1 one minute", dur.FormatDurationSeconds(60), "1 minute")

	// 3.2
	assertEq(t, "3.2 one minute thirty seconds", dur.FormatDurationSeconds(90), "1 minute, 30 seconds")

	// 3.3
	assertEq(t, "3.3 four minutes", dur.FormatDurationSeconds(240), "4 minutes")

	// 3.4
	assertEq(t, "3.4 four minutes thirty seconds", dur.FormatDurationSeconds(270), "4 minutes, 30 seconds")
}

// ================================================================
// Section 4: Duration -- minutes tier (5-59 min)
// ================================================================
func TestDurationMinutes(t *testing.T) {
	dur := sd.NewSayableDuration(locales.EN)

	// 4.1
	assertEq(t, "4.1 five minutes", dur.FormatDurationSeconds(300), "5 minutes")

	// 4.2
	assertEq(t, "4.2 25 minutes", dur.FormatDurationSeconds(1500), "25 minutes")

	// 4.3
	assertEq(t, "4.3 59 minutes", dur.FormatDurationSeconds(3540), "59 minutes")
}

// ================================================================
// Section 5: Duration -- hours + minutes tier (1-5 hr)
// ================================================================
func TestDurationHoursMinutes(t *testing.T) {
	dur := sd.NewSayableDuration(locales.EN)

	// 5.1
	assertEq(t, "5.1 one hour", dur.FormatDurationSeconds(3600), "1 hour")

	// 5.2
	assertEq(t, "5.2 one and half hours", dur.FormatDurationSeconds(5400), "1\u00BD hours")

	// 5.3
	assertEq(t, "5.3 two hours 15 minutes", dur.FormatDurationSeconds(8100), "2 hours, 15 minutes")

	// 5.4
	assertEq(t, "5.4 five hours", dur.FormatDurationSeconds(18000), "5 hours")
}

// ================================================================
// Section 6: Duration -- hours tier (6-23 hr)
// ================================================================
func TestDurationHours(t *testing.T) {
	dur := sd.NewSayableDuration(locales.EN)

	// 6.1
	assertEq(t, "6.1 eight hours", dur.FormatDurationSeconds(28800), "8 hours")

	// 6.2
	assertEq(t, "6.2 23 hours", dur.FormatDurationSeconds(82800), "23 hours")
}

// ================================================================
// Section 7: Duration -- days tier
// ================================================================
func TestDurationDays(t *testing.T) {
	dur := sd.NewSayableDuration(locales.EN)

	// 7.1
	assertEq(t, "7.1 one day", dur.FormatDurationSeconds(86400), "1 day")

	// 7.2
	assertEq(t, "7.2 one day three hours", dur.FormatDurationSeconds(97200), "1 day, 3 hours")

	// 7.3
	assertEq(t, "7.3 one and half days", dur.FormatDurationSeconds(129600), "1\u00BD days")

	// 7.4
	assertEq(t, "7.4 five days", dur.FormatDurationSeconds(432000), "5 days")

	// 7.5
	assertEq(t, "7.5 two days", dur.FormatDurationSeconds(172800), "2 days")
}

// ================================================================
// Section 8: Duration -- weeks tier
// ================================================================
func TestDurationWeeks(t *testing.T) {
	dur := sd.NewSayableDuration(locales.EN)

	// 8.1
	assertEq(t, "8.1 one week", dur.FormatDurationSeconds(604800), "1 week")

	// 8.2
	assertEq(t, "8.2 two weeks one day", dur.FormatDurationSeconds(1296000), "2 weeks, 1 day")

	// 8.3
	assertEq(t, "8.3 four weeks", dur.FormatDurationSeconds(2419200), "4 weeks")
}

// ================================================================
// Section 9: Duration -- months and years tier
// ================================================================
func TestDurationMonthsYears(t *testing.T) {
	dur := sd.NewSayableDuration(locales.EN)

	// 9.1
	assertEq(t, "9.1 one month", dur.FormatDurationSeconds(2678400), "1 month")

	// 9.2
	assertEq(t, "9.2 three months", dur.FormatDurationSeconds(7884000), "3 months")

	// 9.3
	assertEq(t, "9.3 one year", dur.FormatDurationSeconds(31536000), "1 year")

	// 9.4
	assertEq(t, "9.4 one year three months", dur.FormatDurationSeconds(39420000), "1 year, 3 months")
}

// ================================================================
// Section 10: Duration from ISO timestamps
// ================================================================
func TestDurationISO(t *testing.T) {
	dur := sd.NewSayableDuration(locales.EN)

	// 10.1
	assertEq(t, "10.1 ISO one and half hours",
		dur.FormatDurationISO("2025-01-15T10:00:00", "2025-01-15T11:30:00"),
		"1\u00BD hours")

	// 10.2
	assertEq(t, "10.2 ISO 45 minutes",
		dur.FormatDurationISO("2025-01-15T10:00:00", "2025-01-15T10:45:00"),
		"45 minutes")
}

// ================================================================
// Section 11: Relative time -- since
// ================================================================
func TestFormatSince(t *testing.T) {
	dur := sd.NewSayableDuration(locales.EN)

	// 11.1
	assertEq(t, "11.1 just now",
		dur.FormatSince("2025-01-15T10:00:00", "2025-01-15T10:00:00"),
		"just now")

	// 11.2
	assertEq(t, "11.2 30 seconds ago",
		dur.FormatSince("2025-01-15T10:00:00", "2025-01-15T10:00:30"),
		"30 seconds ago")

	// 11.3
	assertEq(t, "11.3 45 minutes ago",
		dur.FormatSince("2025-01-15T10:00:00", "2025-01-15T10:45:00"),
		"45 minutes ago")

	// 11.4
	assertEq(t, "11.4 3 hours ago",
		dur.FormatSince("2025-01-15T10:00:00", "2025-01-15T13:00:00"),
		"3 hours ago")
}

// ================================================================
// Section 12: Relative time -- until
// ================================================================
func TestFormatUntil(t *testing.T) {
	dur := sd.NewSayableDuration(locales.EN)

	// 12.1
	assertEq(t, "12.1 just now",
		dur.FormatUntil("2025-01-15T10:00:00", "2025-01-15T10:00:00"),
		"just now")

	// 12.2
	assertEq(t, "12.2 in 20 minutes",
		dur.FormatUntil("2025-01-15T10:20:00", "2025-01-15T10:00:00"),
		"in 20 minutes")

	// 12.3
	assertEq(t, "12.3 in 3 hours",
		dur.FormatUntil("2025-01-15T13:00:00", "2025-01-15T10:00:00"),
		"in 3 hours")
}

// ================================================================
// Section 13: Locale -- German
// ================================================================
func TestLocaleGerman(t *testing.T) {
	dur := sd.NewSayableDuration(locales.DE)

	// 13.1
	assertEq(t, "13.1 German one hour", dur.FormatDurationSeconds(3600), "1 Stunde")

	// 13.2
	assertEq(t, "13.2 German since 5 minutes",
		dur.FormatSince("2025-01-15T10:00:00", "2025-01-15T10:05:00"),
		"vor 5 Minuten")
}

// ================================================================
// Section 14: Locale -- French
// ================================================================
func TestLocaleFrench(t *testing.T) {
	dur := sd.NewSayableDuration(locales.FR)

	// 14.1
	assertEq(t, "14.1 French two hours", dur.FormatDurationSeconds(7200), "2 heures")
}

// ================================================================
// Section 15: Locale -- Japanese
// ================================================================
func TestLocaleJapanese(t *testing.T) {
	dur := sd.NewSayableDuration(locales.JA)

	// 15.1
	assertEq(t, "15.1 Japanese two minutes", dur.FormatDurationSeconds(120), "2\u5206")

	// 15.2
	assertEq(t, "15.2 Japanese since one hour",
		dur.FormatSince("2025-01-15T10:00:00", "2025-01-15T11:00:00"),
		"1\u6642\u9593\u524D")
}

// ================================================================
// Section 16: Short compactness -- duration
// ================================================================
func TestShortDuration(t *testing.T) {
	dur := sd.NewSayableDuration(locales.EN, sd.Short)

	// 16.1
	assertEq(t, "16.1 short one hour", dur.FormatDurationSeconds(3600), "1h")

	// 16.2
	assertEq(t, "16.2 short one minute thirty seconds", dur.FormatDurationSeconds(90), "1m, 30s")
}

// ================================================================
// Section 17: Compact compactness -- duration
// ================================================================
func TestCompactDuration(t *testing.T) {
	dur := sd.NewSayableDuration(locales.EN, sd.Compact)

	// 17.1
	assertEq(t, "17.1 compact one hour", dur.FormatDurationSeconds(3600), "1h")

	// 17.2
	assertEq(t, "17.2 compact one minute thirty seconds", dur.FormatDurationSeconds(90), "1m30s")
}
