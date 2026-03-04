"""French locale."""

from sayable_time.locale import ClockConfig, CompactnessOverride, ShortClockConfig, TimeLocale

FR = TimeLocale(
    code="fr",
    clock=ClockConfig(
        hours=["douze", "une", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf", "dix", "onze"],
        midnight="minuit",
        noon="midi",
        patterns={
            0: "{h} heures",
            5: "{h} heures cinq",
            10: "{h} heures dix",
            15: "{h} heures et quart",
            20: "{h} heures vingt",
            25: "{h} heures vingt-cinq",
            30: "{h} heures et demie",
            35: "{h} heures trente-cinq",
            40: "{h} heures quarante",
            45: "{h} heures moins le quart",
            50: "{h} heures cinquante",
            55: "{h} heures cinquante-cinq",
        },
    ),
    short=CompactnessOverride(
        clock=ShortClockConfig(use24h=True, format="{h}:{mm}"),
    ),
    compact=CompactnessOverride(
        clock=ShortClockConfig(use24h=True, format="{h}h{mm}"),
    ),
)
