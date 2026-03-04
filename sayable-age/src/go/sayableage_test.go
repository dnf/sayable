package sayableage_test

import (
	"testing"
	"time"

	sayableage "github.com/dnf/sayable/sayable-age/src/go"
	"github.com/dnf/sayable/sayable-age/src/go/locales"
)

// All tests use explicit (dob, asOf) pairs for determinism.

// en returns a default English SayableAge instance.
func en() *sayableage.SayableAge {
	return sayableage.NewSayableAge(locales.EN)
}

// helper to assert non-nil string pointer equals expected.
func assertAge(t *testing.T, name string, got *string, want string) {
	t.Helper()
	if got == nil {
		t.Errorf("%s: got nil, want %q", name, want)
		return
	}
	if *got != want {
		t.Errorf("%s: got %q, want %q", name, *got, want)
	}
}

// helper to assert nil result.
func assertNil(t *testing.T, name string, got *string) {
	t.Helper()
	if got != nil {
		t.Errorf("%s: got %q, want nil", name, *got)
	}
}

// helper to assert result contains substring.
func assertContains(t *testing.T, name string, got *string, substr string) {
	t.Helper()
	if got == nil {
		t.Errorf("%s: got nil, want string containing %q", name, substr)
		return
	}
	if len(*got) == 0 || !contains(*got, substr) {
		t.Errorf("%s: got %q, want string containing %q", name, *got, substr)
	}
}

func contains(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}

// ================================================================
// formatAge — null/edge cases
// ================================================================
func TestFormatAge_NullEdgeCases(t *testing.T) {
	pt := en()
	assertNil(t, "empty string", pt.FormatAge("", "2025-06-15"))                             // 1.1, 1.3
	assertNil(t, "future dob", pt.FormatAge("2025-07-01", "2025-06-15"))                     // 1.4
	assertAge(t, "exactly 500 years", pt.FormatAge("1525-06-15", "2025-06-15"), "500 years") // 1.5
	assertNil(t, "501 years exceeds max", pt.FormatAge("1524-06-15", "2025-06-15"))          // 1.6
	assertNil(t, "1000 years exceeds max", pt.FormatAge("1025-06-15", "2025-06-15"))         // 1.7
}

// ================================================================
// formatAge — days tier (0–6)
// ================================================================
func TestFormatAge_DaysTier(t *testing.T) {
	pt := en()
	tests := []struct {
		name string
		dob  string
		asOf string
		want string
	}{
		{"born today", "2025-06-15", "2025-06-15", "Newborn"},         // 2.1
		{"1 day ago (singular)", "2025-06-14", "2025-06-15", "1 day"}, // 2.2
		{"3 days ago", "2025-06-12", "2025-06-15", "3 days"},          // 2.3
		{"6 days ago", "2025-06-09", "2025-06-15", "6 days"},          // 2.4
		{"7 days → 1 week", "2025-06-08", "2025-06-15", "1 week"},     // 2.5
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			assertAge(t, tc.name, pt.FormatAge(tc.dob, tc.asOf), tc.want)
		})
	}
}

// ================================================================
// formatAge — weeks+days tier (7 days to <3 months)
// ================================================================
func TestFormatAge_WeeksDaysTier(t *testing.T) {
	pt := en()
	tests := []struct {
		name string
		dob  string
		asOf string
		want string
	}{
		{"7 days", "2025-06-08", "2025-06-15", "1 week"},                                    // 3.1
		{"8 days", "2025-06-07", "2025-06-15", "1 week, 1 day"},                             // 3.2
		{"9 days", "2025-06-06", "2025-06-15", "1 week, 2 days"},                            // 3.3
		{"13 days", "2025-06-02", "2025-06-15", "1 week, 6 days"},                           // 3.4
		{"14 days", "2025-06-01", "2025-06-15", "2 weeks"},                                  // 3.5
		{"15 days", "2025-05-31", "2025-06-15", "2 weeks, 1 day"},                           // 3.6
		{"20 days", "2025-05-26", "2025-06-15", "2 weeks, 6 days"},                          // 3.7
		{"21 days", "2025-05-25", "2025-06-15", "3 weeks"},                                  // 3.8
		{"at 1 cal month still weeks+days", "2025-05-15", "2025-06-15", "4 weeks, 3 days"},  // 3.9
		{"at 2 cal months still weeks+days", "2025-04-15", "2025-06-15", "8 weeks, 5 days"}, // 3.10
		{"one day before 3mo still weeks", "2025-03-15", "2025-06-14", "13 weeks"},          // 3.11
		{"on 3mo birthday switches", "2025-03-15", "2025-06-15", "3 months"},                // 3.12
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			assertAge(t, tc.name, pt.FormatAge(tc.dob, tc.asOf), tc.want)
		})
	}
}

// ================================================================
// formatAge — month boundaries: standard months
// ================================================================
func TestFormatAge_MonthBoundaryStandard(t *testing.T) {
	pt := en()
	assertAge(t, "Jan1 → Apr1 = 3mo", pt.FormatAge("2025-01-01", "2025-04-01"), "3 months")           // 4.1
	assertContains(t, "Jan1 → Mar31 still weeks", pt.FormatAge("2025-01-01", "2025-03-31"), "weeks")  // 4.2
	assertAge(t, "Jun15 → Sep15 = 3mo", pt.FormatAge("2025-06-15", "2025-09-15"), "3 months")         // 4.3
	assertContains(t, "Jun15 → Sep14 still weeks", pt.FormatAge("2025-06-15", "2025-09-14"), "weeks") // 4.4
	assertAge(t, "Jun15 → Dec15 = 6mo", pt.FormatAge("2025-06-15", "2025-12-15"), "6 months")         // 4.5
}

// ================================================================
// formatAge — month boundaries: February non-leap
// ================================================================
func TestFormatAge_MonthBoundaryFebNonLeap(t *testing.T) {
	pt := en()
	assertAge(t, "Jan31 → Feb28 non-leap", pt.FormatAge("2025-01-31", "2025-02-28"), "4 weeks")       // 5.1
	assertAge(t, "Jan31 → Apr30 = 3mo (clamp)", pt.FormatAge("2025-01-31", "2025-04-30"), "3 months") // 5.2
	assertContains(t, "Jan31 → Apr29 still weeks", pt.FormatAge("2025-01-31", "2025-04-29"), "weeks") // 5.3
	assertAge(t, "Feb1 → May1 = 3mo", pt.FormatAge("2025-02-01", "2025-05-01"), "3 months")           // 5.4
	assertContains(t, "Feb1 → Apr30 still weeks", pt.FormatAge("2025-02-01", "2025-04-30"), "weeks")  // 5.5
}

// ================================================================
// formatAge — month boundaries: February leap year
// ================================================================
func TestFormatAge_MonthBoundaryFebLeap(t *testing.T) {
	pt := en()
	assertAge(t, "Jan31 → Feb29 leap", pt.FormatAge("2024-01-31", "2024-02-29"), "4 weeks, 1 day")         // 6.1
	assertAge(t, "Jan31 → Feb28 leap", pt.FormatAge("2024-01-31", "2024-02-28"), "4 weeks")                // 6.2
	assertAge(t, "Jan31 → Apr30 leap = 3mo", pt.FormatAge("2024-01-31", "2024-04-30"), "3 months")         // 6.3
	assertContains(t, "Jan30 → Feb29 leap still weeks", pt.FormatAge("2024-01-30", "2024-02-29"), "weeks") // 6.4
	assertContains(t, "Jan30 → Feb28 leap still weeks", pt.FormatAge("2024-01-30", "2024-02-28"), "weeks") // 6.5
}

// ================================================================
// formatAge — month boundaries: 30-day months
// ================================================================
func TestFormatAge_MonthBoundary30Day(t *testing.T) {
	pt := en()
	assertAge(t, "Mar31 → Jun30 = 3mo (clamped)", pt.FormatAge("2025-03-31", "2025-06-30"), "3 months") // 7.1
	assertContains(t, "Mar31 → Jun29 still weeks", pt.FormatAge("2025-03-31", "2025-06-29"), "weeks")   // 7.2
	assertAge(t, "Aug31 → Nov30 = 3mo", pt.FormatAge("2025-08-31", "2025-11-30"), "3 months")           // 7.3
	assertContains(t, "Aug31 → Nov29 still weeks", pt.FormatAge("2025-08-31", "2025-11-29"), "weeks")   // 7.4
}

// ================================================================
// formatAge — month boundaries: leap year baby (born Feb 29)
// ================================================================
func TestFormatAge_LeapYearBaby(t *testing.T) {
	pt := en()
	assertAge(t, "Feb29 → May29 = 3mo", pt.FormatAge("2024-02-29", "2024-05-29"), "3 months")             // 8.1
	assertContains(t, "Feb29 → May28 still weeks", pt.FormatAge("2024-02-29", "2024-05-28"), "weeks")     // 8.2
	assertAge(t, "Feb29 2024 → Feb28 2025 = 12mo", pt.FormatAge("2024-02-29", "2025-02-28"), "12 months") // 8.3
	assertAge(t, "Feb29 2024 → Mar1 2025 = 12mo", pt.FormatAge("2024-02-29", "2025-03-01"), "12 months")  // 8.4
}

// ================================================================
// formatAge — months tier (3–23)
// ================================================================
func TestFormatAge_MonthsTier(t *testing.T) {
	pt := en()
	tests := []struct {
		name string
		dob  string
		asOf string
		want string
	}{
		{"3 months at transition", "2025-01-15", "2025-04-15", "3 months"},  // 9.1
		{"6 months", "2025-01-15", "2025-07-15", "6 months"},                // 9.2
		{"12 months (not 1 year)", "2024-06-15", "2025-06-15", "12 months"}, // 9.3
		{"23 months at upper", "2024-01-15", "2025-12-15", "23 months"},     // 9.4
		{"one day before boundary", "2025-01-15", "2025-07-14", "5 months"}, // 9.5
		{"crossing year boundary", "2024-11-10", "2025-04-10", "5 months"},  // 9.6
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			assertAge(t, tc.name, pt.FormatAge(tc.dob, tc.asOf), tc.want)
		})
	}
}

// ================================================================
// formatAge — years+months tier (24–35 months)
// ================================================================
func TestFormatAge_YearsMonthsTier(t *testing.T) {
	pt := en()
	tests := []struct {
		name string
		dob  string
		asOf string
		want string
	}{
		{"2 years at 24mo", "2023-06-15", "2025-06-15", "2 years"},              // 10.1
		{"2 years 1 month", "2023-06-15", "2025-07-15", "2 years, 1 month"},     // 10.2
		{"2 years 6 months", "2023-06-15", "2025-12-15", "2 years, 6 months"},   // 10.3
		{"2 years 11 months", "2023-06-15", "2026-05-15", "2 years, 11 months"}, // 10.4
		{"one day before 24mo", "2023-06-15", "2025-06-14", "23 months"},        // 10.5
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			assertAge(t, tc.name, pt.FormatAge(tc.dob, tc.asOf), tc.want)
		})
	}
}

// ================================================================
// formatAge — half-year tier (3–6 years)
// ================================================================
func TestFormatAge_HalfYearTier(t *testing.T) {
	pt := en()
	tests := []struct {
		name string
		dob  string
		asOf string
		want string
	}{
		{"3 years exactly", "2022-06-15", "2025-06-15", "3 years"},                    // 11.1
		{"3 years 5 months", "2022-06-15", "2025-11-15", "3 years"},                   // 11.2
		{"3½ years at 3y6m", "2022-06-15", "2025-12-15", "3\u00BD years"},             // 11.3
		{"3½ years at 3y11m", "2022-06-15", "2026-05-15", "3\u00BD years"},            // 11.4
		{"4 years exactly", "2021-06-15", "2025-06-15", "4 years"},                    // 11.5
		{"4½ years", "2021-06-15", "2025-12-15", "4\u00BD years"},                     // 11.6
		{"5 years", "2020-06-15", "2025-06-15", "5 years"},                            // 11.7
		{"5½ years at 5y8m", "2020-06-15", "2026-02-15", "5\u00BD years"},             // 11.8
		{"6 years", "2019-06-15", "2025-06-15", "6 years"},                            // 11.9
		{"6½ years", "2019-06-15", "2025-12-15", "6\u00BD years"},                     // 11.10
		{"6½ years at 6y11m", "2019-06-15", "2026-05-15", "6\u00BD years"},            // 11.11
		{"one day before 3rd bday", "2022-06-15", "2025-06-14", "2 years, 11 months"}, // 11.12
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			assertAge(t, tc.name, pt.FormatAge(tc.dob, tc.asOf), tc.want)
		})
	}
}

// ================================================================
// formatAge — integer tier (7+ years)
// ================================================================
func TestFormatAge_IntegerTier(t *testing.T) {
	pt := en()
	assertAge(t, "7 years exactly", pt.FormatAge("2018-06-15", "2025-06-15"), "7 years")         // 12.1
	assertAge(t, "7 years 6 months (no ½)", pt.FormatAge("2018-03-20", "2025-06-15"), "7 years") // 12.2
	assertAge(t, "45 years", pt.FormatAge("1980-01-01", "2025-06-15"), "45 years")               // 12.3
}

// ================================================================
// formatAge — cross-year transitions with Feb
// ================================================================
func TestFormatAge_CrossYearFeb(t *testing.T) {
	pt := en()
	assertAge(t, "Dec31 → Mar31 = 3mo", pt.FormatAge("2024-12-31", "2025-03-31"), "3 months")         // 13.1
	assertContains(t, "Dec31 → Mar30 still weeks", pt.FormatAge("2024-12-31", "2025-03-30"), "weeks") // 13.2
	assertAge(t, "Nov30 → Feb28 = 3mo", pt.FormatAge("2024-11-30", "2025-02-28"), "3 months")         // 13.3
	assertContains(t, "Nov30 → Feb27 still weeks", pt.FormatAge("2024-11-30", "2025-02-27"), "weeks") // 13.4
}

// ================================================================
// formatAge — born-on-31st progression
// ================================================================
func TestFormatAge_BornOn31st(t *testing.T) {
	pt := en()
	tests := []struct {
		name string
		dob  string
		asOf string
		want string
	}{
		{"Jan31 → Apr30 = 3mo", "2025-01-31", "2025-04-30", "3 months"},           // 14.1
		{"Jan31 → May31 = 4mo", "2025-01-31", "2025-05-31", "4 months"},           // 14.2
		{"Jan31 → Jun30 = 5mo (clamped)", "2025-01-31", "2025-06-30", "5 months"}, // 14.3
		{"Jan31 → Jul1 = 5mo", "2025-01-31", "2025-07-01", "5 months"},            // 14.4
		{"Jan31 → Jul31 = 6mo", "2025-01-31", "2025-07-31", "6 months"},           // 14.5
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			assertAge(t, tc.name, pt.FormatAge(tc.dob, tc.asOf), tc.want)
		})
	}
}

// ================================================================
// formatAge — default asOf (uses current date)
// ================================================================
func TestFormatAge_DefaultAsOf(t *testing.T) {
	sayableage.SetTimeNow(func() time.Time {
		return time.Date(2025, 6, 15, 0, 0, 0, 0, time.UTC)
	})
	defer sayableage.RestoreTimeNow()
	pt := en()
	assertAge(t, "5 years from today", pt.FormatAge("2020-01-01"), "5 years") // 15.1
	assertAge(t, "5 days from today", pt.FormatAge("2025-06-10"), "5 days")   // 15.2
}

// ================================================================
// formatStage
// ================================================================
func TestFormatStage_NullEdgeCases(t *testing.T) {
	pt := en()
	assertNil(t, "empty string", pt.FormatStage("", "2025-06-15"))                          // 16.1, 16.3
	assertNil(t, "future dob", pt.FormatStage("2025-07-01", "2025-06-15"))                  // 16.4
	assertAge(t, "stage 500 years", pt.FormatStage("1525-06-15", "2025-06-15"), "Adult")    // 16.5
	assertNil(t, "stage 501 years exceeds max", pt.FormatStage("1524-06-15", "2025-06-15")) // 16.6
}

func TestFormatStage_Newborn(t *testing.T) {
	pt := en()
	assertAge(t, "born today", pt.FormatStage("2025-06-15", "2025-06-15"), "Newborn")               // 17.1
	assertAge(t, "1 day old", pt.FormatStage("2025-06-14", "2025-06-15"), "Newborn")                // 17.2
	assertAge(t, "3 weeks old", pt.FormatStage("2025-05-25", "2025-06-15"), "Newborn")              // 17.3
	assertAge(t, "1 month old", pt.FormatStage("2025-05-15", "2025-06-15"), "Newborn")              // 17.4
	assertAge(t, "1 month 29 days", pt.FormatStage("2025-04-16", "2025-06-15"), "Newborn")          // 17.5
	assertAge(t, "exactly 2 months → Infant", pt.FormatStage("2025-04-15", "2025-06-15"), "Infant") // 17.6
}

func TestFormatStage_Infant(t *testing.T) {
	pt := en()
	assertAge(t, "2 months", pt.FormatStage("2025-04-15", "2025-06-15"), "Infant")                // 18.1
	assertAge(t, "6 months", pt.FormatStage("2024-12-15", "2025-06-15"), "Infant")                // 18.2
	assertAge(t, "11 months", pt.FormatStage("2024-07-15", "2025-06-15"), "Infant")               // 18.3
	assertAge(t, "exactly 12mo → Toddler", pt.FormatStage("2024-06-15", "2025-06-15"), "Toddler") // 18.4
}

func TestFormatStage_Toddler(t *testing.T) {
	pt := en()
	assertAge(t, "12 months", pt.FormatStage("2024-06-15", "2025-06-15"), "Toddler")          // 19.1
	assertAge(t, "18 months", pt.FormatStage("2024-01-15", "2025-07-15"), "Toddler")          // 19.2
	assertAge(t, "24 months", pt.FormatStage("2023-06-15", "2025-06-15"), "Toddler")          // 19.3
	assertAge(t, "35 months", pt.FormatStage("2023-06-15", "2026-05-15"), "Toddler")          // 19.4
	assertAge(t, "exactly 36mo → Child", pt.FormatStage("2022-06-15", "2025-06-15"), "Child") // 19.5
}

func TestFormatStage_Child(t *testing.T) {
	pt := en()
	assertAge(t, "3 years", pt.FormatStage("2022-06-15", "2025-06-15"), "Child")                   // 20.1
	assertAge(t, "4 years", pt.FormatStage("2021-06-15", "2025-06-15"), "Child")                   // 20.2
	assertAge(t, "6 years", pt.FormatStage("2019-06-15", "2025-06-15"), "Child")                   // 20.3
	assertAge(t, "9 years", pt.FormatStage("2016-06-15", "2025-06-15"), "Child")                   // 20.4
	assertAge(t, "12y 11mo", pt.FormatStage("2013-06-15", "2026-05-15"), "Child")                  // 20.5
	assertAge(t, "exactly 13y → Teenager", pt.FormatStage("2012-06-15", "2025-06-15"), "Teenager") // 20.6
}

func TestFormatStage_Teenager(t *testing.T) {
	pt := en()
	assertAge(t, "13 years", pt.FormatStage("2012-06-15", "2025-06-15"), "Teenager")         // 21.1
	assertAge(t, "15 years", pt.FormatStage("2010-06-15", "2025-06-15"), "Teenager")         // 21.2
	assertAge(t, "17y 11mo", pt.FormatStage("2008-06-15", "2026-05-15"), "Teenager")         // 21.3
	assertAge(t, "exactly 18y → Adult", pt.FormatStage("2007-06-15", "2025-06-15"), "Adult") // 21.4
}

func TestFormatStage_Adult(t *testing.T) {
	pt := en()
	assertAge(t, "18 years", pt.FormatStage("2007-06-15", "2025-06-15"), "Adult") // 22.1
	assertAge(t, "25 years", pt.FormatStage("2000-06-15", "2025-06-15"), "Adult") // 22.2
	assertAge(t, "45 years", pt.FormatStage("1980-01-01", "2025-06-15"), "Adult") // 22.3
}

func TestFormatStage_DefaultAsOf(t *testing.T) {
	sayableage.SetTimeNow(func() time.Time {
		return time.Date(2025, 6, 15, 0, 0, 0, 0, time.UTC)
	})
	defer sayableage.RestoreTimeNow()
	pt := en()
	assertAge(t, "Newborn", pt.FormatStage("2025-06-15"), "Newborn") // 23.1
	assertAge(t, "Child", pt.FormatStage("2020-01-01"), "Child")     // 23.2
	assertAge(t, "Adult", pt.FormatStage("1980-01-01"), "Adult")     // 23.3
}

// ================================================================
// SayableAge class with English locale
// ================================================================
func TestSayableAge_English(t *testing.T) {
	pt := sayableage.NewSayableAge(locales.EN)
	assertAge(t, "Newborn", pt.FormatAge("2025-06-15", "2025-06-15"), "Newborn")            // 24.1
	assertAge(t, "3 days", pt.FormatAge("2025-06-12", "2025-06-15"), "3 days")              // 24.2
	assertAge(t, "1 week 1 day", pt.FormatAge("2025-06-07", "2025-06-15"), "1 week, 1 day") // 24.3
	assertAge(t, "6 months", pt.FormatAge("2025-01-15", "2025-07-15"), "6 months")          // 24.4
	assertAge(t, "2y 1mo", pt.FormatAge("2023-06-15", "2025-07-15"), "2 years, 1 month")    // 24.5
	assertAge(t, "3½ years", pt.FormatAge("2022-06-15", "2025-12-15"), "3\u00BD years")     // 24.6
	assertAge(t, "7 years", pt.FormatAge("2018-06-15", "2025-06-15"), "7 years")            // 24.7

	assertAge(t, "stage Newborn", pt.FormatStage("2025-06-15", "2025-06-15"), "Newborn")   // 24.8
	assertAge(t, "stage Infant", pt.FormatStage("2025-01-15", "2025-06-15"), "Infant")     // 24.9
	assertAge(t, "stage Toddler", pt.FormatStage("2024-06-15", "2025-06-15"), "Toddler")   // 24.10
	assertAge(t, "stage Child", pt.FormatStage("2022-06-15", "2025-06-15"), "Child")       // 24.11
	assertAge(t, "stage Teenager", pt.FormatStage("2012-06-15", "2025-06-15"), "Teenager") // 24.12
	assertAge(t, "stage Adult", pt.FormatStage("2007-06-15", "2025-06-15"), "Adult")       // 24.13

	assertNil(t, "null age", pt.FormatAge(""))     // 24.14
	assertNil(t, "null stage", pt.FormatStage("")) // 24.15
}

// ================================================================
// SayableAge with Spanish-like locale
// ================================================================
func TestSayableAge_Spanish(t *testing.T) {
	es := sayableage.AgeLocale{
		Code: "es",
		Plural: func(n int) sayableage.PluralCategory {
			if n == 1 {
				return sayableage.One
			}
			return sayableage.Other
		},
		Units: struct{ Day, Week, Month, Year sayableage.UnitForms }{
			Day:   sayableage.PluralUnit(map[sayableage.PluralCategory]string{sayableage.One: "{n} día", sayableage.Other: "{n} días"}),
			Week:  sayableage.PluralUnit(map[sayableage.PluralCategory]string{sayableage.One: "{n} semana", sayableage.Other: "{n} semanas"}),
			Month: sayableage.PluralUnit(map[sayableage.PluralCategory]string{sayableage.One: "{n} mes", sayableage.Other: "{n} meses"}),
			Year:  sayableage.PluralUnit(map[sayableage.PluralCategory]string{sayableage.One: "{n} año", sayableage.Other: "{n} años"}),
		},
		Half:      "{n} y medio",
		Delimiter: ", ",
		JustBorn:  "Recién nacido",
		Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult sayableage.StageLabel }{
			Newborn:  sayableage.G("Recién nacido", "Recién nacida"),
			Infant:   sayableage.S("Bebé"),
			Toddler:  sayableage.G("Niño pequeño", "Niña pequeña"),
			Child:    sayableage.G("Niño", "Niña"),
			Teenager: sayableage.S("Adolescente"),
			Adult:    sayableage.G("Adulto", "Adulta"),
		},
	}

	pt := sayableage.NewSayableAge(es)

	assertAge(t, "justBorn", pt.FormatAge("2025-06-15", "2025-06-15"), "Recién nacido")                // 25.1
	assertAge(t, "singular day", pt.FormatAge("2025-06-14", "2025-06-15"), "1 día")                    // 25.2
	assertAge(t, "plural days", pt.FormatAge("2025-06-12", "2025-06-15"), "3 días")                    // 25.3
	assertAge(t, "singular week", pt.FormatAge("2025-06-08", "2025-06-15"), "1 semana")                // 25.4
	assertAge(t, "weeks+days", pt.FormatAge("2025-06-07", "2025-06-15"), "1 semana, 1 día")            // 25.5
	assertAge(t, "plural weeks+days", pt.FormatAge("2025-05-26", "2025-06-15"), "2 semanas, 6 días")   // 25.6
	assertAge(t, "months", pt.FormatAge("2025-01-15", "2025-07-15"), "6 meses")                        // 25.7
	assertAge(t, "singular month compound", pt.FormatAge("2023-06-15", "2025-07-15"), "2 años, 1 mes") // 25.8
	assertAge(t, "years+months", pt.FormatAge("2023-06-15", "2025-12-15"), "2 años, 6 meses")          // 25.9
	assertAge(t, "half marker", pt.FormatAge("2022-06-15", "2025-12-15"), "3 y medio años")            // 25.10
	assertAge(t, "integer years", pt.FormatAge("2022-06-15", "2025-06-15"), "3 años")                  // 25.11
	assertAge(t, "7+ years", pt.FormatAge("2018-06-15", "2025-06-15"), "7 años")                       // 25.12

	assertAge(t, "stage newborn", pt.FormatStage("2025-06-15", "2025-06-15"), "Recién nacido") // 25.13
	assertAge(t, "stage infant", pt.FormatStage("2025-01-15", "2025-06-15"), "Bebé")           // 25.14
	assertAge(t, "stage toddler", pt.FormatStage("2024-06-15", "2025-06-15"), "Niño pequeño")  // 25.15
	assertAge(t, "stage child", pt.FormatStage("2022-06-15", "2025-06-15"), "Niño")            // 25.16
	assertAge(t, "stage teenager", pt.FormatStage("2012-06-15", "2025-06-15"), "Adolescente")  // 25.17
	assertAge(t, "stage adult", pt.FormatStage("2007-06-15", "2025-06-15"), "Adulto")          // 25.18

	assertNil(t, "null", pt.FormatAge(""))         // 25.19
	assertNil(t, "null stage", pt.FormatStage("")) // 25.20
}

// ================================================================
// Compactness: short
// ================================================================
func TestSayableAge_CompactShort(t *testing.T) {
	pt := sayableage.NewSayableAge(locales.EN, sayableage.Short)

	assertAge(t, "days", pt.FormatAge("2025-06-12", "2025-06-15"), "3 d")                   // 26.1
	assertAge(t, "weeks", pt.FormatAge("2025-06-08", "2025-06-15"), "1 wk")                 // 26.2
	assertAge(t, "weeks+days", pt.FormatAge("2025-06-07", "2025-06-15"), "1 wk, 1 d")       // 26.3
	assertAge(t, "months", pt.FormatAge("2025-01-15", "2025-07-15"), "6 mo")                // 26.4
	assertAge(t, "years+months", pt.FormatAge("2023-06-15", "2025-07-15"), "2 yr, 1 mo")    // 26.5
	assertAge(t, "half years", pt.FormatAge("2022-06-15", "2025-12-15"), "3\u00BD yr")      // 26.6
	assertAge(t, "integer years", pt.FormatAge("2018-06-15", "2025-06-15"), "7 yr")         // 26.7
	assertAge(t, "justBorn unchanged", pt.FormatAge("2025-06-15", "2025-06-15"), "Newborn") // 26.8
	assertAge(t, "stages unchanged", pt.FormatStage("2025-01-15", "2025-06-15"), "Infant")  // 26.9
}

// ================================================================
// Compactness: compact
// ================================================================
func TestSayableAge_CompactCompact(t *testing.T) {
	pt := sayableage.NewSayableAge(locales.EN, sayableage.Compact)

	assertAge(t, "days", pt.FormatAge("2025-06-12", "2025-06-15"), "3d")                        // 27.1
	assertAge(t, "weeks", pt.FormatAge("2025-06-08", "2025-06-15"), "1w")                       // 27.2
	assertAge(t, "weeks+days no delimiter", pt.FormatAge("2025-06-07", "2025-06-15"), "1w1d")   // 27.3
	assertAge(t, "months", pt.FormatAge("2025-01-15", "2025-07-15"), "6m")                      // 27.4
	assertAge(t, "years+months no delimiter", pt.FormatAge("2023-06-15", "2025-07-15"), "2y1m") // 27.5
	assertAge(t, "half years", pt.FormatAge("2022-06-15", "2025-12-15"), "3\u00BDy")            // 27.6
	assertAge(t, "integer years", pt.FormatAge("2018-06-15", "2025-06-15"), "7y")               // 27.7
	assertAge(t, "justBorn unchanged", pt.FormatAge("2025-06-15", "2025-06-15"), "Newborn")     // 27.8
}

// ================================================================
// formatStage — gender support
// ================================================================
func TestFormatStage_GenderNeutralLocale(t *testing.T) {
	pt := sayableage.NewSayableAge(locales.EN)
	// English has all S() labels — gender param should have no effect
	assertAge(t, "en no gender", pt.FormatStage("2025-06-15", "2025-06-15"), "Newborn")
	assertAge(t, "en masculine", pt.FormatStage("2025-06-15", "2025-06-15", "m"), "Newborn")
	assertAge(t, "en feminine", pt.FormatStage("2025-06-15", "2025-06-15", "f"), "Newborn")
	assertAge(t, "en adult no gender", pt.FormatStage("2007-06-15", "2025-06-15"), "Adult")
	assertAge(t, "en adult m", pt.FormatStage("2007-06-15", "2025-06-15", "m"), "Adult")
	assertAge(t, "en adult f", pt.FormatStage("2007-06-15", "2025-06-15", "f"), "Adult")
}

func TestFormatStage_GenderedLocaleSpanish(t *testing.T) {
	pt := sayableage.NewSayableAge(locales.ES)

	// Default (no gender) returns masculine for gendered labels
	assertAge(t, "es newborn default", pt.FormatStage("2025-06-15", "2025-06-15"), "Recién nacido")
	assertAge(t, "es toddler default", pt.FormatStage("2024-06-15", "2025-06-15"), "Niño pequeño")
	assertAge(t, "es child default", pt.FormatStage("2022-06-15", "2025-06-15"), "Niño")
	assertAge(t, "es adult default", pt.FormatStage("2007-06-15", "2025-06-15"), "Adulto")

	// Masculine
	assertAge(t, "es newborn m", pt.FormatStage("2025-06-15", "2025-06-15", "m"), "Recién nacido")
	assertAge(t, "es toddler m", pt.FormatStage("2024-06-15", "2025-06-15", "m"), "Niño pequeño")
	assertAge(t, "es child m", pt.FormatStage("2022-06-15", "2025-06-15", "m"), "Niño")
	assertAge(t, "es adult m", pt.FormatStage("2007-06-15", "2025-06-15", "m"), "Adulto")

	// Feminine
	assertAge(t, "es newborn f", pt.FormatStage("2025-06-15", "2025-06-15", "f"), "Recién nacida")
	assertAge(t, "es toddler f", pt.FormatStage("2024-06-15", "2025-06-15", "f"), "Niña pequeña")
	assertAge(t, "es child f", pt.FormatStage("2022-06-15", "2025-06-15", "f"), "Niña")
	assertAge(t, "es adult f", pt.FormatStage("2007-06-15", "2025-06-15", "f"), "Adulta")

	// Gender-neutral labels (S()) ignore gender
	assertAge(t, "es infant neutral", pt.FormatStage("2025-01-15", "2025-06-15"), "Bebé")
	assertAge(t, "es infant m", pt.FormatStage("2025-01-15", "2025-06-15", "m"), "Bebé")
	assertAge(t, "es infant f", pt.FormatStage("2025-01-15", "2025-06-15", "f"), "Bebé")
	assertAge(t, "es teenager neutral", pt.FormatStage("2012-06-15", "2025-06-15"), "Adolescente")
	assertAge(t, "es teenager m", pt.FormatStage("2012-06-15", "2025-06-15", "m"), "Adolescente")
	assertAge(t, "es teenager f", pt.FormatStage("2012-06-15", "2025-06-15", "f"), "Adolescente")
}

func TestFormatStage_GenderedLocaleArabic(t *testing.T) {
	pt := sayableage.NewSayableAge(locales.AR)

	// All stages are gendered in Arabic
	assertAge(t, "ar newborn m", pt.FormatStage("2025-06-15", "2025-06-15", "m"), "حديث الولادة")
	assertAge(t, "ar newborn f", pt.FormatStage("2025-06-15", "2025-06-15", "f"), "حديثة الولادة")
	assertAge(t, "ar infant m", pt.FormatStage("2025-01-15", "2025-06-15", "m"), "رضيع")
	assertAge(t, "ar infant f", pt.FormatStage("2025-01-15", "2025-06-15", "f"), "رضيعة")
	assertAge(t, "ar toddler m", pt.FormatStage("2024-06-15", "2025-06-15", "m"), "طفل صغير")
	assertAge(t, "ar toddler f", pt.FormatStage("2024-06-15", "2025-06-15", "f"), "طفلة صغيرة")
	assertAge(t, "ar child m", pt.FormatStage("2022-06-15", "2025-06-15", "m"), "طفل")
	assertAge(t, "ar child f", pt.FormatStage("2022-06-15", "2025-06-15", "f"), "طفلة")
	assertAge(t, "ar teenager m", pt.FormatStage("2012-06-15", "2025-06-15", "m"), "مراهق")
	assertAge(t, "ar teenager f", pt.FormatStage("2012-06-15", "2025-06-15", "f"), "مراهقة")
	assertAge(t, "ar adult m", pt.FormatStage("2007-06-15", "2025-06-15", "m"), "بالغ")
	assertAge(t, "ar adult f", pt.FormatStage("2007-06-15", "2025-06-15", "f"), "بالغة")
}

func TestFormatStage_GenderEdgeCases(t *testing.T) {
	pt := sayableage.NewSayableAge(locales.ES)

	// Nil for invalid input
	assertNil(t, "empty dob", pt.FormatStage(""))
	assertNil(t, "empty dob with gender", pt.FormatStage("", "", "f"))
	assertNil(t, "future dob with gender", pt.FormatStage("2025-07-01", "2025-06-15", "f"))
}

func TestFormatStage_ENGender(t *testing.T) {
	// EN is all neutral — gender param should have no effect
	pt := sayableage.NewSayableAge(locales.EN)
	assertAge(t, "EN FormatStage no gender", pt.FormatStage("2007-06-15", "2025-06-15"), "Adult")
	assertAge(t, "EN FormatStage m", pt.FormatStage("2007-06-15", "2025-06-15", "m"), "Adult")
	assertAge(t, "EN FormatStage f", pt.FormatStage("2007-06-15", "2025-06-15", "f"), "Adult")
}

func TestResolveStage_Direct(t *testing.T) {
	// Test the ResolveStage function directly
	neutral := sayableage.S("Newborn")
	if got := sayableage.ResolveStage(neutral, ""); got != "Newborn" {
		t.Errorf("neutral no gender: got %q, want %q", got, "Newborn")
	}
	if got := sayableage.ResolveStage(neutral, "m"); got != "Newborn" {
		t.Errorf("neutral m: got %q, want %q", got, "Newborn")
	}
	if got := sayableage.ResolveStage(neutral, "f"); got != "Newborn" {
		t.Errorf("neutral f: got %q, want %q", got, "Newborn")
	}

	gendered := sayableage.G("Adulto", "Adulta")
	if got := sayableage.ResolveStage(gendered, ""); got != "Adulto" {
		t.Errorf("gendered no gender: got %q, want %q", got, "Adulto")
	}
	if got := sayableage.ResolveStage(gendered, "m"); got != "Adulto" {
		t.Errorf("gendered m: got %q, want %q", got, "Adulto")
	}
	if got := sayableage.ResolveStage(gendered, "f"); got != "Adulta" {
		t.Errorf("gendered f: got %q, want %q", got, "Adulta")
	}
}

// ================================================================
// Section 29: Locale-specific edge cases — new plural rules
// ================================================================

func TestLocale_Hebrew(t *testing.T) {
	pt := sayableage.NewSayableAge(locales.HE)

	assertAge(t, "he justBorn", pt.FormatAge("2025-06-15", "2025-06-15"), "רק נולד")                // 29.1
	assertAge(t, "he 1 day one", pt.FormatAge("2025-06-14", "2025-06-15"), "יום 1")                 // 29.2
	assertAge(t, "he 3 days other", pt.FormatAge("2025-06-12", "2025-06-15"), "3 ימים")             // 29.3
	assertAge(t, "he 2 weeks dual", pt.FormatAge("2025-06-01", "2025-06-15"), "שבועיים")            // 29.4
	assertAge(t, "he 3 weeks other", pt.FormatAge("2025-05-25", "2025-06-15"), "3 שבועות")          // 29.5
	assertAge(t, "he 6 months", pt.FormatAge("2025-01-15", "2025-07-15"), "6 חודשים")               // 29.6
	assertAge(t, "he 3 months", pt.FormatAge("2025-03-15", "2025-06-15"), "3 חודשים")               // 29.7
	assertAge(t, "he 2y dual 1m one", pt.FormatAge("2023-06-15", "2025-07-15"), "שנתיים, חודש 1")   // 29.8
	assertAge(t, "he 3.5y half", pt.FormatAge("2022-06-15", "2025-12-15"), "3 שנים וחצי")           // 29.9
	assertAge(t, "he 7y other", pt.FormatAge("2018-06-15", "2025-06-15"), "7 שנים")                 // 29.10
	assertAge(t, "he stage m newborn", pt.FormatStage("2025-06-15", "2025-06-15", "m"), "רק נולד")  // 29.11
	assertAge(t, "he stage f newborn", pt.FormatStage("2025-06-15", "2025-06-15", "f"), "רק נולדה") // 29.12
	assertAge(t, "he stage m adult", pt.FormatStage("2007-06-15", "2025-06-15", "m"), "מבוגר")      // 29.13
	assertAge(t, "he stage f adult", pt.FormatStage("2007-06-15", "2025-06-15", "f"), "מבוגרת")     // 29.14
}

func TestLocale_Macedonian(t *testing.T) {
	pt := sayableage.NewSayableAge(locales.MK)

	assertAge(t, "mk justBorn", pt.FormatAge("2025-06-15", "2025-06-15"), "Новороденче")             // 29.15
	assertAge(t, "mk 1 day one", pt.FormatAge("2025-06-14", "2025-06-15"), "1 ден")                  // 29.16
	assertAge(t, "mk 3 days other", pt.FormatAge("2025-06-12", "2025-06-15"), "3 дена")              // 29.17
	assertAge(t, "mk 6 months", pt.FormatAge("2025-01-15", "2025-07-15"), "6 месеци")                // 29.18
	assertAge(t, "mk 2y1m one month", pt.FormatAge("2023-06-15", "2025-07-15"), "2 години, 1 месец") // 29.19
	assertAge(t, "mk 3.5y half", pt.FormatAge("2022-06-15", "2025-12-15"), "3 години и пол")         // 29.20
	assertAge(t, "mk 7y", pt.FormatAge("2018-06-15", "2025-06-15"), "7 години")                      // 29.21
}

func TestLocale_Swahili(t *testing.T) {
	pt := sayableage.NewSayableAge(locales.SW)

	assertAge(t, "sw justBorn", pt.FormatAge("2025-06-15", "2025-06-15"), "Mzaliwa mpya")     // 29.22
	assertAge(t, "sw 1 day", pt.FormatAge("2025-06-14", "2025-06-15"), "siku 1")              // 29.23
	assertAge(t, "sw 3 days", pt.FormatAge("2025-06-12", "2025-06-15"), "siku 3")             // 29.24
	assertAge(t, "sw 6 months", pt.FormatAge("2025-01-15", "2025-07-15"), "miezi 6")          // 29.25
	assertAge(t, "sw 2y 1m", pt.FormatAge("2023-06-15", "2025-07-15"), "miaka 2, mwezi 1")    // 29.26
	assertAge(t, "sw 3.5y half", pt.FormatAge("2022-06-15", "2025-12-15"), "miaka 3 na nusu") // 29.27
}

func TestLocale_Indonesian(t *testing.T) {
	pt := sayableage.NewSayableAge(locales.ID)

	assertAge(t, "id justBorn", pt.FormatAge("2025-06-15", "2025-06-15"), "Baru lahir")        // 29.28
	assertAge(t, "id 1 day", pt.FormatAge("2025-06-14", "2025-06-15"), "1 hari")               // 29.29
	assertAge(t, "id 3 days", pt.FormatAge("2025-06-12", "2025-06-15"), "3 hari")              // 29.30
	assertAge(t, "id 6 months", pt.FormatAge("2025-01-15", "2025-07-15"), "6 bulan")           // 29.31
	assertAge(t, "id 3.5y half", pt.FormatAge("2022-06-15", "2025-12-15"), "3 tahun setengah") // 29.32
	assertAge(t, "id 7y", pt.FormatAge("2018-06-15", "2025-06-15"), "7 tahun")                 // 29.33
}

func TestLocale_Amharic(t *testing.T) {
	pt := sayableage.NewSayableAge(locales.AM)

	assertAge(t, "am justBorn", pt.FormatAge("2025-06-15", "2025-06-15"), "አዲስ የተወለደ")         // 29.34
	assertAge(t, "am 1 day", pt.FormatAge("2025-06-14", "2025-06-15"), "1 ቀን")                 // 29.35
	assertAge(t, "am 3 days", pt.FormatAge("2025-06-12", "2025-06-15"), "3 ቀናት")               // 29.36
	assertAge(t, "am 1w1d ethiopic", pt.FormatAge("2025-06-07", "2025-06-15"), "1 ሳምንት፣ 1 ቀን") // 29.37
	assertAge(t, "am 6 months", pt.FormatAge("2025-01-15", "2025-07-15"), "6 ወራት")             // 29.38
	assertAge(t, "am 3.5y half", pt.FormatAge("2022-06-15", "2025-12-15"), "3 ዓመታት ተኩል")       // 29.39
}

// ================================================================
// Section 30: Locale lookup by code string
// ================================================================

func TestGetLocale(t *testing.T) {
	// 30.1 Known locale
	loc := locales.GetLocale("en")
	if loc == nil {
		t.Fatal("GetLocale(\"en\") returned nil")
	}
	if loc.Code != "en" {
		t.Errorf("GetLocale(\"en\").Code = %q, want %q", loc.Code, "en")
	}

	// 30.2 Another known locale
	loc = locales.GetLocale("fr")
	if loc == nil {
		t.Fatal("GetLocale(\"fr\") returned nil")
	}
	if loc.Code != "fr" {
		t.Errorf("GetLocale(\"fr\").Code = %q, want %q", loc.Code, "fr")
	}

	// 30.3 Unknown code
	if locales.GetLocale("xx") != nil {
		t.Error("GetLocale(\"xx\") should be nil")
	}

	// 30.4 Empty string
	if locales.GetLocale("") != nil {
		t.Error("GetLocale(\"\") should be nil")
	}

	// 30.5 Case-sensitive
	if locales.GetLocale("EN") != nil {
		t.Error("GetLocale(\"EN\") should be nil (case-sensitive)")
	}
}
