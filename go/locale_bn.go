package parenttime

// BN is the Bengali locale.
var BN = AgeLocale{
	Code: "bn",
	Plural: func(n int) PluralCategory {
		if n == 0 || n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} দিন", Other: "{n} দিন"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} সপ্তাহ", Other: "{n} সপ্তাহ"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} মাস", Other: "{n} মাস"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} বছর", Other: "{n} বছর"}),
	},
	Half:      "সাড়ে {n}",
	Delimiter: ", ",
	JustBorn:  "নবজাতক",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "নবজাতক",
		Infant:   "শিশু",
		Toddler:  "ছোট শিশু",
		Child:    "শিশু",
		Teenager: "কিশোর",
		Adult:    "প্রাপ্তবয়স্ক",
	},
}
