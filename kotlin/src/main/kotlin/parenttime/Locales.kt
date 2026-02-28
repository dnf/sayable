package parenttime

/**
 * All 49 locale definitions for parent-time.
 */
public object Locales {

    // ================================================================
    // AR — Arabic
    // ================================================================
    public val AR: AgeLocale = AgeLocale(
        code = "ar",
        plural = { n ->
            when {
                n == 0 -> PluralCategory.ZERO
                n == 1 -> PluralCategory.ONE
                n == 2 -> PluralCategory.TWO
                n % 100 in 3..10 -> PluralCategory.FEW
                n % 100 in 11..99 -> PluralCategory.MANY
                else -> PluralCategory.OTHER
            }
        },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ZERO to "{n} \u064A\u0648\u0645", PluralCategory.ONE to "\u064A\u0648\u0645", PluralCategory.TWO to "\u064A\u0648\u0645\u0627\u0646", PluralCategory.FEW to "{n} \u0623\u064A\u0627\u0645", PluralCategory.MANY to "{n} \u064A\u0648\u0645\u064B\u0627", PluralCategory.OTHER to "{n} \u064A\u0648\u0645")),
            week = pluralUnit(mapOf(PluralCategory.ZERO to "{n} \u0623\u0633\u0628\u0648\u0639", PluralCategory.ONE to "\u0623\u0633\u0628\u0648\u0639", PluralCategory.TWO to "\u0623\u0633\u0628\u0648\u0639\u0627\u0646", PluralCategory.FEW to "{n} \u0623\u0633\u0627\u0628\u064A\u0639", PluralCategory.MANY to "{n} \u0623\u0633\u0628\u0648\u0639\u064B\u0627", PluralCategory.OTHER to "{n} \u0623\u0633\u0628\u0648\u0639")),
            month = pluralUnit(mapOf(PluralCategory.ZERO to "{n} \u0634\u0647\u0631", PluralCategory.ONE to "\u0634\u0647\u0631", PluralCategory.TWO to "\u0634\u0647\u0631\u0627\u0646", PluralCategory.FEW to "{n} \u0623\u0634\u0647\u0631", PluralCategory.MANY to "{n} \u0634\u0647\u0631\u064B\u0627", PluralCategory.OTHER to "{n} \u0634\u0647\u0631")),
            year = pluralUnit(mapOf(PluralCategory.ZERO to "{n} \u0633\u0646\u0629", PluralCategory.ONE to "\u0633\u0646\u0629", PluralCategory.TWO to "\u0633\u0646\u062A\u0627\u0646", PluralCategory.FEW to "{n} \u0633\u0646\u0648\u0627\u062A", PluralCategory.MANY to "{n} \u0633\u0646\u0629", PluralCategory.OTHER to "{n} \u0633\u0646\u0629"))
        ),
        half = "{0} \u0648\u0646\u0635\u0641",
        delimiter = " \u0648",
        justBorn = "\u062D\u062F\u064A\u062B \u0627\u0644\u0648\u0644\u0627\u062F\u0629",
        stages = Stages(
            newborn = "\u062D\u062F\u064A\u062B \u0627\u0644\u0648\u0644\u0627\u062F\u0629",
            infant = "\u0631\u0636\u064A\u0639",
            toddler = "\u0637\u0641\u0644 \u0635\u063A\u064A\u0631",
            child = "\u0637\u0641\u0644",
            teenager = "\u0645\u0631\u0627\u0647\u0642",
            adult = "\u0628\u0627\u0644\u063A"
        )
    )

    // ================================================================
    // BG — Bulgarian
    // ================================================================
    public val BG: AgeLocale = AgeLocale(
        code = "bg",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0434\u0435\u043D", PluralCategory.OTHER to "{n} \u0434\u043D\u0438")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0441\u0435\u0434\u043C\u0438\u0446\u0430", PluralCategory.OTHER to "{n} \u0441\u0435\u0434\u043C\u0438\u0446\u0438")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u043C\u0435\u0441\u0435\u0446", PluralCategory.OTHER to "{n} \u043C\u0435\u0441\u0435\u0446\u0430")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0433\u043E\u0434\u0438\u043D\u0430", PluralCategory.OTHER to "{n} \u0433\u043E\u0434\u0438\u043D\u0438"))
        ),
        half = "{0} \u0438 \u043F\u043E\u043B\u043E\u0432\u0438\u043D\u0430",
        delimiter = ", ",
        justBorn = "\u041D\u043E\u0432\u043E\u0440\u043E\u0434\u0435\u043D\u043E",
        stages = Stages(
            newborn = "\u041D\u043E\u0432\u043E\u0440\u043E\u0434\u0435\u043D\u043E",
            infant = "\u0411\u0435\u0431\u0435",
            toddler = "\u041C\u0430\u043B\u043A\u043E \u0434\u0435\u0442\u0435",
            child = "\u0414\u0435\u0442\u0435",
            teenager = "\u0422\u0438\u0439\u043D\u0435\u0439\u0434\u0436\u044A\u0440",
            adult = "\u0412\u044A\u0437\u0440\u0430\u0441\u0442\u0435\u043D"
        )
    )

    // ================================================================
    // BN — Bengali
    // ================================================================
    public val BN: AgeLocale = AgeLocale(
        code = "bn",
        plural = { n -> if (n == 0 || n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u09A6\u09BF\u09A8", PluralCategory.OTHER to "{n} \u09A6\u09BF\u09A8")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u09B8\u09AA\u09CD\u09A4\u09BE\u09B9", PluralCategory.OTHER to "{n} \u09B8\u09AA\u09CD\u09A4\u09BE\u09B9")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u09AE\u09BE\u09B8", PluralCategory.OTHER to "{n} \u09AE\u09BE\u09B8")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u09AC\u099B\u09B0", PluralCategory.OTHER to "{n} \u09AC\u099B\u09B0"))
        ),
        half = "\u09B8\u09BE\u09DC\u09C7 {n}",
        delimiter = ", ",
        justBorn = "\u09A8\u09AC\u099C\u09BE\u09A4\u0995",
        stages = Stages(
            newborn = "\u09A8\u09AC\u099C\u09BE\u09A4\u0995",
            infant = "\u09B6\u09BF\u09B6\u09C1",
            toddler = "\u099B\u09CB\u099F \u09B6\u09BF\u09B6\u09C1",
            child = "\u09B6\u09BF\u09B6\u09C1",
            teenager = "\u0995\u09BF\u09B6\u09CB\u09B0",
            adult = "\u09AA\u09CD\u09B0\u09BE\u09AA\u09CD\u09A4\u09AC\u09AF\u09BC\u09B8\u09CD\u0995"
        )
    )

    // ================================================================
    // BS — Bosnian
    // ================================================================
    public val BS: AgeLocale = AgeLocale(
        code = "bs",
        plural = { n ->
            val mod10 = n % 10
            val mod100 = n % 100
            when {
                mod10 == 1 && mod100 != 11 -> PluralCategory.ONE
                mod10 in 2..4 && (mod100 < 12 || mod100 > 14) -> PluralCategory.FEW
                else -> PluralCategory.MANY
            }
        },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} dan", PluralCategory.FEW to "{n} dana", PluralCategory.MANY to "{n} dana", PluralCategory.OTHER to "{n} dana")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} sedmica", PluralCategory.FEW to "{n} sedmice", PluralCategory.MANY to "{n} sedmica", PluralCategory.OTHER to "{n} sedmica")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} mjesec", PluralCategory.FEW to "{n} mjeseca", PluralCategory.MANY to "{n} mjeseci", PluralCategory.OTHER to "{n} mjeseci")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} godina", PluralCategory.FEW to "{n} godine", PluralCategory.MANY to "{n} godina", PluralCategory.OTHER to "{n} godina"))
        ),
        half = "{0} i po",
        delimiter = ", ",
        justBorn = "Novoro\u0111en\u010De",
        stages = Stages(
            newborn = "Novoro\u0111en\u010De",
            infant = "Beba",
            toddler = "Malo dijete",
            child = "Dijete",
            teenager = "Tinejd\u017Eer",
            adult = "Odrasla osoba"
        )
    )

    // ================================================================
    // CA — Catalan
    // ================================================================
    public val CA: AgeLocale = AgeLocale(
        code = "ca",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} dia", PluralCategory.OTHER to "{n} dies")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} setmana", PluralCategory.OTHER to "{n} setmanes")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} mes", PluralCategory.OTHER to "{n} mesos")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} any", PluralCategory.OTHER to "{n} anys"))
        ),
        half = "{n} i mig",
        delimiter = ", ",
        justBorn = "Nounat",
        stages = Stages(
            newborn = "Nounat",
            infant = "Nad\u00F3",
            toddler = "Infant",
            child = "Nen",
            teenager = "Adolescent",
            adult = "Adult"
        )
    )

    // ================================================================
    // CS — Czech
    // ================================================================
    public val CS: AgeLocale = AgeLocale(
        code = "cs",
        plural = { n ->
            when {
                n == 1 -> PluralCategory.ONE
                n in 2..4 -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} den", PluralCategory.FEW to "{n} dny", PluralCategory.OTHER to "{n} dn\u00ED")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} t\u00FDden", PluralCategory.FEW to "{n} t\u00FDdny", PluralCategory.OTHER to "{n} t\u00FDdn\u016F")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} m\u011Bs\u00EDc", PluralCategory.FEW to "{n} m\u011Bs\u00EDce", PluralCategory.OTHER to "{n} m\u011Bs\u00EDc\u016F")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} rok", PluralCategory.FEW to "{n} roky", PluralCategory.OTHER to "{n} let"))
        ),
        half = "{n}\u00BD",
        delimiter = ", ",
        justBorn = "Novorozenec",
        stages = Stages(
            newborn = "Novorozenec",
            infant = "Kojenec",
            toddler = "Batole",
            child = "D\u00EDt\u011B",
            teenager = "Teenager",
            adult = "Dosp\u011Bl\u00FD"
        )
    )

    // ================================================================
    // DA — Danish
    // ================================================================
    public val DA: AgeLocale = AgeLocale(
        code = "da",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} dag", PluralCategory.OTHER to "{n} dage")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} uge", PluralCategory.OTHER to "{n} uger")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} m\u00E5ned", PluralCategory.OTHER to "{n} m\u00E5neder")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u00E5r", PluralCategory.OTHER to "{n} \u00E5r"))
        ),
        half = "{n}\u00BD",
        delimiter = ", ",
        justBorn = "Nyf\u00F8dt",
        stages = Stages(
            newborn = "Nyf\u00F8dt",
            infant = "Sp\u00E6dbarn",
            toddler = "Sm\u00E5barn",
            child = "Barn",
            teenager = "Teenager",
            adult = "Voksen"
        )
    )

    // ================================================================
    // DE — German
    // ================================================================
    public val DE: AgeLocale = AgeLocale(
        code = "de",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} Tag", PluralCategory.OTHER to "{n} Tage")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} Woche", PluralCategory.OTHER to "{n} Wochen")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} Monat", PluralCategory.OTHER to "{n} Monate")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} Jahr", PluralCategory.OTHER to "{n} Jahre"))
        ),
        half = "{n}\u00BD",
        delimiter = ", ",
        justBorn = "Neugeboren",
        stages = Stages(
            newborn = "Neugeborenes",
            infant = "S\u00E4ugling",
            toddler = "Kleinkind",
            child = "Kind",
            teenager = "Teenager",
            adult = "Erwachsener"
        )
    )

    // ================================================================
    // EL — Greek
    // ================================================================
    public val EL: AgeLocale = AgeLocale(
        code = "el",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u03BC\u03AD\u03C1\u03B1", PluralCategory.OTHER to "{n} \u03BC\u03AD\u03C1\u03B5\u03C2")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u03B5\u03B2\u03B4\u03BF\u03BC\u03AC\u03B4\u03B1", PluralCategory.OTHER to "{n} \u03B5\u03B2\u03B4\u03BF\u03BC\u03AC\u03B4\u03B5\u03C2")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u03BC\u03AE\u03BD\u03B1\u03C2", PluralCategory.OTHER to "{n} \u03BC\u03AE\u03BD\u03B5\u03C2")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u03C7\u03C1\u03CC\u03BD\u03BF\u03C2", PluralCategory.OTHER to "{n} \u03C7\u03C1\u03CC\u03BD\u03B9\u03B1"))
        ),
        half = "{0} \u03BA\u03B1\u03B9 \u03BC\u03B9\u03C3\u03CC",
        delimiter = ", ",
        justBorn = "\u039D\u03B5\u03BF\u03B3\u03AD\u03BD\u03BD\u03B7\u03C4\u03BF",
        stages = Stages(
            newborn = "\u039D\u03B5\u03BF\u03B3\u03AD\u03BD\u03BD\u03B7\u03C4\u03BF",
            infant = "\u0392\u03C1\u03AD\u03C6\u03BF\u03C2",
            toddler = "\u039D\u03AE\u03C0\u03B9\u03BF",
            child = "\u03A0\u03B1\u03B9\u03B4\u03AF",
            teenager = "\u0388\u03C6\u03B7\u03B2\u03BF\u03C2",
            adult = "\u0395\u03BD\u03AE\u03BB\u03B9\u03BA\u03B1\u03C2"
        )
    )

    // ================================================================
    // EN — English
    // ================================================================
    public val EN: AgeLocale = AgeLocale(
        code = "en",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} day", PluralCategory.OTHER to "{n} days")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} week", PluralCategory.OTHER to "{n} weeks")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} month", PluralCategory.OTHER to "{n} months")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} year", PluralCategory.OTHER to "{n} years"))
        ),
        half = "{n}\u00BD",
        delimiter = ", ",
        justBorn = "Newborn",
        stages = Stages(
            newborn = "Newborn",
            infant = "Infant",
            toddler = "Toddler",
            child = "Child",
            teenager = "Teenager",
            adult = "Adult"
        ),
        short = CompactnessOverride(
            day = simpleUnit("{n} d"),
            week = simpleUnit("{n} wk"),
            month = simpleUnit("{n} mo"),
            year = simpleUnit("{n} yr")
        ),
        compact = CompactnessOverride(
            day = simpleUnit("{n}d"),
            week = simpleUnit("{n}w"),
            month = simpleUnit("{n}m"),
            year = simpleUnit("{n}y"),
            delimiter = ""
        )
    )

    // ================================================================
    // ES — Spanish
    // ================================================================
    public val ES: AgeLocale = AgeLocale(
        code = "es",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} d\u00EDa", PluralCategory.OTHER to "{n} d\u00EDas")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} semana", PluralCategory.OTHER to "{n} semanas")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} mes", PluralCategory.OTHER to "{n} meses")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} a\u00F1o", PluralCategory.OTHER to "{n} a\u00F1os"))
        ),
        half = "{n} y medio",
        delimiter = ", ",
        justBorn = "Reci\u00E9n nacido",
        stages = Stages(
            newborn = "Reci\u00E9n nacido",
            infant = "Beb\u00E9",
            toddler = "Ni\u00F1o peque\u00F1o",
            child = "Ni\u00F1o",
            teenager = "Adolescente",
            adult = "Adulto"
        )
    )

    // ================================================================
    // ET — Estonian
    // ================================================================
    public val ET: AgeLocale = AgeLocale(
        code = "et",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} p\u00E4ev", PluralCategory.OTHER to "{n} p\u00E4eva")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} n\u00E4dal", PluralCategory.OTHER to "{n} n\u00E4dalat")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} kuu", PluralCategory.OTHER to "{n} kuud")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} aasta", PluralCategory.OTHER to "{n} aastat"))
        ),
        half = "{n}\u00BD",
        delimiter = ", ",
        justBorn = "Vasts\u00FCndinu",
        stages = Stages(
            newborn = "Vasts\u00FCndinu",
            infant = "Imik",
            toddler = "V\u00E4ikelaps",
            child = "Laps",
            teenager = "Teismeline",
            adult = "T\u00E4iskasvanu"
        )
    )

    // ================================================================
    // EU — Basque
    // ================================================================
    public val EU: AgeLocale = AgeLocale(
        code = "eu",
        plural = { PluralCategory.OTHER },
        units = Units(
            day = simpleUnit("{n} egun"),
            week = simpleUnit("{n} aste"),
            month = simpleUnit("{n} hilabete"),
            year = simpleUnit("{n} urte")
        ),
        half = "{0} eta erdi",
        delimiter = ", ",
        justBorn = "Jaioberria",
        stages = Stages(
            newborn = "Jaioberria",
            infant = "Haurra",
            toddler = "Haur txikia",
            child = "Umea",
            teenager = "Nerabea",
            adult = "Heldua"
        )
    )

    // ================================================================
    // FA — Persian (Farsi)
    // ================================================================
    public val FA: AgeLocale = AgeLocale(
        code = "fa",
        plural = { n -> if (n == 0 || n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0631\u0648\u0632", PluralCategory.OTHER to "{n} \u0631\u0648\u0632")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0647\u0641\u062A\u0647", PluralCategory.OTHER to "{n} \u0647\u0641\u062A\u0647")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0645\u0627\u0647", PluralCategory.OTHER to "{n} \u0645\u0627\u0647")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0633\u0627\u0644", PluralCategory.OTHER to "{n} \u0633\u0627\u0644"))
        ),
        half = "{0} \u0648 \u0646\u06CC\u0645",
        delimiter = " \u0648 ",
        justBorn = "\u0646\u0648\u0632\u0627\u062F",
        stages = Stages(
            newborn = "\u0646\u0648\u0632\u0627\u062F",
            infant = "\u0634\u06CC\u0631\u062E\u0648\u0627\u0631",
            toddler = "\u0646\u0648\u067E\u0627",
            child = "\u06A9\u0648\u062F\u06A9",
            teenager = "\u0646\u0648\u062C\u0648\u0627\u0646",
            adult = "\u0628\u0632\u0631\u06AF\u0633\u0627\u0644"
        )
    )

    // ================================================================
    // FI — Finnish
    // ================================================================
    public val FI: AgeLocale = AgeLocale(
        code = "fi",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} p\u00E4iv\u00E4", PluralCategory.OTHER to "{n} p\u00E4iv\u00E4\u00E4")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} viikko", PluralCategory.OTHER to "{n} viikkoa")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} kuukausi", PluralCategory.OTHER to "{n} kuukautta")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} vuosi", PluralCategory.OTHER to "{n} vuotta"))
        ),
        half = "{n} ja puoli",
        delimiter = ", ",
        justBorn = "Vastasyntynyt",
        stages = Stages(
            newborn = "Vastasyntynyt",
            infant = "Vauva",
            toddler = "Taapero",
            child = "Lapsi",
            teenager = "Teini",
            adult = "Aikuinen"
        )
    )

    // ================================================================
    // FR — French
    // ================================================================
    public val FR: AgeLocale = AgeLocale(
        code = "fr",
        plural = { n -> if (n == 0 || n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} jour", PluralCategory.OTHER to "{n} jours")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} semaine", PluralCategory.OTHER to "{n} semaines")),
            month = simpleUnit("{n} mois"),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} an", PluralCategory.OTHER to "{n} ans"))
        ),
        half = "{0} et demi",
        delimiter = ", ",
        justBorn = "Nouveau-n\u00E9",
        stages = Stages(
            newborn = "Nouveau-n\u00E9",
            infant = "Nourrisson",
            toddler = "Bambin",
            child = "Enfant",
            teenager = "Adolescent",
            adult = "Adulte"
        )
    )

    // ================================================================
    // GA — Irish
    // ================================================================
    public val GA: AgeLocale = AgeLocale(
        code = "ga",
        plural = { PluralCategory.OTHER },
        units = Units(
            day = simpleUnit("{n} l\u00E1"),
            week = simpleUnit("{n} seachtain"),
            month = simpleUnit("{n} m\u00ED"),
            year = simpleUnit("{n} bliain")
        ),
        half = "{0} go leith",
        delimiter = ", ",
        justBorn = "Nuabheirthe",
        stages = Stages(
            newborn = "Nuabheirthe",
            infant = "Na\u00EDon\u00E1n",
            toddler = "Lapad\u00E1n",
            child = "P\u00E1iste",
            teenager = "D\u00E9ag\u00F3ir",
            adult = "Duine f\u00E1sta"
        )
    )

    // ================================================================
    // GU — Gujarati
    // ================================================================
    public val GU: AgeLocale = AgeLocale(
        code = "gu",
        plural = { n -> if (n == 0 || n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0AA6\u0ABF\u0AB5\u0AB8", PluralCategory.OTHER to "{n} \u0AA6\u0ABF\u0AB5\u0AB8")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0A85\u0AA0\u0AB5\u0ABE\u0AA1\u0ABF\u0AAF\u0AC1\u0A82", PluralCategory.OTHER to "{n} \u0A85\u0AA0\u0AB5\u0ABE\u0AA1\u0ABF\u0AAF\u0ABE")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0AAE\u0AB9\u0ABF\u0AA8\u0ACB", PluralCategory.OTHER to "{n} \u0AAE\u0AB9\u0ABF\u0AA8\u0ABE")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0AB5\u0AB0\u0ACD\u0AB7", PluralCategory.OTHER to "{n} \u0AB5\u0AB0\u0ACD\u0AB7"))
        ),
        half = "\u0AB8\u0ABE\u0AA1\u0AC7 {n}",
        delimiter = ", ",
        justBorn = "\u0AA8\u0AB5\u0A9C\u0ABE\u0AA4",
        stages = Stages(
            newborn = "\u0AA8\u0AB5\u0A9C\u0ABE\u0AA4",
            infant = "\u0AB6\u0ABF\u0AB6\u0AC1",
            toddler = "\u0AA8\u0ABE\u0AA8\u0AC1\u0A82 \u0AAC\u0ABE\u0AB3\u0A95",
            child = "\u0AAC\u0ABE\u0AB3\u0A95",
            teenager = "\u0A95\u0ABF\u0AB6\u0ACB\u0AB0",
            adult = "\u0AAA\u0AC1\u0A96\u0ACD\u0AA4"
        )
    )

    // ================================================================
    // HI — Hindi
    // ================================================================
    public val HI: AgeLocale = AgeLocale(
        code = "hi",
        plural = { n -> if (n == 0 || n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0926\u093F\u0928", PluralCategory.OTHER to "{n} \u0926\u093F\u0928")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0938\u092A\u094D\u0924\u093E\u0939", PluralCategory.OTHER to "{n} \u0938\u092A\u094D\u0924\u093E\u0939")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u092E\u0939\u0940\u0928\u093E", PluralCategory.OTHER to "{n} \u092E\u0939\u0940\u0928\u0947")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0938\u093E\u0932", PluralCategory.OTHER to "{n} \u0938\u093E\u0932"))
        ),
        half = "\u0938\u093E\u0922\u093C\u0947 {n}",
        delimiter = ", ",
        justBorn = "\u0928\u0935\u091C\u093E\u0924",
        stages = Stages(
            newborn = "\u0928\u0935\u091C\u093E\u0924",
            infant = "\u0936\u093F\u0936\u0941",
            toddler = "\u091B\u094B\u091F\u093E \u092C\u091A\u094D\u091A\u093E",
            child = "\u092C\u091A\u094D\u091A\u093E",
            teenager = "\u0915\u093F\u0936\u094B\u0930",
            adult = "\u0935\u092F\u0938\u094D\u0915"
        )
    )

    // ================================================================
    // HR — Croatian
    // ================================================================
    public val HR: AgeLocale = AgeLocale(
        code = "hr",
        plural = { n ->
            val mod10 = n % 10
            val mod100 = n % 100
            when {
                mod10 == 1 && mod100 != 11 -> PluralCategory.ONE
                mod10 in 2..4 && (mod100 < 12 || mod100 > 14) -> PluralCategory.FEW
                else -> PluralCategory.MANY
            }
        },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} dan", PluralCategory.FEW to "{n} dana", PluralCategory.MANY to "{n} dana", PluralCategory.OTHER to "{n} dana")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} tjedan", PluralCategory.FEW to "{n} tjedna", PluralCategory.MANY to "{n} tjedana", PluralCategory.OTHER to "{n} tjedana")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} mjesec", PluralCategory.FEW to "{n} mjeseca", PluralCategory.MANY to "{n} mjeseci", PluralCategory.OTHER to "{n} mjeseci")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} godina", PluralCategory.FEW to "{n} godine", PluralCategory.MANY to "{n} godina", PluralCategory.OTHER to "{n} godina"))
        ),
        half = "{0} i pol",
        delimiter = ", ",
        justBorn = "Novoro\u0111en\u010De",
        stages = Stages(
            newborn = "Novoro\u0111en\u010De",
            infant = "Dojen\u010De",
            toddler = "Malo dijete",
            child = "Dijete",
            teenager = "Tinejd\u017Eer",
            adult = "Odrasla osoba"
        )
    )

    // ================================================================
    // HU — Hungarian
    // ================================================================
    public val HU: AgeLocale = AgeLocale(
        code = "hu",
        plural = { PluralCategory.OTHER },
        units = Units(
            day = simpleUnit("{n} nap"),
            week = simpleUnit("{n} h\u00E9t"),
            month = simpleUnit("{n} h\u00F3nap"),
            year = simpleUnit("{n} \u00E9v")
        ),
        half = "{n} \u00E9s f\u00E9l",
        delimiter = ", ",
        justBorn = "\u00DAjsz\u00FCl\u00F6tt",
        stages = Stages(
            newborn = "\u00DAjsz\u00FCl\u00F6tt",
            infant = "Csecsem\u0151",
            toddler = "Kisgyermek",
            child = "Gyermek",
            teenager = "Tin\u00E9dzser",
            adult = "Feln\u0151tt"
        )
    )

    // ================================================================
    // IT — Italian
    // ================================================================
    public val IT: AgeLocale = AgeLocale(
        code = "it",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} giorno", PluralCategory.OTHER to "{n} giorni")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} settimana", PluralCategory.OTHER to "{n} settimane")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} mese", PluralCategory.OTHER to "{n} mesi")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} anno", PluralCategory.OTHER to "{n} anni"))
        ),
        half = "{0} e mezzo",
        delimiter = ", ",
        justBorn = "Neonato",
        stages = Stages(
            newborn = "Neonato",
            infant = "Lattante",
            toddler = "Bimbo",
            child = "Bambino",
            teenager = "Adolescente",
            adult = "Adulto"
        )
    )

    // ================================================================
    // JA — Japanese
    // ================================================================
    public val JA: AgeLocale = AgeLocale(
        code = "ja",
        plural = { PluralCategory.OTHER },
        units = Units(
            day = simpleUnit("{n}\u65E5"),
            week = simpleUnit("{n}\u9031"),
            month = simpleUnit("{n}\u30F6\u6708"),
            year = simpleUnit("{n}\u6B73")
        ),
        half = "{0}\u534A",
        delimiter = "",
        justBorn = "\u65B0\u751F\u5150",
        stages = Stages(
            newborn = "\u65B0\u751F\u5150",
            infant = "\u4E73\u5150",
            toddler = "\u5E7C\u5150",
            child = "\u5150\u7AE5",
            teenager = "\u9752\u5C11\u5E74",
            adult = "\u6210\u4EBA"
        )
    )

    // ================================================================
    // JV — Javanese
    // ================================================================
    public val JV: AgeLocale = AgeLocale(
        code = "jv",
        plural = { PluralCategory.OTHER },
        units = Units(
            day = simpleUnit("{n} dina"),
            week = simpleUnit("{n} minggu"),
            month = simpleUnit("{n} wulan"),
            year = simpleUnit("{n} taun")
        ),
        half = "{0} setengah",
        delimiter = ", ",
        justBorn = "Bayi anyar",
        stages = Stages(
            newborn = "Bayi anyar",
            infant = "Bayi",
            toddler = "Balita",
            child = "Bocah",
            teenager = "Remaja",
            adult = "Diwasa"
        )
    )

    // ================================================================
    // KO — Korean
    // ================================================================
    public val KO: AgeLocale = AgeLocale(
        code = "ko",
        plural = { PluralCategory.OTHER },
        units = Units(
            day = simpleUnit("{n}\uC77C"),
            week = simpleUnit("{n}\uC8FC"),
            month = simpleUnit("{n}\uAC1C\uC6D4"),
            year = simpleUnit("{n}\uC0B4")
        ),
        half = "{0} \uBC18",
        delimiter = " ",
        justBorn = "\uC2E0\uC0DD\uC544",
        stages = Stages(
            newborn = "\uC2E0\uC0DD\uC544",
            infant = "\uC601\uC544",
            toddler = "\uC720\uC544",
            child = "\uC544\uB3D9",
            teenager = "\uCCAD\uC18C\uB144",
            adult = "\uC131\uC778"
        )
    )

    // ================================================================
    // LT — Lithuanian
    // ================================================================
    public val LT: AgeLocale = AgeLocale(
        code = "lt",
        plural = { n ->
            val mod10 = n % 10
            val mod100 = n % 100
            when {
                mod10 == 1 && mod100 != 11 -> PluralCategory.ONE
                mod10 in 2..9 && (mod100 < 12 || mod100 > 19) -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} diena", PluralCategory.FEW to "{n} dienos", PluralCategory.OTHER to "{n} dien\u0173")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} savait\u0117", PluralCategory.FEW to "{n} savait\u0117s", PluralCategory.OTHER to "{n} savai\u010Di\u0173")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} m\u0117nuo", PluralCategory.FEW to "{n} m\u0117nesiai", PluralCategory.OTHER to "{n} m\u0117nesi\u0173")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} metai", PluralCategory.FEW to "{n} metai", PluralCategory.OTHER to "{n} met\u0173"))
        ),
        half = "{n}\u00BD",
        delimiter = ", ",
        justBorn = "Naujagimis",
        stages = Stages(
            newborn = "Naujagimis",
            infant = "K\u016Bdikis",
            toddler = "Ma\u017Eylis",
            child = "Vaikas",
            teenager = "Paauglys",
            adult = "Suaug\u0119s"
        )
    )

    // ================================================================
    // LV — Latvian
    // ================================================================
    public val LV: AgeLocale = AgeLocale(
        code = "lv",
        plural = { n ->
            when {
                n == 0 -> PluralCategory.ZERO
                n % 10 == 1 && n % 100 != 11 -> PluralCategory.ONE
                else -> PluralCategory.OTHER
            }
        },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ZERO to "{n} dienu", PluralCategory.ONE to "{n} diena", PluralCategory.OTHER to "{n} dienas")),
            week = pluralUnit(mapOf(PluralCategory.ZERO to "{n} ned\u0113\u013Cu", PluralCategory.ONE to "{n} ned\u0113\u013Ca", PluralCategory.OTHER to "{n} ned\u0113\u013Cas")),
            month = pluralUnit(mapOf(PluralCategory.ZERO to "{n} m\u0113ne\u0161u", PluralCategory.ONE to "{n} m\u0113nesis", PluralCategory.OTHER to "{n} m\u0113ne\u0161i")),
            year = pluralUnit(mapOf(PluralCategory.ZERO to "{n} gadu", PluralCategory.ONE to "{n} gads", PluralCategory.OTHER to "{n} gadi"))
        ),
        half = "{n}\u00BD",
        delimiter = ", ",
        justBorn = "Jaundzimu\u0161ais",
        stages = Stages(
            newborn = "Jaundzimu\u0161ais",
            infant = "Z\u012Bdainis",
            toddler = "Mazulis",
            child = "B\u0113rns",
            teenager = "Pusaudzis",
            adult = "Pieaugu\u0161ais"
        )
    )

    // ================================================================
    // MR — Marathi
    // ================================================================
    public val MR: AgeLocale = AgeLocale(
        code = "mr",
        plural = { n -> if (n == 0 || n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0926\u093F\u0935\u0938", PluralCategory.OTHER to "{n} \u0926\u093F\u0935\u0938")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0906\u0920\u0935\u0921\u093E", PluralCategory.OTHER to "{n} \u0906\u0920\u0935\u0921\u0947")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u092E\u0939\u093F\u0928\u093E", PluralCategory.OTHER to "{n} \u092E\u0939\u093F\u0928\u0947")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0935\u0930\u094D\u0937", PluralCategory.OTHER to "{n} \u0935\u0930\u094D\u0937\u0947"))
        ),
        half = "\u0938\u093E\u0921\u0947 {n}",
        delimiter = ", ",
        justBorn = "\u0928\u0935\u091C\u093E\u0924",
        stages = Stages(
            newborn = "\u0928\u0935\u091C\u093E\u0924",
            infant = "\u0905\u0930\u094D\u092D\u0915",
            toddler = "\u092C\u093E\u0933",
            child = "\u092E\u0942\u0932",
            teenager = "\u0915\u093F\u0936\u094B\u0930",
            adult = "\u092A\u094D\u0930\u094C\u0922"
        )
    )

    // ================================================================
    // MS — Malay
    // ================================================================
    public val MS: AgeLocale = AgeLocale(
        code = "ms",
        plural = { PluralCategory.OTHER },
        units = Units(
            day = simpleUnit("{n} hari"),
            week = simpleUnit("{n} minggu"),
            month = simpleUnit("{n} bulan"),
            year = simpleUnit("{n} tahun")
        ),
        half = "{0} setengah",
        delimiter = ", ",
        justBorn = "Baru lahir",
        stages = Stages(
            newborn = "Baru lahir",
            infant = "Bayi",
            toddler = "Kanak-kanak kecil",
            child = "Kanak-kanak",
            teenager = "Remaja",
            adult = "Dewasa"
        )
    )

    // ================================================================
    // NB — Norwegian Bokm\u00E5l
    // ================================================================
    public val NB: AgeLocale = AgeLocale(
        code = "nb",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} dag", PluralCategory.OTHER to "{n} dager")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} uke", PluralCategory.OTHER to "{n} uker")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} m\u00E5ned", PluralCategory.OTHER to "{n} m\u00E5neder")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u00E5r", PluralCategory.OTHER to "{n} \u00E5r"))
        ),
        half = "{n}\u00BD",
        delimiter = ", ",
        justBorn = "Nyf\u00F8dt",
        stages = Stages(
            newborn = "Nyf\u00F8dt",
            infant = "Spedbarn",
            toddler = "Sm\u00E5barn",
            child = "Barn",
            teenager = "Ten\u00E5ring",
            adult = "Voksen"
        )
    )

    // ================================================================
    // NL — Dutch
    // ================================================================
    public val NL: AgeLocale = AgeLocale(
        code = "nl",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} dag", PluralCategory.OTHER to "{n} dagen")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} week", PluralCategory.OTHER to "{n} weken")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} maand", PluralCategory.OTHER to "{n} maanden")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} jaar", PluralCategory.OTHER to "{n} jaar"))
        ),
        half = "{n}\u00BD",
        delimiter = ", ",
        justBorn = "Pasgeboren",
        stages = Stages(
            newborn = "Pasgeborene",
            infant = "Baby",
            toddler = "Peuter",
            child = "Kind",
            teenager = "Tiener",
            adult = "Volwassene"
        )
    )

    // ================================================================
    // PA — Punjabi
    // ================================================================
    public val PA: AgeLocale = AgeLocale(
        code = "pa",
        plural = { n -> if (n == 0 || n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0A26\u0A3F\u0A28", PluralCategory.OTHER to "{n} \u0A26\u0A3F\u0A28")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0A39\u0A5E\u0A3C\u0A24\u0A3E", PluralCategory.OTHER to "{n} \u0A39\u0A5E\u0A3C\u0A24\u0A47")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0A2E\u0A39\u0A40\u0A28\u0A3E", PluralCategory.OTHER to "{n} \u0A2E\u0A39\u0A40\u0A28\u0A47")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0A38\u0A3E\u0A32", PluralCategory.OTHER to "{n} \u0A38\u0A3E\u0A32"))
        ),
        half = "\u0A38\u0A3E\u0A22\u0A47 {n}",
        delimiter = ", ",
        justBorn = "\u0A28\u0A35\u0A1C\u0A70\u0A2E\u0A3F\u0A06",
        stages = Stages(
            newborn = "\u0A28\u0A35\u0A1C\u0A70\u0A2E\u0A3F\u0A06",
            infant = "\u0A36\u0A3F\u0A36\u0A42",
            toddler = "\u0A1B\u0A4B\u0A1F\u0A3E \u0A2C\u0A71\u0A1A\u0A3E",
            child = "\u0A2C\u0A71\u0A1A\u0A3E",
            teenager = "\u0A15\u0A3F\u0A36\u0A4B\u0A30",
            adult = "\u0A2C\u0A3E\u0A32\u0A17"
        )
    )

    // ================================================================
    // PL — Polish
    // ================================================================
    public val PL: AgeLocale = AgeLocale(
        code = "pl",
        plural = { n ->
            when {
                n == 1 -> PluralCategory.ONE
                n % 10 in 2..4 && (n % 100 < 12 || n % 100 > 14) -> PluralCategory.FEW
                else -> PluralCategory.MANY
            }
        },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} dzie\u0144", PluralCategory.FEW to "{n} dni", PluralCategory.MANY to "{n} dni", PluralCategory.OTHER to "{n} dni")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} tydzie\u0144", PluralCategory.FEW to "{n} tygodnie", PluralCategory.MANY to "{n} tygodni", PluralCategory.OTHER to "{n} tygodni")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} miesi\u0105c", PluralCategory.FEW to "{n} miesi\u0105ce", PluralCategory.MANY to "{n} miesi\u0119cy", PluralCategory.OTHER to "{n} miesi\u0119cy")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} rok", PluralCategory.FEW to "{n} lata", PluralCategory.MANY to "{n} lat", PluralCategory.OTHER to "{n} lat"))
        ),
        half = "{n} i p\u00F3\u0142",
        delimiter = ", ",
        justBorn = "Noworodek",
        stages = Stages(
            newborn = "Noworodek",
            infant = "Niemowl\u0119",
            toddler = "Maluch",
            child = "Dziecko",
            teenager = "Nastolatek",
            adult = "Doros\u0142y"
        )
    )

    // ================================================================
    // PT — Portuguese
    // ================================================================
    public val PT: AgeLocale = AgeLocale(
        code = "pt",
        plural = { n -> if (n == 0 || n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} dia", PluralCategory.OTHER to "{n} dias")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} semana", PluralCategory.OTHER to "{n} semanas")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} m\u00EAs", PluralCategory.OTHER to "{n} meses")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} ano", PluralCategory.OTHER to "{n} anos"))
        ),
        half = "{0} e meio",
        delimiter = ", ",
        justBorn = "Rec\u00E9m-nascido",
        stages = Stages(
            newborn = "Rec\u00E9m-nascido",
            infant = "Beb\u00EA",
            toddler = "Crian\u00E7a pequena",
            child = "Crian\u00E7a",
            teenager = "Adolescente",
            adult = "Adulto"
        )
    )

    // ================================================================
    // RO — Romanian
    // ================================================================
    public val RO: AgeLocale = AgeLocale(
        code = "ro",
        plural = { n ->
            val mod100 = n % 100
            when {
                n == 1 -> PluralCategory.ONE
                n == 0 || (mod100 in 1..19) -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} zi", PluralCategory.FEW to "{n} zile", PluralCategory.OTHER to "{n} de zile")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} s\u0103pt\u0103m\u00E2n\u0103", PluralCategory.FEW to "{n} s\u0103pt\u0103m\u00E2ni", PluralCategory.OTHER to "{n} de s\u0103pt\u0103m\u00E2ni")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} lun\u0103", PluralCategory.FEW to "{n} luni", PluralCategory.OTHER to "{n} de luni")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} an", PluralCategory.FEW to "{n} ani", PluralCategory.OTHER to "{n} de ani"))
        ),
        half = "{0} \u0219i jum\u0103tate",
        delimiter = ", ",
        justBorn = "Nou-n\u0103scut",
        stages = Stages(
            newborn = "Nou-n\u0103scut",
            infant = "Sugar",
            toddler = "Copil mic",
            child = "Copil",
            teenager = "Adolescent",
            adult = "Adult"
        )
    )

    // ================================================================
    // RU — Russian
    // ================================================================
    public val RU: AgeLocale = AgeLocale(
        code = "ru",
        plural = { n ->
            val mod10 = n % 10
            val mod100 = n % 100
            when {
                mod10 == 1 && mod100 != 11 -> PluralCategory.ONE
                mod10 in 2..4 && (mod100 < 12 || mod100 > 14) -> PluralCategory.FEW
                else -> PluralCategory.MANY
            }
        },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0434\u0435\u043D\u044C", PluralCategory.FEW to "{n} \u0434\u043D\u044F", PluralCategory.MANY to "{n} \u0434\u043D\u0435\u0439", PluralCategory.OTHER to "{n} \u0434\u043D\u0435\u0439")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u043D\u0435\u0434\u0435\u043B\u044F", PluralCategory.FEW to "{n} \u043D\u0435\u0434\u0435\u043B\u0438", PluralCategory.MANY to "{n} \u043D\u0435\u0434\u0435\u043B\u044C", PluralCategory.OTHER to "{n} \u043D\u0435\u0434\u0435\u043B\u044C")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u043C\u0435\u0441\u044F\u0446", PluralCategory.FEW to "{n} \u043C\u0435\u0441\u044F\u0446\u0430", PluralCategory.MANY to "{n} \u043C\u0435\u0441\u044F\u0446\u0435\u0432", PluralCategory.OTHER to "{n} \u043C\u0435\u0441\u044F\u0446\u0435\u0432")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0433\u043E\u0434", PluralCategory.FEW to "{n} \u0433\u043E\u0434\u0430", PluralCategory.MANY to "{n} \u043B\u0435\u0442", PluralCategory.OTHER to "{n} \u043B\u0435\u0442"))
        ),
        half = "{n} \u0441 \u043F\u043E\u043B\u043E\u0432\u0438\u043D\u043E\u0439",
        delimiter = ", ",
        justBorn = "\u041D\u043E\u0432\u043E\u0440\u043E\u0436\u0434\u0451\u043D\u043D\u044B\u0439",
        stages = Stages(
            newborn = "\u041D\u043E\u0432\u043E\u0440\u043E\u0436\u0434\u0451\u043D\u043D\u044B\u0439",
            infant = "\u041C\u043B\u0430\u0434\u0435\u043D\u0435\u0446",
            toddler = "\u041C\u0430\u043B\u044B\u0448",
            child = "\u0420\u0435\u0431\u0451\u043D\u043E\u043A",
            teenager = "\u041F\u043E\u0434\u0440\u043E\u0441\u0442\u043E\u043A",
            adult = "\u0412\u0437\u0440\u043E\u0441\u043B\u044B\u0439"
        )
    )

    // ================================================================
    // SK — Slovak
    // ================================================================
    public val SK: AgeLocale = AgeLocale(
        code = "sk",
        plural = { n ->
            when {
                n == 1 -> PluralCategory.ONE
                n in 2..4 -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} de\u0148", PluralCategory.FEW to "{n} dni", PluralCategory.OTHER to "{n} dn\u00ED")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} t\u00FD\u017Ede\u0148", PluralCategory.FEW to "{n} t\u00FD\u017Edne", PluralCategory.OTHER to "{n} t\u00FD\u017Ed\u0148ov")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} mesiac", PluralCategory.FEW to "{n} mesiace", PluralCategory.OTHER to "{n} mesiacov")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} rok", PluralCategory.FEW to "{n} roky", PluralCategory.OTHER to "{n} rokov"))
        ),
        half = "{n}\u00BD",
        delimiter = ", ",
        justBorn = "Novorodenec",
        stages = Stages(
            newborn = "Novorodenec",
            infant = "Doj\u010Da",
            toddler = "Bato\u013Ea",
            child = "Die\u0165a",
            teenager = "T\u00EDned\u017Eer",
            adult = "Dospel\u00FD"
        )
    )

    // ================================================================
    // SL — Slovenian
    // ================================================================
    public val SL: AgeLocale = AgeLocale(
        code = "sl",
        plural = { n ->
            val mod100 = n % 100
            when {
                mod100 == 1 -> PluralCategory.ONE
                mod100 == 2 -> PluralCategory.TWO
                mod100 == 3 || mod100 == 4 -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} dan", PluralCategory.TWO to "{n} dneva", PluralCategory.FEW to "{n} dni", PluralCategory.OTHER to "{n} dni")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} teden", PluralCategory.TWO to "{n} tedna", PluralCategory.FEW to "{n} tedne", PluralCategory.OTHER to "{n} tednov")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} mesec", PluralCategory.TWO to "{n} meseca", PluralCategory.FEW to "{n} mesece", PluralCategory.OTHER to "{n} mesecev")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} leto", PluralCategory.TWO to "{n} leti", PluralCategory.FEW to "{n} leta", PluralCategory.OTHER to "{n} let"))
        ),
        half = "{0} in pol",
        delimiter = ", ",
        justBorn = "Novorojen\u010Dek",
        stages = Stages(
            newborn = "Novorojen\u010Dek",
            infant = "Dojen\u010Dek",
            toddler = "Mal\u010Dek",
            child = "Otrok",
            teenager = "Najstnik",
            adult = "Odrasel"
        )
    )

    // ================================================================
    // SQ — Albanian
    // ================================================================
    public val SQ: AgeLocale = AgeLocale(
        code = "sq",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} dit\u00EB", PluralCategory.OTHER to "{n} dit\u00EB")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} jav\u00EB", PluralCategory.OTHER to "{n} jav\u00EB")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} muaj", PluralCategory.OTHER to "{n} muaj")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} vit", PluralCategory.OTHER to "{n} vjet"))
        ),
        half = "{0} e gjysm\u00EB",
        delimiter = ", ",
        justBorn = "Sapolindur",
        stages = Stages(
            newborn = "Sapolindur",
            infant = "Foshnj\u00EB",
            toddler = "F\u00EBmij\u00EB i vog\u00EBl",
            child = "F\u00EBmij\u00EB",
            teenager = "Adoleshent",
            adult = "I rritur"
        )
    )

    // ================================================================
    // SR — Serbian (Cyrillic)
    // ================================================================
    public val SR: AgeLocale = AgeLocale(
        code = "sr",
        plural = { n ->
            val mod10 = n % 10
            val mod100 = n % 100
            when {
                mod10 == 1 && mod100 != 11 -> PluralCategory.ONE
                mod10 in 2..4 && (mod100 < 12 || mod100 > 14) -> PluralCategory.FEW
                else -> PluralCategory.MANY
            }
        },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0434\u0430\u043D", PluralCategory.FEW to "{n} \u0434\u0430\u043D\u0430", PluralCategory.MANY to "{n} \u0434\u0430\u043D\u0430", PluralCategory.OTHER to "{n} \u0434\u0430\u043D\u0430")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u043D\u0435\u0434\u0435\u0459\u0430", PluralCategory.FEW to "{n} \u043D\u0435\u0434\u0435\u0459\u0435", PluralCategory.MANY to "{n} \u043D\u0435\u0434\u0435\u0459\u0430", PluralCategory.OTHER to "{n} \u043D\u0435\u0434\u0435\u0459\u0430")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u043C\u0435\u0441\u0435\u0446", PluralCategory.FEW to "{n} \u043C\u0435\u0441\u0435\u0446\u0430", PluralCategory.MANY to "{n} \u043C\u0435\u0441\u0435\u0446\u0438", PluralCategory.OTHER to "{n} \u043C\u0435\u0441\u0435\u0446\u0438")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0433\u043E\u0434\u0438\u043D\u0430", PluralCategory.FEW to "{n} \u0433\u043E\u0434\u0438\u043D\u0435", PluralCategory.MANY to "{n} \u0433\u043E\u0434\u0438\u043D\u0430", PluralCategory.OTHER to "{n} \u0433\u043E\u0434\u0438\u043D\u0430"))
        ),
        half = "{0} \u0438 \u043F\u043E",
        delimiter = ", ",
        justBorn = "\u041D\u043E\u0432\u043E\u0440\u043E\u0452\u0435\u043D\u0447\u0435",
        stages = Stages(
            newborn = "\u041D\u043E\u0432\u043E\u0440\u043E\u0452\u0435\u043D\u0447\u0435",
            infant = "\u041E\u0434\u043E\u0458\u0447\u0435",
            toddler = "\u041C\u0430\u043B\u043E \u0434\u0435\u0442\u0435",
            child = "\u0414\u0435\u0442\u0435",
            teenager = "\u0422\u0438\u043D\u0435\u0458\u045F\u0435\u0440",
            adult = "\u041E\u0434\u0440\u0430\u0441\u043B\u0430 \u043E\u0441\u043E\u0431\u0430"
        )
    )

    // ================================================================
    // SV — Swedish
    // ================================================================
    public val SV: AgeLocale = AgeLocale(
        code = "sv",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} dag", PluralCategory.OTHER to "{n} dagar")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} vecka", PluralCategory.OTHER to "{n} veckor")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} m\u00E5nad", PluralCategory.OTHER to "{n} m\u00E5nader")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u00E5r", PluralCategory.OTHER to "{n} \u00E5r"))
        ),
        half = "{n}\u00BD",
        delimiter = ", ",
        justBorn = "Nyf\u00F6dd",
        stages = Stages(
            newborn = "Nyf\u00F6dd",
            infant = "Sp\u00E4dbarn",
            toddler = "Litet barn",
            child = "Barn",
            teenager = "Ton\u00E5ring",
            adult = "Vuxen"
        )
    )

    // ================================================================
    // TA — Tamil
    // ================================================================
    public val TA: AgeLocale = AgeLocale(
        code = "ta",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0BA8\u0BBE\u0BB3\u0BCD", PluralCategory.OTHER to "{n} \u0BA8\u0BBE\u0B9F\u0BCD\u0B95\u0BB3\u0BCD")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0BB5\u0BBE\u0BB0\u0BAE\u0BCD", PluralCategory.OTHER to "{n} \u0BB5\u0BBE\u0BB0\u0B99\u0BCD\u0B95\u0BB3\u0BCD")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0BAE\u0BBE\u0BA4\u0BAE\u0BCD", PluralCategory.OTHER to "{n} \u0BAE\u0BBE\u0BA4\u0B99\u0BCD\u0B95\u0BB3\u0BCD")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0BB5\u0BAF\u0BA4\u0BC1", PluralCategory.OTHER to "{n} \u0BB5\u0BAF\u0BA4\u0BC1"))
        ),
        half = "{0}\u0BB0\u0BC8",
        delimiter = ", ",
        justBorn = "\u0BAA\u0BBF\u0BB1\u0BA8\u0BCD\u0BA4 \u0B95\u0BC1\u0BB4\u0BA8\u0BCD\u0BA4\u0BC8",
        stages = Stages(
            newborn = "\u0BAA\u0BBF\u0BB1\u0BA8\u0BCD\u0BA4 \u0B95\u0BC1\u0BB4\u0BA8\u0BCD\u0BA4\u0BC8",
            infant = "\u0B95\u0BC1\u0BB4\u0BA8\u0BCD\u0BA4\u0BC8",
            toddler = "\u0B9A\u0BBF\u0BB1\u0BC1 \u0B95\u0BC1\u0BB4\u0BA8\u0BCD\u0BA4\u0BC8",
            child = "\u0B9A\u0BBF\u0BB1\u0BC1\u0BB5\u0BB0\u0BCD",
            teenager = "\u0B87\u0BB3\u0BAE\u0BCD\u0BAA\u0BB0\u0BC1\u0BB5\u0BAE\u0BCD",
            adult = "\u0BAA\u0BC6\u0BB0\u0BBF\u0BAF\u0BB5\u0BB0\u0BCD"
        )
    )

    // ================================================================
    // TE — Telugu
    // ================================================================
    public val TE: AgeLocale = AgeLocale(
        code = "te",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0C30\u0C4B\u0C1C\u0C41", PluralCategory.OTHER to "{n} \u0C30\u0C4B\u0C1C\u0C41\u0C32\u0C41")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0C35\u0C3E\u0C30\u0C02", PluralCategory.OTHER to "{n} \u0C35\u0C3E\u0C30\u0C3E\u0C32\u0C41")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0C28\u0C46\u0C32", PluralCategory.OTHER to "{n} \u0C28\u0C46\u0C32\u0C32\u0C41")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0C38\u0C02\u0C35\u0C24\u0C4D\u0C38\u0C30\u0C02", PluralCategory.OTHER to "{n} \u0C38\u0C02\u0C35\u0C24\u0C4D\u0C38\u0C30\u0C3E\u0C32\u0C41"))
        ),
        half = "{0}\u0C28\u0C4D\u0C28\u0C30",
        delimiter = ", ",
        justBorn = "\u0C28\u0C35\u0C1C\u0C3E\u0C24 \u0C36\u0C3F\u0C36\u0C41\u0C35\u0C41",
        stages = Stages(
            newborn = "\u0C28\u0C35\u0C1C\u0C3E\u0C24 \u0C36\u0C3F\u0C36\u0C41\u0C35\u0C41",
            infant = "\u0C36\u0C3F\u0C36\u0C41\u0C35\u0C41",
            toddler = "\u0C1A\u0C3F\u0C28\u0C4D\u0C28 \u0C2A\u0C3F\u0C32\u0C4D\u0C32\u0C35\u0C3E\u0C21\u0C41",
            child = "\u0C2A\u0C3F\u0C32\u0C4D\u0C32\u0C35\u0C3E\u0C21\u0C41",
            teenager = "\u0C15\u0C4C\u0C2E\u0C3E\u0C30\u0C26\u0C36",
            adult = "\u0C35\u0C2F\u0C4B\u0C1C\u0C28\u0C41\u0C21\u0C41"
        )
    )

    // ================================================================
    // TH — Thai
    // ================================================================
    public val TH: AgeLocale = AgeLocale(
        code = "th",
        plural = { PluralCategory.OTHER },
        units = Units(
            day = simpleUnit("{n} \u0E27\u0E31\u0E19"),
            week = simpleUnit("{n} \u0E2A\u0E31\u0E1B\u0E14\u0E32\u0E2B\u0E4C"),
            month = simpleUnit("{n} \u0E40\u0E14\u0E37\u0E2D\u0E19"),
            year = simpleUnit("{n} \u0E1B\u0E35")
        ),
        half = "{0}\u0E04\u0E23\u0E36\u0E48\u0E07",
        delimiter = " ",
        justBorn = "\u0E41\u0E23\u0E01\u0E40\u0E01\u0E34\u0E14",
        stages = Stages(
            newborn = "\u0E41\u0E23\u0E01\u0E40\u0E01\u0E34\u0E14",
            infant = "\u0E17\u0E32\u0E23\u0E01",
            toddler = "\u0E40\u0E14\u0E47\u0E01\u0E27\u0E31\u0E22\u0E40\u0E15\u0E32\u0E30\u0E41\u0E15\u0E30",
            child = "\u0E40\u0E14\u0E47\u0E01",
            teenager = "\u0E27\u0E31\u0E22\u0E23\u0E38\u0E48\u0E19",
            adult = "\u0E1C\u0E39\u0E49\u0E43\u0E2B\u0E0D\u0E48"
        )
    )

    // ================================================================
    // TR — Turkish
    // ================================================================
    public val TR: AgeLocale = AgeLocale(
        code = "tr",
        plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} g\u00FCn", PluralCategory.OTHER to "{n} g\u00FCn")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} hafta", PluralCategory.OTHER to "{n} hafta")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} ay", PluralCategory.OTHER to "{n} ay")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} ya\u015F", PluralCategory.OTHER to "{n} ya\u015F"))
        ),
        half = "{n} bu\u00E7uk",
        delimiter = ", ",
        justBorn = "Yeni do\u011Fan",
        stages = Stages(
            newborn = "Yeni do\u011Fan",
            infant = "Bebek",
            toddler = "K\u00FC\u00E7\u00FCk \u00E7ocuk",
            child = "\u00C7ocuk",
            teenager = "Ergen",
            adult = "Yeti\u015Fkin"
        )
    )

    // ================================================================
    // UK — Ukrainian
    // ================================================================
    public val UK: AgeLocale = AgeLocale(
        code = "uk",
        plural = { n ->
            val mod10 = n % 10
            val mod100 = n % 100
            when {
                mod10 == 1 && mod100 != 11 -> PluralCategory.ONE
                mod10 in 2..4 && (mod100 < 12 || mod100 > 14) -> PluralCategory.FEW
                else -> PluralCategory.MANY
            }
        },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0434\u0435\u043D\u044C", PluralCategory.FEW to "{n} \u0434\u043D\u0456", PluralCategory.MANY to "{n} \u0434\u043D\u0456\u0432", PluralCategory.OTHER to "{n} \u0434\u043D\u0456\u0432")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0442\u0438\u0436\u0434\u0435\u043D\u044C", PluralCategory.FEW to "{n} \u0442\u0438\u0436\u043D\u0456", PluralCategory.MANY to "{n} \u0442\u0438\u0436\u043D\u0456\u0432", PluralCategory.OTHER to "{n} \u0442\u0438\u0436\u043D\u0456\u0432")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u043C\u0456\u0441\u044F\u0446\u044C", PluralCategory.FEW to "{n} \u043C\u0456\u0441\u044F\u0446\u0456", PluralCategory.MANY to "{n} \u043C\u0456\u0441\u044F\u0446\u0456\u0432", PluralCategory.OTHER to "{n} \u043C\u0456\u0441\u044F\u0446\u0456\u0432")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0440\u0456\u043A", PluralCategory.FEW to "{n} \u0440\u043E\u043A\u0438", PluralCategory.MANY to "{n} \u0440\u043E\u043A\u0456\u0432", PluralCategory.OTHER to "{n} \u0440\u043E\u043A\u0456\u0432"))
        ),
        half = "{n} \u0437 \u043F\u043E\u043B\u043E\u0432\u0438\u043D\u043E\u044E",
        delimiter = ", ",
        justBorn = "\u041D\u043E\u0432\u043E\u043D\u0430\u0440\u043E\u0434\u0436\u0435\u043D\u0438\u0439",
        stages = Stages(
            newborn = "\u041D\u043E\u0432\u043E\u043D\u0430\u0440\u043E\u0434\u0436\u0435\u043D\u0438\u0439",
            infant = "\u041D\u0435\u043C\u043E\u0432\u043B\u044F",
            toddler = "\u041C\u0430\u043B\u044E\u043A",
            child = "\u0414\u0438\u0442\u0438\u043D\u0430",
            teenager = "\u041F\u0456\u0434\u043B\u0456\u0442\u043E\u043A",
            adult = "\u0414\u043E\u0440\u043E\u0441\u043B\u0438\u0439"
        )
    )

    // ================================================================
    // UR — Urdu
    // ================================================================
    public val UR: AgeLocale = AgeLocale(
        code = "ur",
        plural = { n -> if (n == 0 || n == 1) PluralCategory.ONE else PluralCategory.OTHER },
        units = Units(
            day = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u062F\u0646", PluralCategory.OTHER to "{n} \u062F\u0646")),
            week = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u06C1\u0641\u062A\u06C1", PluralCategory.OTHER to "{n} \u06C1\u0641\u062A\u06D2")),
            month = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0645\u06C1\u06CC\u0646\u06C1", PluralCategory.OTHER to "{n} \u0645\u06C1\u06CC\u0646\u06D2")),
            year = pluralUnit(mapOf(PluralCategory.ONE to "{n} \u0633\u0627\u0644", PluralCategory.OTHER to "{n} \u0633\u0627\u0644"))
        ),
        half = "\u0633\u0627\u0691\u06BE\u06D2 {n}",
        delimiter = "\u060C ",
        justBorn = "\u0646\u0648\u0645\u0648\u0644\u0648\u062F",
        stages = Stages(
            newborn = "\u0646\u0648\u0645\u0648\u0644\u0648\u062F",
            infant = "\u0634\u06CC\u0631\u062E\u0648\u0627\u0631",
            toddler = "\u0686\u06BE\u0648\u0679\u0627 \u0628\u0686\u06C1",
            child = "\u0628\u0686\u06C1",
            teenager = "\u0646\u0648\u062C\u0648\u0627\u0646",
            adult = "\u0628\u0627\u0644\u063A"
        )
    )

    // ================================================================
    // VI — Vietnamese
    // ================================================================
    public val VI: AgeLocale = AgeLocale(
        code = "vi",
        plural = { PluralCategory.OTHER },
        units = Units(
            day = simpleUnit("{n} ng\u00E0y"),
            week = simpleUnit("{n} tu\u1EA7n"),
            month = simpleUnit("{n} th\u00E1ng"),
            year = simpleUnit("{n} tu\u1ED5i")
        ),
        half = "{0} r\u01B0\u1EE1i",
        delimiter = ", ",
        justBorn = "S\u01A1 sinh",
        stages = Stages(
            newborn = "S\u01A1 sinh",
            infant = "Tr\u1EBB s\u01A1 sinh",
            toddler = "Tr\u1EBB m\u1EDBi bi\u1EBFt \u0111i",
            child = "Tr\u1EBB em",
            teenager = "Thi\u1EBFu ni\u00EAn",
            adult = "Ng\u01B0\u1EDDi l\u1EDBn"
        )
    )

    // ================================================================
    // ZH — Chinese
    // ================================================================
    public val ZH: AgeLocale = AgeLocale(
        code = "zh",
        plural = { PluralCategory.OTHER },
        units = Units(
            day = simpleUnit("{n}\u5929"),
            week = simpleUnit("{n}\u5468"),
            month = simpleUnit("{n}\u4E2A\u6708"),
            year = simpleUnit("{n}\u5C81")
        ),
        half = "{0}\u534A",
        delimiter = "",
        justBorn = "\u65B0\u751F\u513F",
        stages = Stages(
            newborn = "\u65B0\u751F\u513F",
            infant = "\u5A74\u513F",
            toddler = "\u5E7C\u513F",
            child = "\u513F\u7AE5",
            teenager = "\u9752\u5C11\u5E74",
            adult = "\u6210\u4EBA"
        )
    )

    /**
     * Map of all locales by code.
     */
    public val ALL: Map<String, AgeLocale> = mapOf(
        "ar" to AR, "bg" to BG, "bn" to BN, "bs" to BS, "ca" to CA,
        "cs" to CS, "da" to DA, "de" to DE, "el" to EL, "en" to EN,
        "es" to ES, "et" to ET, "eu" to EU, "fa" to FA, "fi" to FI,
        "fr" to FR, "ga" to GA, "gu" to GU, "hi" to HI, "hr" to HR,
        "hu" to HU, "it" to IT, "ja" to JA, "jv" to JV, "ko" to KO,
        "lt" to LT, "lv" to LV, "mr" to MR, "ms" to MS, "nb" to NB,
        "nl" to NL, "pa" to PA, "pl" to PL, "pt" to PT, "ro" to RO,
        "ru" to RU, "sk" to SK, "sl" to SL, "sq" to SQ, "sr" to SR,
        "sv" to SV, "ta" to TA, "te" to TE, "th" to TH, "tr" to TR,
        "uk" to UK, "ur" to UR, "vi" to VI, "zh" to ZH
    )
}
