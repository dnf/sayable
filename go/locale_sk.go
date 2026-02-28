package parenttime

// SK is the Slovak locale.
var SK = AgeLocale{
	Code: "sk",
	Plural: func(n int) PluralCategory {
		if n == 1 {
			return One
		}
		if n >= 2 && n <= 4 {
			return Few
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} deň", Few: "{n} dni", Other: "{n} dní"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} týždeň", Few: "{n} týždne", Other: "{n} týždňov"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} mesiac", Few: "{n} mesiace", Other: "{n} mesiacov"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} rok", Few: "{n} roky", Other: "{n} rokov"}),
	},
	Half:      "{n}\u00BD",
	Delimiter: ", ",
	JustBorn:  "Novorodenec",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Novorodenec",
		Infant:   "Dojča",
		Toddler:  "Batoľa",
		Child:    "Dieťa",
		Teenager: "Tínedžer",
		Adult:    "Dospelý",
	},
}
