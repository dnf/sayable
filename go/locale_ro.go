package parenttime

// RO is the Romanian locale.
var RO = AgeLocale{
	Code: "ro",
	Plural: func(n int) PluralCategory {
		if n == 1 {
			return One
		}
		mod100 := n % 100
		if n == 0 || (mod100 >= 1 && mod100 <= 19) {
			return Few
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} zi", Few: "{n} zile", Other: "{n} de zile"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} săptămână", Few: "{n} săptămâni", Other: "{n} de săptămâni"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} lună", Few: "{n} luni", Other: "{n} de luni"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} an", Few: "{n} ani", Other: "{n} de ani"}),
	},
	Half:      "{0} și jumătate",
	Delimiter: ", ",
	JustBorn:  "Nou-născut",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Nou-născut",
		Infant:   "Sugar",
		Toddler:  "Copil mic",
		Child:    "Copil",
		Teenager: "Adolescent",
		Adult:    "Adult",
	},
}
