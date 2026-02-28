package parenttime

// UR is the Urdu locale.
var UR = AgeLocale{
	Code: "ur",
	Plural: func(n int) PluralCategory {
		if n == 0 || n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} دن", Other: "{n} دن"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} ہفتہ", Other: "{n} ہفتے"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} مہینہ", Other: "{n} مہینے"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} سال", Other: "{n} سال"}),
	},
	Half:      "ساڑھے {n}",
	Delimiter: "، ",
	JustBorn:  "نومولود",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "نومولود",
		Infant:   "شیرخوار",
		Toddler:  "چھوٹا بچہ",
		Child:    "بچہ",
		Teenager: "نوجوان",
		Adult:    "بالغ",
	},
}
