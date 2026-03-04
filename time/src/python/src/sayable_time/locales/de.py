"""German locale."""

from sayable_time.locale import ClockConfig, CompactnessOverride, ShortClockConfig, TimeLocale

DE = TimeLocale(
    code="de",
    clock=ClockConfig(
        hours=["zwölf", "eins", "zwei", "drei", "vier", "fünf", "sechs", "sieben", "acht", "neun", "zehn", "elf"],
        midnight="Mitternacht",
        noon="Mittag",
        patterns={
            0: "{h} Uhr",
            5: "fünf nach {h}",
            10: "zehn nach {h}",
            15: "Viertel nach {h}",
            20: "zwanzig nach {h}",
            25: "fünf vor halb {next_h}",
            30: "halb {next_h}",
            35: "fünf nach halb {next_h}",
            40: "zwanzig vor {next_h}",
            45: "Viertel vor {next_h}",
            50: "zehn vor {next_h}",
            55: "fünf vor {next_h}",
        },
    ),
    short=CompactnessOverride(
        clock=ShortClockConfig(use24h=True, format="{h}:{mm}"),
    ),
    compact=CompactnessOverride(
        clock=ShortClockConfig(use24h=True, format="{h}:{mm}"),
    ),
)
