package parenttime

// JA is the Japanese locale.
var JA = AgeLocale{
	Code: "ja",
	Plural: func(_ int) PluralCategory {
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   SimpleUnit("{n}日"),
		Week:  SimpleUnit("{n}週"),
		Month: SimpleUnit("{n}ヶ月"),
		Year:  SimpleUnit("{n}歳"),
	},
	Half:      "{0}半",
	Delimiter: "",
	JustBorn:  "新生児",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "新生児",
		Infant:   "乳児",
		Toddler:  "幼児",
		Child:    "児童",
		Teenager: "青少年",
		Adult:    "成人",
	},
}
