package parenttime

// LV is the Latvian locale.
var LV = AgeLocale{
	Code: "lv",
	Plural: func(n int) PluralCategory {
		mod10 := n % 10
		mod100 := n % 100
		if mod10 == 0 || (mod100 >= 11 && mod100 <= 19) {
			return Zero
		}
		if mod10 == 1 && mod100 != 11 {
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
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult StageLabel }{
		Newborn:  G("Jaundzimušais", "Jaundzimušā"),
		Infant:   G("Zīdainis", "Zīdaine"),
		Toddler:  G("Mazulis", "Mazule"),
		Child:    S("Bērns"),
		Teenager: G("Pusaudzis", "Pusaudze"),
		Adult:    G("Pieaugušais", "Pieaugusī"),
	},
}
