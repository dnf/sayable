package parenttime

// UK is the Ukrainian locale.
var UK = AgeLocale{
	Code: "uk",
	Plural: func(n int) PluralCategory {
		mod10 := n % 10
		mod100 := n % 100
		if mod10 == 1 && mod100 != 11 {
			return One
		}
		if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) {
			return Few
		}
		return Many
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} день", Few: "{n} дні", Many: "{n} днів", Other: "{n} днів"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} тиждень", Few: "{n} тижні", Many: "{n} тижнів", Other: "{n} тижнів"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} місяць", Few: "{n} місяці", Many: "{n} місяців", Other: "{n} місяців"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} рік", Few: "{n} роки", Many: "{n} років", Other: "{n} років"}),
	},
	Half:      "{n} з половиною",
	Delimiter: ", ",
	JustBorn:  "Новонароджений",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Новонароджений",
		Infant:   "Немовля",
		Toddler:  "Малюк",
		Child:    "Дитина",
		Teenager: "Підліток",
		Adult:    "Дорослий",
	},
}
