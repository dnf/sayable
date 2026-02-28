package parenttime

// GA is the Irish locale.
var GA = AgeLocale{
	Code: "ga",
	Plural: func(n int) PluralCategory {
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   SimpleUnit("{n} lá"),
		Week:  SimpleUnit("{n} seachtain"),
		Month: SimpleUnit("{n} mí"),
		Year:  SimpleUnit("{n} bliain"),
	},
	Half:      "{0} go leith",
	Delimiter: ", ",
	JustBorn:  "Nuabheirthe",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Nuabheirthe",
		Infant:   "Naíonán",
		Toddler:  "Lapadán",
		Child:    "Páiste",
		Teenager: "Déagóir",
		Adult:    "Duine fásta",
	},
}
