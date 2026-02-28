package parenttime

// VI is the Vietnamese locale.
var VI = AgeLocale{
	Code: "vi",
	Plural: func(_ int) PluralCategory {
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   SimpleUnit("{n} ngày"),
		Week:  SimpleUnit("{n} tuần"),
		Month: SimpleUnit("{n} tháng"),
		Year:  SimpleUnit("{n} tuổi"),
	},
	Half:      "{0} rưỡi",
	Delimiter: ", ",
	JustBorn:  "Sơ sinh",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Sơ sinh",
		Infant:   "Trẻ sơ sinh",
		Toddler:  "Trẻ mới biết đi",
		Child:    "Trẻ em",
		Teenager: "Thiếu niên",
		Adult:    "Người lớn",
	},
}
