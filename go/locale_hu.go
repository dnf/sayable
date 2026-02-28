package parenttime

// HU is the Hungarian locale.
var HU = AgeLocale{
	Code: "hu",
	Plural: func(n int) PluralCategory {
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   SimpleUnit("{n} nap"),
		Week:  SimpleUnit("{n} hét"),
		Month: SimpleUnit("{n} hónap"),
		Year:  SimpleUnit("{n} év"),
	},
	Half:      "{n} és fél",
	Delimiter: ", ",
	JustBorn:  "Újszülött",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Újszülött",
		Infant:   "Csecsemő",
		Toddler:  "Kisgyermek",
		Child:    "Gyermek",
		Teenager: "Tinédzser",
		Adult:    "Felnőtt",
	},
}
