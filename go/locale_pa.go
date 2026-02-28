package parenttime

// PA is the Punjabi locale.
var PA = AgeLocale{
	Code: "pa",
	Plural: func(n int) PluralCategory {
		if n == 0 || n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} ਦਿਨ", Other: "{n} ਦਿਨ"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} ਹਫ਼ਤਾ", Other: "{n} ਹਫ਼ਤੇ"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} ਮਹੀਨਾ", Other: "{n} ਮਹੀਨੇ"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} ਸਾਲ", Other: "{n} ਸਾਲ"}),
	},
	Half:      "ਸਾਢੇ {n}",
	Delimiter: ", ",
	JustBorn:  "ਨਵਜੰਮਿਆ",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "ਨਵਜੰਮਿਆ",
		Infant:   "ਸ਼ਿਸ਼ੂ",
		Toddler:  "ਛੋਟਾ ਬੱਚਾ",
		Child:    "ਬੱਚਾ",
		Teenager: "ਕਿਸ਼ੋਰ",
		Adult:    "ਬਾਲਗ",
	},
}
