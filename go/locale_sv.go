package parenttime

// SV is the Swedish locale.
var SV = AgeLocale{
	Code: "sv",
	Plural: func(n int) PluralCategory {
		if n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} dag", Other: "{n} dagar"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} vecka", Other: "{n} veckor"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} månad", Other: "{n} månader"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} år", Other: "{n} år"}),
	},
	Half:      "{n}\u00BD",
	Delimiter: ", ",
	JustBorn:  "Nyfödd",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult StageLabel }{
		Newborn:  S("Nyfödd"),
		Infant:   S("Spädbarn"),
		Toddler:  S("Litet barn"),
		Child:    S("Barn"),
		Teenager: S("Tonåring"),
		Adult:    S("Vuxen"),
	},
}
