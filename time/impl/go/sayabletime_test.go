package sayabletime_test

import (
	"testing"

	st "github.com/dnf/sayable/time/impl/go"
	"github.com/dnf/sayable/time/impl/go/locales"
)

// assertEq asserts a non-nil string pointer equals the expected value.
func assertEq(t *testing.T, got *string, want string) {
	t.Helper()
	if got == nil {
		t.Errorf("got nil, want %q", want)
		return
	}
	if *got != want {
		t.Errorf("got %q, want %q", *got, want)
	}
}

// assertNil asserts a string pointer is nil.
func assertNil(t *testing.T, got *string) {
	t.Helper()
	if got != nil {
		t.Errorf("got %q, want nil", *got)
	}
}

// ================================================================
// Section 1: Null / edge cases
// ================================================================

func TestNullEdgeCases(t *testing.T) {
	stDefault := st.NewSayableTime(locales.EN)
	st.SetDefault(stDefault)

	// 1.1
	t.Run("nil_input", func(t *testing.T) {
		assertNil(t, st.FormatTime(""))
	})

	// 1.2
	t.Run("empty_string", func(t *testing.T) {
		assertNil(t, st.FormatTime(""))
	})

	// 1.3
	t.Run("invalid_string", func(t *testing.T) {
		assertNil(t, st.FormatTime("invalid"))
	})

	// 1.4
	t.Run("out_of_range", func(t *testing.T) {
		assertNil(t, st.FormatTime("25:00"))
	})
}

// ================================================================
// Section 2: Clock time (normal compactness)
// ================================================================

func TestClockTimeNormal(t *testing.T) {
	f := st.NewSayableTime(locales.EN)

	// 2.1
	t.Run("midnight", func(t *testing.T) {
		assertEq(t, f.FormatTime("00:00"), "midnight")
	})

	// 2.2
	t.Run("noon", func(t *testing.T) {
		assertEq(t, f.FormatTime("12:00"), "noon")
	})

	// 2.3
	t.Run("oclock", func(t *testing.T) {
		assertEq(t, f.FormatTime("15:00"), "three o'clock")
	})

	// 2.4
	t.Run("quarter_past", func(t *testing.T) {
		assertEq(t, f.FormatTime("14:15"), "a quarter past two")
	})

	// 2.5
	t.Run("half_past", func(t *testing.T) {
		assertEq(t, f.FormatTime("09:30"), "half past nine")
	})

	// 2.6
	t.Run("quarter_to", func(t *testing.T) {
		assertEq(t, f.FormatTime("10:45"), "a quarter to eleven")
	})

	// 2.7
	t.Run("five_past", func(t *testing.T) {
		assertEq(t, f.FormatTime("08:05"), "five past eight")
	})

	// 2.8
	t.Run("five_to", func(t *testing.T) {
		assertEq(t, f.FormatTime("16:55"), "five to five")
	})

	// 2.9
	t.Run("rounds_to_midnight", func(t *testing.T) {
		assertEq(t, f.FormatTime("23:58"), "midnight")
	})

	// 2.10
	t.Run("rounds_to_twenty", func(t *testing.T) {
		assertEq(t, f.FormatTime("07:22"), "twenty past seven")
	})

	// 2.11
	t.Run("iso_datetime_input", func(t *testing.T) {
		assertEq(t, f.FormatTime("2025-01-15T14:15:00"), "a quarter past two")
	})
}

// ================================================================
// Section 3: Clock time (short compactness)
// ================================================================

func TestClockTimeShort(t *testing.T) {
	f := st.NewSayableTime(locales.EN, st.Short)

	// 3.1
	t.Run("pm", func(t *testing.T) {
		assertEq(t, f.FormatTime("14:15"), "2:15 PM")
	})

	// 3.2
	t.Run("am", func(t *testing.T) {
		assertEq(t, f.FormatTime("09:30"), "9:30 AM")
	})

	// 3.3
	t.Run("midnight", func(t *testing.T) {
		assertEq(t, f.FormatTime("00:00"), "12:00 AM")
	})

	// 3.4
	t.Run("noon", func(t *testing.T) {
		assertEq(t, f.FormatTime("12:00"), "12:00 PM")
	})
}

// ================================================================
// Section 4: Clock time (compact)
// ================================================================

func TestClockTimeCompact(t *testing.T) {
	f := st.NewSayableTime(locales.EN, st.Compact)

	// 4.1
	t.Run("pm", func(t *testing.T) {
		assertEq(t, f.FormatTime("14:15"), "2:15p")
	})

	// 4.2
	t.Run("am", func(t *testing.T) {
		assertEq(t, f.FormatTime("09:30"), "9:30a")
	})
}

// ================================================================
// Section 5: Locale — German
// ================================================================

func TestLocaleGerman(t *testing.T) {
	f := st.NewSayableTime(locales.DE)

	// 5.1
	t.Run("half_to_pattern", func(t *testing.T) {
		assertEq(t, f.FormatTime("15:30"), "halb vier")
	})
}

// ================================================================
// Section 6: Locale — French
// ================================================================

func TestLocaleFrench(t *testing.T) {
	f := st.NewSayableTime(locales.FR)

	// 6.1
	t.Run("quarter_past", func(t *testing.T) {
		assertEq(t, f.FormatTime("15:15"), "trois heures et quart")
	})
}

// ================================================================
// Section 7: Locale — Japanese
// ================================================================

func TestLocaleJapanese(t *testing.T) {
	f := st.NewSayableTime(locales.JA)

	// 7.1
	t.Run("half_past", func(t *testing.T) {
		assertEq(t, f.FormatTime("15:30"), "三時半")
	})
}

// ================================================================
// Section 8: Locale — Finnish (dot separator, short)
// ================================================================

func TestLocaleFinnishDotSeparator(t *testing.T) {
	f := st.NewSayableTime(locales.FI, st.Short)

	// 8.1
	t.Run("dot_separator", func(t *testing.T) {
		assertEq(t, f.FormatTime("14:15"), "14.15")
	})

	// 8.2
	t.Run("midnight_dot", func(t *testing.T) {
		assertEq(t, f.FormatTime("00:00"), "0.00")
	})
}

// ── Section 9: Minutes in short and compact modes ────────────────────────────────────

func TestSection9MinutesInShortAndCompactModes(t *testing.T) {
	assertEq(t, st.NewSayableTime(locales.EN, st.Short).FormatTime("18:01"), "6:01 PM") // 9.1
	assertEq(t, st.NewSayableTime(locales.EN, st.Compact).FormatTime("19:05"), "7:05p") // 9.2
}

// ── Section 10: Input validation ────────────────────────────────────

func TestSection10InputValidation(t *testing.T) {
	assertEq(t, st.NewSayableTime(locales.EN).FormatTime("9:30"), "half past nine")                     // 10.1
	assertEq(t, st.NewSayableTime(locales.EN).FormatTime("09:30"), "half past nine")                    // 10.2
	assertNil(t, st.NewSayableTime(locales.EN).FormatTime(" 9:30"))                                     // 10.3
	assertNil(t, st.NewSayableTime(locales.EN).FormatTime("9:30 "))                                     // 10.4
	assertNil(t, st.NewSayableTime(locales.EN).FormatTime("9:5"))                                       // 10.5
	assertNil(t, st.NewSayableTime(locales.EN).FormatTime("24:00"))                                     // 10.6
	assertEq(t, st.NewSayableTime(locales.EN).FormatTime("14:15:30"), "a quarter past two")             // 10.7
	assertEq(t, st.NewSayableTime(locales.EN).FormatTime("2025-01-15T14:15:00Z"), "a quarter past two") // 10.8
	assertNil(t, st.NewSayableTime(locales.EN).FormatTime("2025-02-30T14:15:00"))                       // 10.9
}
