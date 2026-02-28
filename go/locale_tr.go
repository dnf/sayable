package parenttime

// TR is the Turkish locale.
var TR = AgeLocale{
	Code: "tr",
	Plural: func(n int) PluralCategory {
		if n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} gün", Other: "{n} gün"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} hafta", Other: "{n} hafta"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} ay", Other: "{n} ay"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} yaş", Other: "{n} yaş"}),
	},
	Half:      "{n} buçuk",
	Delimiter: ", ",
	JustBorn:  "Yeni doğan",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Yeni doğan",
		Infant:   "Bebek",
		Toddler:  "Küçük çocuk",
		Child:    "Çocuk",
		Teenager: "Ergen",
		Adult:    "Yetişkin",
	},
}
