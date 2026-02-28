package parenttime

// MR is the Marathi locale.
var MR = AgeLocale{
	Code: "mr",
	Plural: func(n int) PluralCategory {
		if n == 0 || n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} दिवस", Other: "{n} दिवस"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} आठवडा", Other: "{n} आठवडे"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} महिना", Other: "{n} महिने"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} वर्ष", Other: "{n} वर्षे"}),
	},
	Half:      "साडे {n}",
	Delimiter: ", ",
	JustBorn:  "नवजात",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "नवजात",
		Infant:   "अर्भक",
		Toddler:  "बाळ",
		Child:    "मूल",
		Teenager: "किशोर",
		Adult:    "प्रौढ",
	},
}
