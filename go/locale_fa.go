package parenttime

// FA is the Persian (Farsi) locale.
var FA = AgeLocale{
	Code: "fa",
	Plural: func(n int) PluralCategory {
		if n == 0 || n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} روز", Other: "{n} روز"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} هفته", Other: "{n} هفته"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} ماه", Other: "{n} ماه"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} سال", Other: "{n} سال"}),
	},
	Half:      "{0} و نیم",
	Delimiter: " و ",
	JustBorn:  "نوزاد",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult StageLabel }{
		Newborn:  S("نوزاد"),
		Infant:   S("شیرخوار"),
		Toddler:  S("نوپا"),
		Child:    S("کودک"),
		Teenager: S("نوجوان"),
		Adult:    S("بزرگسال"),
	},
}
