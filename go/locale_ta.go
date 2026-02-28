package parenttime

// TA is the Tamil locale.
var TA = AgeLocale{
	Code: "ta",
	Plural: func(n int) PluralCategory {
		if n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} நாள்", Other: "{n} நாட்கள்"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} வாரம்", Other: "{n} வாரங்கள்"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} மாதம்", Other: "{n} மாதங்கள்"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} வயது", Other: "{n} வயது"}),
	},
	Half:      "{0}ரை",
	Delimiter: ", ",
	JustBorn:  "பிறந்த குழந்தை",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "பிறந்த குழந்தை",
		Infant:   "குழந்தை",
		Toddler:  "சிறு குழந்தை",
		Child:    "சிறுவர்",
		Teenager: "இளம்பருவம்",
		Adult:    "பெரியவர்",
	},
}
