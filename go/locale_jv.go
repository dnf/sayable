package parenttime

// JV is the Javanese locale.
var JV = AgeLocale{
	Code: "jv",
	Plural: func(_ int) PluralCategory {
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   SimpleUnit("{n} dina"),
		Week:  SimpleUnit("{n} minggu"),
		Month: SimpleUnit("{n} wulan"),
		Year:  SimpleUnit("{n} taun"),
	},
	Half:      "{0} setengah",
	Delimiter: ", ",
	JustBorn:  "Bayi anyar",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Bayi anyar",
		Infant:   "Bayi",
		Toddler:  "Balita",
		Child:    "Bocah",
		Teenager: "Remaja",
		Adult:    "Diwasa",
	},
}
