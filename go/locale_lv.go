package parenttime

// LV is the Latvian locale.
var LV = AgeLocale{
	Code: "lv",
	Plural: func(n int) PluralCategory {
		if n == 0 {
			return Zero
		}
		if n%10 == 1 && n%100 != 11 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{Zero: "{n} dienu", One: "{n} diena", Other: "{n} dienas"}),
		Week:  PluralUnit(map[PluralCategory]string{Zero: "{n} nedēļu", One: "{n} nedēļa", Other: "{n} nedēļas"}),
		Month: PluralUnit(map[PluralCategory]string{Zero: "{n} mēnešu", One: "{n} mēnesis", Other: "{n} mēneši"}),
		Year:  PluralUnit(map[PluralCategory]string{Zero: "{n} gadu", One: "{n} gads", Other: "{n} gadi"}),
	},
	Half:      "{n}\u00BD",
	Delimiter: ", ",
	JustBorn:  "Jaundzimušais",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Jaundzimušais",
		Infant:   "Zīdainis",
		Toddler:  "Mazulis",
		Child:    "Bērns",
		Teenager: "Pusaudzis",
		Adult:    "Pieaugušais",
	},
}
