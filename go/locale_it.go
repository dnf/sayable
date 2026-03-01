package parenttime

// IT is the Italian locale.
var IT = AgeLocale{
	Code: "it",
	Plural: func(n int) PluralCategory {
		if n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} giorno", Other: "{n} giorni"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} settimana", Other: "{n} settimane"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} mese", Other: "{n} mesi"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} anno", Other: "{n} anni"}),
	},
	Half:      "{0} e mezzo",
	Delimiter: ", ",
	JustBorn:  "Neonato",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult StageLabel }{
		Newborn:  G("Neonato", "Neonata"),
		Infant:   S("Lattante"),
		Toddler:  G("Bimbo", "Bimba"),
		Child:    G("Bambino", "Bambina"),
		Teenager: S("Adolescente"),
		Adult:    G("Adulto", "Adulta"),
	},
}
