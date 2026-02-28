package parenttime

// ES is the Spanish locale.
var ES = AgeLocale{
	Code: "es",
	Plural: func(n int) PluralCategory {
		if n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} día", Other: "{n} días"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} semana", Other: "{n} semanas"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} mes", Other: "{n} meses"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} año", Other: "{n} años"}),
	},
	Half:      "{n} y medio",
	Delimiter: ", ",
	JustBorn:  "Recién nacido",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Recién nacido",
		Infant:   "Bebé",
		Toddler:  "Niño pequeño",
		Child:    "Niño",
		Teenager: "Adolescente",
		Adult:    "Adulto",
	},
}
