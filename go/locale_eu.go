package parenttime

// EU is the Basque locale.
var EU = AgeLocale{
	Code: "eu",
	Plural: func(n int) PluralCategory {
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   SimpleUnit("{n} egun"),
		Week:  SimpleUnit("{n} aste"),
		Month: SimpleUnit("{n} hilabete"),
		Year:  SimpleUnit("{n} urte"),
	},
	Half:      "{0} eta erdi",
	Delimiter: ", ",
	JustBorn:  "Jaioberria",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Jaioberria",
		Infant:   "Haurra",
		Toddler:  "Haur txikia",
		Child:    "Umea",
		Teenager: "Nerabea",
		Adult:    "Heldua",
	},
}
