package parenttime

// PL is the Polish locale.
var PL = AgeLocale{
	Code: "pl",
	Plural: func(n int) PluralCategory {
		if n == 1 {
			return One
		}
		mod10 := n % 10
		mod100 := n % 100
		if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) {
			return Few
		}
		return Many
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} dzień", Few: "{n} dni", Many: "{n} dni", Other: "{n} dni"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} tydzień", Few: "{n} tygodnie", Many: "{n} tygodni", Other: "{n} tygodni"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} miesiąc", Few: "{n} miesiące", Many: "{n} miesięcy", Other: "{n} miesięcy"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} rok", Few: "{n} lata", Many: "{n} lat", Other: "{n} lat"}),
	},
	Half:      "{n} i pół",
	Delimiter: ", ",
	JustBorn:  "Noworodek",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult StageLabel }{
		Newborn:  S("Noworodek"),
		Infant:   S("Niemowlę"),
		Toddler:  S("Maluch"),
		Child:    S("Dziecko"),
		Teenager: G("Nastolatek", "Nastolatka"),
		Adult:    G("Dorosły", "Dorosła"),
	},
}
