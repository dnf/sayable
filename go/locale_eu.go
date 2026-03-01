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
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult StageLabel }{
		Newborn:  S("Jaioberria"),
		Infant:   S("Haurra"),
		Toddler:  S("Haur txikia"),
		Child:    S("Umea"),
		Teenager: S("Nerabea"),
		Adult:    S("Heldua"),
	},
}
