package parenttime

// DE is the German locale.
var DE = AgeLocale{
	Code: "de",
	Plural: func(n int) PluralCategory {
		if n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} Tag", Other: "{n} Tage"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} Woche", Other: "{n} Wochen"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} Monat", Other: "{n} Monate"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} Jahr", Other: "{n} Jahre"}),
	},
	Half:      "{n}\u00BD",
	Delimiter: ", ",
	JustBorn:  "Neugeboren",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Neugeborenes",
		Infant:   "Säugling",
		Toddler:  "Kleinkind",
		Child:    "Kind",
		Teenager: "Teenager",
		Adult:    "Erwachsener",
	},
}
