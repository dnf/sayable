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
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult StageLabel }{
		Newborn:  S("新生児"),
		Infant:   S("乳児"),
		Toddler:  S("幼児"),
		Child:    S("児童"),
		Teenager: S("青少年"),
		Adult:    S("成人"),
	},
}
