package parenttime

// SQ is the Albanian locale.
var SQ = AgeLocale{
	Code: "sq",
	Plural: func(n int) PluralCategory {
		if n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} ditë", Other: "{n} ditë"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} javë", Other: "{n} javë"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} muaj", Other: "{n} muaj"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} vit", Other: "{n} vjet"}),
	},
	Half:      "{0} e gjysmë",
	Delimiter: ", ",
	JustBorn:  "Sapolindur",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Sapolindur",
		Infant:   "Foshnjë",
		Toddler:  "Fëmijë i vogël",
		Child:    "Fëmijë",
		Teenager: "Adoleshent",
		Adult:    "I rritur",
	},
}
