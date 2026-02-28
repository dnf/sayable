package parenttime

// EN is the English locale.
var EN = AgeLocale{
	Code: "en",
	Plural: func(n int) PluralCategory {
		if n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} day", Other: "{n} days"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} week", Other: "{n} weeks"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} month", Other: "{n} months"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} year", Other: "{n} years"}),
	},
	Half:      "{n}\u00BD",
	Delimiter: ", ",
	JustBorn:  "Newborn",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Newborn",
		Infant:   "Infant",
		Toddler:  "Toddler",
		Child:    "Child",
		Teenager: "Teenager",
		Adult:    "Adult",
	},
	Short: &CompactnessOverride{
		Day:   &UnitForms{Simple: "{n} d"},
		Week:  &UnitForms{Simple: "{n} wk"},
		Month: &UnitForms{Simple: "{n} mo"},
		Year:  &UnitForms{Simple: "{n} yr"},
	},
	Compact: &CompactnessOverride{
		Day:       &UnitForms{Simple: "{n}d"},
		Week:      &UnitForms{Simple: "{n}w"},
		Month:     &UnitForms{Simple: "{n}m"},
		Year:      &UnitForms{Simple: "{n}y"},
		Delimiter: strPtr(""),
	},
}
