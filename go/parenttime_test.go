package parenttime

import (
	"testing"
	"time"
)

// All tests use explicit (dob, asOf) pairs for determinism.

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
	assertNil(t, "empty string", FormatAge("", "2025-06-15"))
	assertNil(t, "future dob", FormatAge("2025-07-01", "2025-06-15"))
}

// ================================================================
// formatAge — days tier (0–6)
// ================================================================
func TestFormatAge_DaysTier(t *testing.T) {
	tests := []struct {
		name string
		dob  string
		asOf string
		want string
	}{
		{"born today", "2025-06-15", "2025-06-15", "Newborn"},
		{"1 day ago (singular)", "2025-06-14", "2025-06-15", "1 day"},
		{"3 days ago", "2025-06-12", "2025-06-15", "3 days"},
		{"6 days ago", "2025-06-09", "2025-06-15", "6 days"},
		{"7 days → 1 week", "2025-06-08", "2025-06-15", "1 week"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			assertAge(t, tc.name, FormatAge(tc.dob, tc.asOf), tc.want)
		})
	}
}

// ================================================================
// formatAge — weeks+days tier (7 days to <3 months)
// ================================================================
func TestFormatAge_WeeksDaysTier(t *testing.T) {
	tests := []struct {
		name string
		dob  string
		asOf string
		want string
	}{
		{"7 days", "2025-06-08", "2025-06-15", "1 week"},
		{"8 days", "2025-06-07", "2025-06-15", "1 week, 1 day"},
		{"9 days", "2025-06-06", "2025-06-15", "1 week, 2 days"},
		{"13 days", "2025-06-02", "2025-06-15", "1 week, 6 days"},
		{"14 days", "2025-06-01", "2025-06-15", "2 weeks"},
		{"15 days", "2025-05-31", "2025-06-15", "2 weeks, 1 day"},
		{"20 days", "2025-05-26", "2025-06-15", "2 weeks, 6 days"},
		{"21 days", "2025-05-25", "2025-06-15", "3 weeks"},
		{"at 1 cal month still weeks+days", "2025-05-15", "2025-06-15", "4 weeks, 3 days"},
		{"at 2 cal months still weeks+days", "2025-04-15", "2025-06-15", "8 weeks, 5 days"},
		{"one day before 3mo still weeks", "2025-03-15", "2025-06-14", "13 weeks"},
		{"on 3mo birthday switches", "2025-03-15", "2025-06-15", "3 months"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			assertAge(t, tc.name, FormatAge(tc.dob, tc.asOf), tc.want)
		})
	}
}

// ================================================================
// formatAge — month boundaries: standard months
// ================================================================
func TestFormatAge_MonthBoundaryStandard(t *testing.T) {
	assertAge(t, "Jan1 → Apr1 = 3mo", FormatAge("2025-01-01", "2025-04-01"), "3 months")
	assertContains(t, "Jan1 → Mar31 still weeks", FormatAge("2025-01-01", "2025-03-31"), "weeks")
	assertAge(t, "Jun15 → Sep15 = 3mo", FormatAge("2025-06-15", "2025-09-15"), "3 months")
	assertContains(t, "Jun15 → Sep14 still weeks", FormatAge("2025-06-15", "2025-09-14"), "weeks")
	assertAge(t, "Jun15 → Dec15 = 6mo", FormatAge("2025-06-15", "2025-12-15"), "6 months")
}

// ================================================================
// formatAge — month boundaries: February non-leap
// ================================================================
func TestFormatAge_MonthBoundaryFebNonLeap(t *testing.T) {
	assertAge(t, "Jan31 → Feb28 non-leap", FormatAge("2025-01-31", "2025-02-28"), "4 weeks")
	assertAge(t, "Jan31 → Apr30 = 3mo (clamp)", FormatAge("2025-01-31", "2025-04-30"), "3 months")
	assertContains(t, "Jan31 → Apr29 still weeks", FormatAge("2025-01-31", "2025-04-29"), "weeks")
	assertAge(t, "Feb1 → May1 = 3mo", FormatAge("2025-02-01", "2025-05-01"), "3 months")
	assertContains(t, "Feb1 → Apr30 still weeks", FormatAge("2025-02-01", "2025-04-30"), "weeks")
}

// ================================================================
// formatAge — month boundaries: February leap year
// ================================================================
func TestFormatAge_MonthBoundaryFebLeap(t *testing.T) {
	assertAge(t, "Jan31 → Feb29 leap", FormatAge("2024-01-31", "2024-02-29"), "4 weeks, 1 day")
	assertAge(t, "Jan31 → Feb28 leap", FormatAge("2024-01-31", "2024-02-28"), "4 weeks")
	assertAge(t, "Jan31 → Apr30 leap = 3mo", FormatAge("2024-01-31", "2024-04-30"), "3 months")
	assertContains(t, "Jan30 → Feb29 leap still weeks", FormatAge("2024-01-30", "2024-02-29"), "weeks")
	assertContains(t, "Jan30 → Feb28 leap still weeks", FormatAge("2024-01-30", "2024-02-28"), "weeks")
}

// ================================================================
// formatAge — month boundaries: 30-day months
// ================================================================
func TestFormatAge_MonthBoundary30Day(t *testing.T) {
	assertAge(t, "Mar31 → Jun30 = 3mo (clamped)", FormatAge("2025-03-31", "2025-06-30"), "3 months")
	assertContains(t, "Mar31 → Jun29 still weeks", FormatAge("2025-03-31", "2025-06-29"), "weeks")
	assertAge(t, "Aug31 → Nov30 = 3mo", FormatAge("2025-08-31", "2025-11-30"), "3 months")
	assertContains(t, "Aug31 → Nov29 still weeks", FormatAge("2025-08-31", "2025-11-29"), "weeks")
}

// ================================================================
// formatAge — month boundaries: leap year baby (born Feb 29)
// ================================================================
func TestFormatAge_LeapYearBaby(t *testing.T) {
	assertAge(t, "Feb29 → May29 = 3mo", FormatAge("2024-02-29", "2024-05-29"), "3 months")
	assertContains(t, "Feb29 → May28 still weeks", FormatAge("2024-02-29", "2024-05-28"), "weeks")
	assertAge(t, "Feb29 2024 → Feb28 2025 = 12mo", FormatAge("2024-02-29", "2025-02-28"), "12 months")
	assertAge(t, "Feb29 2024 → Mar1 2025 = 12mo", FormatAge("2024-02-29", "2025-03-01"), "12 months")
}

// ================================================================
// formatAge — months tier (3–23)
// ================================================================
func TestFormatAge_MonthsTier(t *testing.T) {
	tests := []struct {
		name string
		dob  string
		asOf string
		want string
	}{
		{"3 months at transition", "2025-01-15", "2025-04-15", "3 months"},
		{"6 months", "2025-01-15", "2025-07-15", "6 months"},
		{"12 months (not 1 year)", "2024-06-15", "2025-06-15", "12 months"},
		{"23 months at upper", "2024-01-15", "2025-12-15", "23 months"},
		{"one day before boundary", "2025-01-15", "2025-07-14", "5 months"},
		{"crossing year boundary", "2024-11-10", "2025-04-10", "5 months"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			assertAge(t, tc.name, FormatAge(tc.dob, tc.asOf), tc.want)
		})
	}
}

// ================================================================
// formatAge — years+months tier (24–35 months)
// ================================================================
func TestFormatAge_YearsMonthsTier(t *testing.T) {
	tests := []struct {
		name string
		dob  string
		asOf string
		want string
	}{
		{"2 years at 24mo", "2023-06-15", "2025-06-15", "2 years"},
		{"2 years 1 month", "2023-06-15", "2025-07-15", "2 years, 1 month"},
		{"2 years 6 months", "2023-06-15", "2025-12-15", "2 years, 6 months"},
		{"2 years 11 months", "2023-06-15", "2026-05-15", "2 years, 11 months"},
		{"one day before 24mo", "2023-06-15", "2025-06-14", "23 months"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			assertAge(t, tc.name, FormatAge(tc.dob, tc.asOf), tc.want)
		})
	}
}

// ================================================================
// formatAge — half-year tier (3–6 years)
// ================================================================
func TestFormatAge_HalfYearTier(t *testing.T) {
	tests := []struct {
		name string
		dob  string
		asOf string
		want string
	}{
		{"3 years exactly", "2022-06-15", "2025-06-15", "3 years"},
		{"3 years 5 months", "2022-06-15", "2025-11-15", "3 years"},
		{"3½ years at 3y6m", "2022-06-15", "2025-12-15", "3\u00BD years"},
		{"3½ years at 3y11m", "2022-06-15", "2026-05-15", "3\u00BD years"},
		{"4 years exactly", "2021-06-15", "2025-06-15", "4 years"},
		{"4½ years", "2021-06-15", "2025-12-15", "4\u00BD years"},
		{"5 years", "2020-06-15", "2025-06-15", "5 years"},
		{"5½ years at 5y8m", "2020-06-15", "2026-02-15", "5\u00BD years"},
		{"6 years", "2019-06-15", "2025-06-15", "6 years"},
		{"6½ years", "2019-06-15", "2025-12-15", "6\u00BD years"},
		{"6½ years at 6y11m", "2019-06-15", "2026-05-15", "6\u00BD years"},
		{"one day before 3rd bday", "2022-06-15", "2025-06-14", "2 years, 11 months"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			assertAge(t, tc.name, FormatAge(tc.dob, tc.asOf), tc.want)
		})
	}
}

// ================================================================
// formatAge — integer tier (7+ years)
// ================================================================
func TestFormatAge_IntegerTier(t *testing.T) {
	assertAge(t, "7 years exactly", FormatAge("2018-06-15", "2025-06-15"), "7 years")
	assertAge(t, "7 years 6 months (no ½)", FormatAge("2018-03-20", "2025-06-15"), "7 years")
	assertAge(t, "45 years", FormatAge("1980-01-01", "2025-06-15"), "45 years")
}

// ================================================================
// formatAge — cross-year transitions with Feb
// ================================================================
func TestFormatAge_CrossYearFeb(t *testing.T) {
	assertAge(t, "Dec31 → Mar31 = 3mo", FormatAge("2024-12-31", "2025-03-31"), "3 months")
	assertContains(t, "Dec31 → Mar30 still weeks", FormatAge("2024-12-31", "2025-03-30"), "weeks")
	assertAge(t, "Nov30 → Feb28 = 3mo", FormatAge("2024-11-30", "2025-02-28"), "3 months")
	assertContains(t, "Nov30 → Feb27 still weeks", FormatAge("2024-11-30", "2025-02-27"), "weeks")
}

// ================================================================
// formatAge — born-on-31st progression
// ================================================================
func TestFormatAge_BornOn31st(t *testing.T) {
	tests := []struct {
		name string
		dob  string
		asOf string
		want string
	}{
		{"Jan31 → Apr30 = 3mo", "2025-01-31", "2025-04-30", "3 months"},
		{"Jan31 → May31 = 4mo", "2025-01-31", "2025-05-31", "4 months"},
		{"Jan31 → Jun30 = 5mo (clamped)", "2025-01-31", "2025-06-30", "5 months"},
		{"Jan31 → Jul1 = 5mo", "2025-01-31", "2025-07-01", "5 months"},
		{"Jan31 → Jul31 = 6mo", "2025-01-31", "2025-07-31", "6 months"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			assertAge(t, tc.name, FormatAge(tc.dob, tc.asOf), tc.want)
		})
	}
}

// ================================================================
// formatAge — default asOf (uses current date)
// ================================================================
func TestFormatAge_DefaultAsOf(t *testing.T) {
	orig := timeNow
	defer func() { timeNow = orig }()
	timeNow = func() time.Time {
		return time.Date(2025, 6, 15, 0, 0, 0, 0, time.UTC)
	}
	assertAge(t, "5 years from today", FormatAge("2020-01-01"), "5 years")
	assertAge(t, "5 days from today", FormatAge("2025-06-10"), "5 days")
}

// ================================================================
// formatStage
// ================================================================
func TestFormatStage_NullEdgeCases(t *testing.T) {
	assertNil(t, "empty string", FormatStage("", "2025-06-15"))
	assertNil(t, "future dob", FormatStage("2025-07-01", "2025-06-15"))
}

func TestFormatStage_Newborn(t *testing.T) {
	assertAge(t, "born today", FormatStage("2025-06-15", "2025-06-15"), "Newborn")
	assertAge(t, "1 day old", FormatStage("2025-06-14", "2025-06-15"), "Newborn")
	assertAge(t, "3 weeks old", FormatStage("2025-05-25", "2025-06-15"), "Newborn")
	assertAge(t, "1 month old", FormatStage("2025-05-15", "2025-06-15"), "Newborn")
	assertAge(t, "1 month 29 days", FormatStage("2025-04-16", "2025-06-15"), "Newborn")
	assertAge(t, "exactly 2 months → Infant", FormatStage("2025-04-15", "2025-06-15"), "Infant")
}

func TestFormatStage_Infant(t *testing.T) {
	assertAge(t, "2 months", FormatStage("2025-04-15", "2025-06-15"), "Infant")
	assertAge(t, "6 months", FormatStage("2024-12-15", "2025-06-15"), "Infant")
	assertAge(t, "11 months", FormatStage("2024-07-15", "2025-06-15"), "Infant")
	assertAge(t, "exactly 12mo → Toddler", FormatStage("2024-06-15", "2025-06-15"), "Toddler")
}

func TestFormatStage_Toddler(t *testing.T) {
	assertAge(t, "12 months", FormatStage("2024-06-15", "2025-06-15"), "Toddler")
	assertAge(t, "18 months", FormatStage("2024-01-15", "2025-07-15"), "Toddler")
	assertAge(t, "24 months", FormatStage("2023-06-15", "2025-06-15"), "Toddler")
	assertAge(t, "35 months", FormatStage("2023-06-15", "2026-05-15"), "Toddler")
	assertAge(t, "exactly 36mo → Child", FormatStage("2022-06-15", "2025-06-15"), "Child")
}

func TestFormatStage_Child(t *testing.T) {
	assertAge(t, "3 years", FormatStage("2022-06-15", "2025-06-15"), "Child")
	assertAge(t, "4 years", FormatStage("2021-06-15", "2025-06-15"), "Child")
	assertAge(t, "6 years", FormatStage("2019-06-15", "2025-06-15"), "Child")
	assertAge(t, "9 years", FormatStage("2016-06-15", "2025-06-15"), "Child")
	assertAge(t, "12y 11mo", FormatStage("2013-06-15", "2026-05-15"), "Child")
	assertAge(t, "exactly 13y → Teenager", FormatStage("2012-06-15", "2025-06-15"), "Teenager")
}

func TestFormatStage_Teenager(t *testing.T) {
	assertAge(t, "13 years", FormatStage("2012-06-15", "2025-06-15"), "Teenager")
	assertAge(t, "15 years", FormatStage("2010-06-15", "2025-06-15"), "Teenager")
	assertAge(t, "17y 11mo", FormatStage("2008-06-15", "2026-05-15"), "Teenager")
	assertAge(t, "exactly 18y → Adult", FormatStage("2007-06-15", "2025-06-15"), "Adult")
}

func TestFormatStage_Adult(t *testing.T) {
	assertAge(t, "18 years", FormatStage("2007-06-15", "2025-06-15"), "Adult")
	assertAge(t, "25 years", FormatStage("2000-06-15", "2025-06-15"), "Adult")
	assertAge(t, "45 years", FormatStage("1980-01-01", "2025-06-15"), "Adult")
}

func TestFormatStage_DefaultAsOf(t *testing.T) {
	orig := timeNow
	defer func() { timeNow = orig }()
	timeNow = func() time.Time {
		return time.Date(2025, 6, 15, 0, 0, 0, 0, time.UTC)
	}
	assertAge(t, "Newborn", FormatStage("2025-06-15"), "Newborn")
	assertAge(t, "Child", FormatStage("2020-01-01"), "Child")
	assertAge(t, "Adult", FormatStage("1980-01-01"), "Adult")
}

// ================================================================
// ParentTime class with English locale
// ================================================================
func TestParentTime_English(t *testing.T) {
	pt := NewParentTime(EN)
	assertAge(t, "Newborn", pt.FormatAge("2025-06-15", "2025-06-15"), "Newborn")
	assertAge(t, "3 days", pt.FormatAge("2025-06-12", "2025-06-15"), "3 days")
	assertAge(t, "1 week 1 day", pt.FormatAge("2025-06-07", "2025-06-15"), "1 week, 1 day")
	assertAge(t, "6 months", pt.FormatAge("2025-01-15", "2025-07-15"), "6 months")
	assertAge(t, "2y 1mo", pt.FormatAge("2023-06-15", "2025-07-15"), "2 years, 1 month")
	assertAge(t, "3½ years", pt.FormatAge("2022-06-15", "2025-12-15"), "3\u00BD years")
	assertAge(t, "7 years", pt.FormatAge("2018-06-15", "2025-06-15"), "7 years")

	assertAge(t, "stage Newborn", pt.FormatStage("2025-06-15", "2025-06-15"), "Newborn")
	assertAge(t, "stage Infant", pt.FormatStage("2025-01-15", "2025-06-15"), "Infant")
	assertAge(t, "stage Toddler", pt.FormatStage("2024-06-15", "2025-06-15"), "Toddler")
	assertAge(t, "stage Child", pt.FormatStage("2022-06-15", "2025-06-15"), "Child")
	assertAge(t, "stage Teenager", pt.FormatStage("2012-06-15", "2025-06-15"), "Teenager")
	assertAge(t, "stage Adult", pt.FormatStage("2007-06-15", "2025-06-15"), "Adult")

	assertNil(t, "null age", pt.FormatAge(""))
	assertNil(t, "null stage", pt.FormatStage(""))
}

// ================================================================
// ParentTime with Spanish-like locale
// ================================================================
func TestParentTime_Spanish(t *testing.T) {
	es := AgeLocale{
		Code: "es",
		Plural: func(n int) PluralCategory {
			if n == 1 {
				return One
			}
			return Other
		},
		Units: struct{ Day, Week, Month, Year UnitForms }{
			Day:   PluralUnit(map[PluralCategory]string{One: "{n} día", Other: "{n} días"}),
			Week:  PluralUnit(map[PluralCategory]string{One: "{n} semana", Other: "{n} semanas"}),
			Month: PluralUnit(map[PluralCategory]string{One: "{n} mes", Other: "{n} meses"}),
			Year:  PluralUnit(map[PluralCategory]string{One: "{n} año", Other: "{n} años"}),
		},
		Half:      "{n} y medio",
		Delimiter: ", ",
		JustBorn:  "Recién nacido",
		Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult StageLabel }{
			Newborn:  G("Recién nacido", "Recién nacida"),
			Infant:   S("Bebé"),
			Toddler:  G("Niño pequeño", "Niña pequeña"),
			Child:    G("Niño", "Niña"),
			Teenager: S("Adolescente"),
			Adult:    G("Adulto", "Adulta"),
		},
	}

	pt := NewParentTime(es)

	assertAge(t, "justBorn", pt.FormatAge("2025-06-15", "2025-06-15"), "Recién nacido")
	assertAge(t, "singular day", pt.FormatAge("2025-06-14", "2025-06-15"), "1 día")
	assertAge(t, "plural days", pt.FormatAge("2025-06-12", "2025-06-15"), "3 días")
	assertAge(t, "singular week", pt.FormatAge("2025-06-08", "2025-06-15"), "1 semana")
	assertAge(t, "weeks+days", pt.FormatAge("2025-06-07", "2025-06-15"), "1 semana, 1 día")
	assertAge(t, "plural weeks+days", pt.FormatAge("2025-05-26", "2025-06-15"), "2 semanas, 6 días")
	assertAge(t, "months", pt.FormatAge("2025-01-15", "2025-07-15"), "6 meses")
	assertAge(t, "singular month compound", pt.FormatAge("2023-06-15", "2025-07-15"), "2 años, 1 mes")
	assertAge(t, "years+months", pt.FormatAge("2023-06-15", "2025-12-15"), "2 años, 6 meses")
	assertAge(t, "half marker", pt.FormatAge("2022-06-15", "2025-12-15"), "3 y medio años")
	assertAge(t, "integer years", pt.FormatAge("2022-06-15", "2025-06-15"), "3 años")
	assertAge(t, "7+ years", pt.FormatAge("2018-06-15", "2025-06-15"), "7 años")

	assertAge(t, "stage newborn", pt.FormatStage("2025-06-15", "2025-06-15"), "Recién nacido")
	assertAge(t, "stage infant", pt.FormatStage("2025-01-15", "2025-06-15"), "Bebé")
	assertAge(t, "stage toddler", pt.FormatStage("2024-06-15", "2025-06-15"), "Niño pequeño")
	assertAge(t, "stage child", pt.FormatStage("2022-06-15", "2025-06-15"), "Niño")
	assertAge(t, "stage teenager", pt.FormatStage("2012-06-15", "2025-06-15"), "Adolescente")
	assertAge(t, "stage adult", pt.FormatStage("2007-06-15", "2025-06-15"), "Adulto")

	assertNil(t, "null", pt.FormatAge(""))
	assertNil(t, "null stage", pt.FormatStage(""))
}

// ================================================================
// Compactness: short
// ================================================================
func TestParentTime_CompactShort(t *testing.T) {
	pt := NewParentTime(EN, Short)

	assertAge(t, "days", pt.FormatAge("2025-06-12", "2025-06-15"), "3 d")
	assertAge(t, "weeks", pt.FormatAge("2025-06-08", "2025-06-15"), "1 wk")
	assertAge(t, "weeks+days", pt.FormatAge("2025-06-07", "2025-06-15"), "1 wk, 1 d")
	assertAge(t, "months", pt.FormatAge("2025-01-15", "2025-07-15"), "6 mo")
	assertAge(t, "years+months", pt.FormatAge("2023-06-15", "2025-07-15"), "2 yr, 1 mo")
	assertAge(t, "half years", pt.FormatAge("2022-06-15", "2025-12-15"), "3\u00BD yr")
	assertAge(t, "integer years", pt.FormatAge("2018-06-15", "2025-06-15"), "7 yr")
	assertAge(t, "justBorn unchanged", pt.FormatAge("2025-06-15", "2025-06-15"), "Newborn")
	assertAge(t, "stages unchanged", pt.FormatStage("2025-01-15", "2025-06-15"), "Infant")
}

// ================================================================
// Compactness: compact
// ================================================================
func TestParentTime_CompactCompact(t *testing.T) {
	pt := NewParentTime(EN, Compact)

	assertAge(t, "days", pt.FormatAge("2025-06-12", "2025-06-15"), "3d")
	assertAge(t, "weeks", pt.FormatAge("2025-06-08", "2025-06-15"), "1w")
	assertAge(t, "weeks+days no delimiter", pt.FormatAge("2025-06-07", "2025-06-15"), "1w1d")
	assertAge(t, "months", pt.FormatAge("2025-01-15", "2025-07-15"), "6m")
	assertAge(t, "years+months no delimiter", pt.FormatAge("2023-06-15", "2025-07-15"), "2y1m")
	assertAge(t, "half years", pt.FormatAge("2022-06-15", "2025-12-15"), "3\u00BDy")
	assertAge(t, "integer years", pt.FormatAge("2018-06-15", "2025-06-15"), "7y")
	assertAge(t, "justBorn unchanged", pt.FormatAge("2025-06-15", "2025-06-15"), "Newborn")
}

// ================================================================
// formatStage — gender support
// ================================================================
func TestFormatStage_GenderNeutralLocale(t *testing.T) {
	pt := NewParentTime(EN)
	// English has all S() labels — gender param should have no effect
	assertAge(t, "en no gender", pt.FormatStage("2025-06-15", "2025-06-15"), "Newborn")
	assertAge(t, "en masculine", pt.FormatStage("2025-06-15", "2025-06-15", "m"), "Newborn")
	assertAge(t, "en feminine", pt.FormatStage("2025-06-15", "2025-06-15", "f"), "Newborn")
	assertAge(t, "en adult no gender", pt.FormatStage("2007-06-15", "2025-06-15"), "Adult")
	assertAge(t, "en adult m", pt.FormatStage("2007-06-15", "2025-06-15", "m"), "Adult")
	assertAge(t, "en adult f", pt.FormatStage("2007-06-15", "2025-06-15", "f"), "Adult")
}

func TestFormatStage_GenderedLocaleSpanish(t *testing.T) {
	pt := NewParentTime(ES)

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
	pt := NewParentTime(AR)

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
	pt := NewParentTime(ES)

	// Nil for invalid input
	assertNil(t, "empty dob", pt.FormatStage(""))
	assertNil(t, "empty dob with gender", pt.FormatStage("", "", "f"))
	assertNil(t, "future dob with gender", pt.FormatStage("2025-07-01", "2025-06-15", "f"))
}

func TestFormatStage_PackageLevelGender(t *testing.T) {
	// Package-level FormatStage with gender — EN is all neutral
	assertAge(t, "pkg FormatStage no gender", FormatStage("2007-06-15", "2025-06-15"), "Adult")
	assertAge(t, "pkg FormatStage m", FormatStage("2007-06-15", "2025-06-15", "m"), "Adult")
	assertAge(t, "pkg FormatStage f", FormatStage("2007-06-15", "2025-06-15", "f"), "Adult")
}

func TestResolveStage_Direct(t *testing.T) {
	// Test the ResolveStage function directly
	neutral := S("Newborn")
	if got := ResolveStage(neutral, ""); got != "Newborn" {
		t.Errorf("neutral no gender: got %q, want %q", got, "Newborn")
	}
	if got := ResolveStage(neutral, "m"); got != "Newborn" {
		t.Errorf("neutral m: got %q, want %q", got, "Newborn")
	}
	if got := ResolveStage(neutral, "f"); got != "Newborn" {
		t.Errorf("neutral f: got %q, want %q", got, "Newborn")
	}

	gendered := G("Adulto", "Adulta")
	if got := ResolveStage(gendered, ""); got != "Adulto" {
		t.Errorf("gendered no gender: got %q, want %q", got, "Adulto")
	}
	if got := ResolveStage(gendered, "m"); got != "Adulto" {
		t.Errorf("gendered m: got %q, want %q", got, "Adulto")
	}
	if got := ResolveStage(gendered, "f"); got != "Adulta" {
		t.Errorf("gendered f: got %q, want %q", got, "Adulta")
	}
}
