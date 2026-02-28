package parenttime

// LT is the Lithuanian locale.
var LT = AgeLocale{
	Code: "lt",
	Plural: func(n int) PluralCategory {
		mod10 := n % 10
		mod100 := n % 100
		if mod10 == 1 && mod100 != 11 {
			return One
		}
		if mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19) {
			return Few
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} diena", Few: "{n} dienos", Other: "{n} dienų"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} savaitė", Few: "{n} savaitės", Other: "{n} savaičių"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} mėnuo", Few: "{n} mėnesiai", Other: "{n} mėnesių"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} metai", Few: "{n} metai", Other: "{n} metų"}),
	},
	Half:      "{n}\u00BD",
	Delimiter: ", ",
	JustBorn:  "Naujagimis",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult string }{
		Newborn:  "Naujagimis",
		Infant:   "Kūdikis",
		Toddler:  "Mažylis",
		Child:    "Vaikas",
		Teenager: "Paauglys",
		Adult:    "Suaugęs",
	},
}
