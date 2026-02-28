package parenttime

// FI is the Finnish locale.
var FI = AgeLocale{
	Code: "fi",
	Plural: func(n int) PluralCategory {
		if n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} päivä", Other: "{n} päivää"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} viikko", Other: "{n} viikkoa"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} kuukausi", Other: "{n} kuukautta"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} vuosi", Other: "{n} vuotta"}),
	},
	Half:      "{n} ja puoli",
	Delimiter: ", ",
	JustBorn:  "Vastasyntynyt",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Vastasyntynyt",
		Infant:   "Vauva",
		Toddler:  "Taapero",
		Child:    "Lapsi",
		Teenager: "Teini",
		Adult:    "Aikuinen",
	},
}
