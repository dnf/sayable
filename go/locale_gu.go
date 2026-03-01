package parenttime

// GU is the Gujarati locale.
var GU = AgeLocale{
	Code: "gu",
	Plural: func(n int) PluralCategory {
		if n == 0 || n == 1 {
			return One
		}
		return Other
	},
	Units: struct{ Day, Week, Month, Year UnitForms }{
		Day:   PluralUnit(map[PluralCategory]string{One: "{n} દિવસ", Other: "{n} દિવસ"}),
		Week:  PluralUnit(map[PluralCategory]string{One: "{n} અઠવાડિયું", Other: "{n} અઠવાડિયા"}),
		Month: PluralUnit(map[PluralCategory]string{One: "{n} મહિનો", Other: "{n} મહિના"}),
		Year:  PluralUnit(map[PluralCategory]string{One: "{n} વર્ષ", Other: "{n} વર્ષ"}),
	},
	Half:      "સાડે {n}",
	Delimiter: ", ",
	JustBorn:  "નવજાત",
	Stages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult StageLabel }{
		Newborn:  S("નવજાત"),
		Infant:   S("શિશુ"),
		Toddler:  S("નાનું બાળક"),
		Child:    S("બાળક"),
		Teenager: G("કિશોર", "કિશોરી"),
		Adult:    S("પુખ્ત"),
	},
}
