package parenttime

// TH is the Thai locale.
var TH = AgeLocale{
	Code: "th",
	Plural: func(_ int) PluralCategory {
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   SimpleUnit("{n} วัน"),
		Week:  SimpleUnit("{n} สัปดาห์"),
		Month: SimpleUnit("{n} เดือน"),
		Year:  SimpleUnit("{n} ปี"),
	},
	Half:      "{0}ครึ่ง",
	Delimiter: " ",
	JustBorn:  "แรกเกิด",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "แรกเกิด",
		Infant:   "ทารก",
		Toddler:  "เด็กวัยเตาะแตะ",
		Child:    "เด็ก",
		Teenager: "วัยรุ่น",
		Adult:    "ผู้ใหญ่",
	},
}
