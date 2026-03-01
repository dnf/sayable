package parenttime

// MS is the Malay locale.
var MS = AgeLocale{
	Code: "ms",
	Plural: func(_ int) PluralCategory {
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   SimpleUnit("{n} hari"),
		Week:  SimpleUnit("{n} minggu"),
		Month: SimpleUnit("{n} bulan"),
		Year:  SimpleUnit("{n} tahun"),
	},
	Half:      "{0} setengah",
	Delimiter: ", ",
	JustBorn:  "Baru lahir",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult StageLabel }{
		Newborn:  S("Baru lahir"),
		Infant:   S("Bayi"),
		Toddler:  S("Kanak-kanak kecil"),
		Child:    S("Kanak-kanak"),
		Teenager: S("Remaja"),
		Adult:    S("Dewasa"),
	},
}
