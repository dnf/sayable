package parenttime

// KO is the Korean locale.
var KO = AgeLocale{
	Code: "ko",
	Plural: func(_ int) PluralCategory {
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   SimpleUnit("{n}일"),
		Week:  SimpleUnit("{n}주"),
		Month: SimpleUnit("{n}개월"),
		Year:  SimpleUnit("{n}살"),
	},
	Half:      "{0} 반",
	Delimiter: " ",
	JustBorn:  "신생아",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "신생아",
		Infant:   "영아",
		Toddler:  "유아",
		Child:    "아동",
		Teenager: "청소년",
		Adult:    "성인",
	},
}
