package parenttime

// DA is the Danish locale.
var DA = AgeLocale{
	Code: "da",
	Plural: func(n int) PluralCategory {
		if n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} dag", Other: "{n} dage"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} uge", Other: "{n} uger"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} måned", Other: "{n} måneder"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} år", Other: "{n} år"}),
	},
	Half:      "{n}\u00BD",
	Delimiter: ", ",
	JustBorn:  "Nyfødt",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult StageLabel }{
		Newborn:  S("Nyfødt"),
		Infant:   S("Spædbarn"),
		Toddler:  S("Småbarn"),
		Child:    S("Barn"),
		Teenager: S("Teenager"),
		Adult:    S("Voksen"),
	},
}
