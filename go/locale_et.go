package parenttime

// ET is the Estonian locale.
var ET = AgeLocale{
	Code: "et",
	Plural: func(n int) PluralCategory {
		if n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} päev", Other: "{n} päeva"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} nädal", Other: "{n} nädalat"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} kuu", Other: "{n} kuud"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} aasta", Other: "{n} aastat"}),
	},
	Half:      "{n}\u00BD",
	Delimiter: ", ",
	JustBorn:  "Vastsündinu",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Vastsündinu",
		Infant:   "Imik",
		Toddler:  "Väikelaps",
		Child:    "Laps",
		Teenager: "Teismeline",
		Adult:    "Täiskasvanu",
	},
}
