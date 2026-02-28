package parenttime

// ZH is the Chinese locale.
var ZH = AgeLocale{
	Code: "zh",
	Plural: func(_ int) PluralCategory {
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   SimpleUnit("{n}天"),
		Week:  SimpleUnit("{n}周"),
		Month: SimpleUnit("{n}个月"),
		Year:  SimpleUnit("{n}岁"),
	},
	Half:      "{0}半",
	Delimiter: "",
	JustBorn:  "新生儿",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "新生儿",
		Infant:   "婴儿",
		Toddler:  "幼儿",
		Child:    "儿童",
		Teenager: "青少年",
		Adult:    "成人",
	},
}
