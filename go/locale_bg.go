package parenttime

// BG is the Bulgarian locale.
var BG = AgeLocale{
	Code: "bg",
	Plural: func(n int) PluralCategory {
		if n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} ден", Other: "{n} дни"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} седмица", Other: "{n} седмици"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} месец", Other: "{n} месеца"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} година", Other: "{n} години"}),
	},
	Half:      "{0} и половина",
	Delimiter: ", ",
	JustBorn:  "Новородено",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Новородено",
		Infant:   "Бебе",
		Toddler:  "Малко дете",
		Child:    "Дете",
		Teenager: "Тийнейджър",
		Adult:    "Възрастен",
	},
}
