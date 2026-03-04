#!/usr/bin/env python3
"""Bootstrap all 71 sayable-time locale JSON files from sayable-age locale data.

Copies shared fields (code, name, pluralRule, half, delimiter, day/week/month/year units)
from sayable-age, adds time-specific units (second, minute, hour) and relative time
fields (justNow, ago, inFuture), and adds clock patterns for supported locales.

Run from the repo root:
    python time/_bootstrap_locales.py
"""

from __future__ import annotations

import json
import os

REPO_ROOT = os.path.dirname(os.path.abspath(__file__))
REPO_PARENT = os.path.dirname(REPO_ROOT)
AGE_LOCALES = os.path.join(REPO_PARENT, "age", "locales", "src")
TIME_LOCALES = os.path.join(REPO_ROOT, "locales", "src")

# Time unit translations for all 71 locales
# Keyed by locale code -> {second, minute, hour} unit forms
_TIME_UNITS: dict[str, dict] = {
    "am": {
        "second": {"one": "{n} ሰከንድ", "other": "{n} ሰከንዶች"},
        "minute": {"one": "{n} ደቂቃ", "other": "{n} ደቂቃዎች"},
        "hour": {"one": "{n} ሰዓት", "other": "{n} ሰዓቶች"},
    },
    "ar": {
        "second": {"zero": "{n} ثانية", "one": "ثانية واحدة", "two": "ثانيتان", "few": "{n} ثوانٍ", "many": "{n} ثانية", "other": "{n} ثانية"},
        "minute": {"zero": "{n} دقيقة", "one": "دقيقة واحدة", "two": "دقيقتان", "few": "{n} دقائق", "many": "{n} دقيقة", "other": "{n} دقيقة"},
        "hour": {"zero": "{n} ساعة", "one": "ساعة واحدة", "two": "ساعتان", "few": "{n} ساعات", "many": "{n} ساعة", "other": "{n} ساعة"},
    },
    "az": {
        "second": "{n} saniyə",
        "minute": "{n} dəqiqə",
        "hour": "{n} saat",
    },
    "bg": {
        "second": {"one": "{n} секунда", "other": "{n} секунди"},
        "minute": {"one": "{n} минута", "other": "{n} минути"},
        "hour": {"one": "{n} час", "other": "{n} часа"},
    },
    "bn": {
        "second": "{n} সেকেন্ড",
        "minute": "{n} মিনিট",
        "hour": "{n} ঘন্টা",
    },
    "br": {
        "second": {"one": "{n} eilenn", "two": "{n} eilenn", "few": "{n} eilenn", "many": "{n} a eilennoù", "other": "{n} eilenn"},
        "minute": {"one": "{n} munut", "two": "{n} vunut", "few": "{n} munut", "many": "{n} a vunutoù", "other": "{n} munut"},
        "hour": {"one": "{n} eur", "two": "{n} eur", "few": "{n} eur", "many": "{n} a eurvezhioù", "other": "{n} eur"},
    },
    "bs": {
        "second": {"one": "{n} sekunda", "few": "{n} sekunde", "other": "{n} sekundi"},
        "minute": {"one": "{n} minuta", "few": "{n} minute", "other": "{n} minuta"},
        "hour": {"one": "{n} sat", "few": "{n} sata", "other": "{n} sati"},
    },
    "ca": {
        "second": {"one": "{n} segon", "other": "{n} segons"},
        "minute": {"one": "{n} minut", "other": "{n} minuts"},
        "hour": {"one": "{n} hora", "other": "{n} hores"},
    },
    "cs": {
        "second": {"one": "{n} sekunda", "few": "{n} sekundy", "other": "{n} sekund"},
        "minute": {"one": "{n} minuta", "few": "{n} minuty", "other": "{n} minut"},
        "hour": {"one": "{n} hodina", "few": "{n} hodiny", "other": "{n} hodin"},
    },
    "cy": {
        "second": {"zero": "{n} eiliad", "one": "{n} eiliad", "two": "{n} eiliad", "few": "{n} eiliad", "many": "{n} eiliad", "other": "{n} eiliad"},
        "minute": {"zero": "{n} munud", "one": "{n} munud", "two": "{n} funud", "few": "{n} munud", "many": "{n} munud", "other": "{n} munud"},
        "hour": {"zero": "{n} awr", "one": "{n} awr", "two": "{n} awr", "few": "{n} awr", "many": "{n} awr", "other": "{n} awr"},
    },
    "da": {
        "second": {"one": "{n} sekund", "other": "{n} sekunder"},
        "minute": {"one": "{n} minut", "other": "{n} minutter"},
        "hour": {"one": "{n} time", "other": "{n} timer"},
    },
    "de": {
        "second": {"one": "{n} Sekunde", "other": "{n} Sekunden"},
        "minute": {"one": "{n} Minute", "other": "{n} Minuten"},
        "hour": {"one": "{n} Stunde", "other": "{n} Stunden"},
    },
    "el": {
        "second": {"one": "{n} δευτερόλεπτο", "other": "{n} δευτερόλεπτα"},
        "minute": {"one": "{n} λεπτό", "other": "{n} λεπτά"},
        "hour": {"one": "{n} ώρα", "other": "{n} ώρες"},
    },
    "en": {
        "second": {"one": "{n} second", "other": "{n} seconds"},
        "minute": {"one": "{n} minute", "other": "{n} minutes"},
        "hour": {"one": "{n} hour", "other": "{n} hours"},
    },
    "es": {
        "second": {"one": "{n} segundo", "other": "{n} segundos"},
        "minute": {"one": "{n} minuto", "other": "{n} minutos"},
        "hour": {"one": "{n} hora", "other": "{n} horas"},
    },
    "et": {
        "second": {"one": "{n} sekund", "other": "{n} sekundit"},
        "minute": {"one": "{n} minut", "other": "{n} minutit"},
        "hour": {"one": "{n} tund", "other": "{n} tundi"},
    },
    "eu": {
        "second": "{n} segundo",
        "minute": "{n} minutu",
        "hour": "{n} ordu",
    },
    "fa": {
        "second": "{n} ثانیه",
        "minute": "{n} دقیقه",
        "hour": "{n} ساعت",
    },
    "fi": {
        "second": {"one": "{n} sekunti", "other": "{n} sekuntia"},
        "minute": {"one": "{n} minuutti", "other": "{n} minuuttia"},
        "hour": {"one": "{n} tunti", "other": "{n} tuntia"},
    },
    "fil": {
        "second": "{n} segundo",
        "minute": "{n} minuto",
        "hour": "{n} oras",
    },
    "fr": {
        "second": {"one": "{n} seconde", "other": "{n} secondes"},
        "minute": {"one": "{n} minute", "other": "{n} minutes"},
        "hour": {"one": "{n} heure", "other": "{n} heures"},
    },
    "ga": {
        "second": {"one": "{n} soicind", "two": "{n} shoicind", "few": "{n} shoicind", "many": "{n} soicind", "other": "{n} soicind"},
        "minute": {"one": "{n} nóiméad", "two": "{n} nóiméad", "few": "{n} nóiméad", "many": "{n} nóiméad", "other": "{n} nóiméad"},
        "hour": {"one": "{n} uair", "two": "{n} uair", "few": "{n} huaire", "many": "{n} n-uaire", "other": "{n} uair"},
    },
    "gd": {
        "second": {"one": "{n} diog", "two": "{n} dhiog", "few": "{n} diogan", "other": "{n} diog"},
        "minute": {"one": "{n} mhionaid", "two": "{n} mhionaid", "few": "{n} mionaidean", "other": "{n} mionaid"},
        "hour": {"one": "{n} uair", "two": "{n} uair", "few": "{n} uairean", "other": "{n} uair"},
    },
    "gu": {
        "second": "{n} સેકન્ડ",
        "minute": "{n} મિનિટ",
        "hour": "{n} કલાક",
    },
    "gv": {
        "second": {"one": "{n} çhiaghtoo", "two": "{n} çhiaghtoo", "few": "{n} çhiaghtoo", "other": "{n} çhiaghtooyn"},
        "minute": {"one": "{n} vinnid", "two": "{n} vinnid", "few": "{n} minnidyn", "other": "{n} minnid"},
        "hour": {"one": "{n} oor", "two": "{n} oor", "few": "{n} ooryn", "other": "{n} oor"},
    },
    "he": {
        "second": {"one": "שנייה {n}", "two": "שתי שניות", "other": "{n} שניות"},
        "minute": {"one": "דקה {n}", "two": "שתי דקות", "other": "{n} דקות"},
        "hour": {"one": "שעה {n}", "two": "שעתיים", "other": "{n} שעות"},
    },
    "hi": {
        "second": "{n} सेकंड",
        "minute": "{n} मिनट",
        "hour": "{n} घंटा",
    },
    "hr": {
        "second": {"one": "{n} sekunda", "few": "{n} sekunde", "other": "{n} sekundi"},
        "minute": {"one": "{n} minuta", "few": "{n} minute", "other": "{n} minuta"},
        "hour": {"one": "{n} sat", "few": "{n} sata", "other": "{n} sati"},
    },
    "hu": {
        "second": "{n} másodperc",
        "minute": "{n} perc",
        "hour": "{n} óra",
    },
    "id": {
        "second": "{n} detik",
        "minute": "{n} menit",
        "hour": "{n} jam",
    },
    "it": {
        "second": {"one": "{n} secondo", "other": "{n} secondi"},
        "minute": {"one": "{n} minuto", "other": "{n} minuti"},
        "hour": {"one": "{n} ora", "other": "{n} ore"},
    },
    "ja": {
        "second": "{n}秒",
        "minute": "{n}分",
        "hour": "{n}時間",
    },
    "jv": {
        "second": "{n} detik",
        "minute": "{n} menit",
        "hour": "{n} jam",
    },
    "ka": {
        "second": "{n} წამი",
        "minute": "{n} წუთი",
        "hour": "{n} საათი",
    },
    "kk": {
        "second": "{n} секунд",
        "minute": "{n} минут",
        "hour": "{n} сағат",
    },
    "km": {
        "second": "{n} វិនាទី",
        "minute": "{n} នាទី",
        "hour": "{n} ម៉ោង",
    },
    "ko": {
        "second": "{n}초",
        "minute": "{n}분",
        "hour": "{n}시간",
    },
    "kw": {
        "second": {"zero": "{n} sekond", "one": "{n} sekond", "two": "{n} sekond", "few": "{n} sekond", "many": "{n} sekond", "other": "{n} sekondow"},
        "minute": {"zero": "{n} mynysen", "one": "{n} mynysen", "two": "{n} vynysen", "few": "{n} mynysen", "many": "{n} mynysen", "other": "{n} mynysen"},
        "hour": {"zero": "{n} our", "one": "{n} our", "two": "{n} our", "few": "{n} our", "many": "{n} our", "other": "{n} our"},
    },
    "lt": {
        "second": {"one": "{n} sekundė", "few": "{n} sekundės", "other": "{n} sekundžių"},
        "minute": {"one": "{n} minutė", "few": "{n} minutės", "other": "{n} minučių"},
        "hour": {"one": "{n} valanda", "few": "{n} valandos", "other": "{n} valandų"},
    },
    "lv": {
        "second": {"zero": "{n} sekunžu", "one": "{n} sekunde", "other": "{n} sekundes"},
        "minute": {"zero": "{n} minūšu", "one": "{n} minūte", "other": "{n} minūtes"},
        "hour": {"zero": "{n} stundu", "one": "{n} stunda", "other": "{n} stundas"},
    },
    "mk": {
        "second": {"one": "{n} секунда", "other": "{n} секунди"},
        "minute": {"one": "{n} минута", "other": "{n} минути"},
        "hour": {"one": "{n} час", "other": "{n} часа"},
    },
    "mr": {
        "second": "{n} सेकंद",
        "minute": "{n} मिनिट",
        "hour": "{n} तास",
    },
    "ms": {
        "second": "{n} saat",
        "minute": "{n} minit",
        "hour": "{n} jam",
    },
    "mt": {
        "second": {"one": "{n} sekonda", "two": "{n} sekondi", "few": "{n} sekondi", "many": "{n}-il sekonda", "other": "{n} sekonda"},
        "minute": {"one": "{n} minuta", "two": "{n} minuti", "few": "{n} minuti", "many": "{n}-il minuta", "other": "{n} minuta"},
        "hour": {"one": "{n} siegħa", "two": "{n} sigħat", "few": "{n} sigħat", "many": "{n}-il siegħa", "other": "{n} siegħa"},
    },
    "my": {
        "second": "{n} စက္ကန့်",
        "minute": "{n} မိနစ်",
        "hour": "{n} နာရီ",
    },
    "nb": {
        "second": {"one": "{n} sekund", "other": "{n} sekunder"},
        "minute": {"one": "{n} minutt", "other": "{n} minutter"},
        "hour": {"one": "{n} time", "other": "{n} timer"},
    },
    "ne": {
        "second": "{n} सेकेन्ड",
        "minute": "{n} मिनेट",
        "hour": "{n} घण्टा",
    },
    "nl": {
        "second": {"one": "{n} seconde", "other": "{n} seconden"},
        "minute": {"one": "{n} minuut", "other": "{n} minuten"},
        "hour": {"one": "{n} uur", "other": "{n} uur"},
    },
    "pa": {
        "second": "{n} ਸਕਿੰਟ",
        "minute": "{n} ਮਿੰਟ",
        "hour": "{n} ਘੰਟਾ",
    },
    "pl": {
        "second": {"one": "{n} sekunda", "few": "{n} sekundy", "many": "{n} sekund"},
        "minute": {"one": "{n} minuta", "few": "{n} minuty", "many": "{n} minut"},
        "hour": {"one": "{n} godzina", "few": "{n} godziny", "many": "{n} godzin"},
    },
    "pt": {
        "second": {"one": "{n} segundo", "other": "{n} segundos"},
        "minute": {"one": "{n} minuto", "other": "{n} minutos"},
        "hour": {"one": "{n} hora", "other": "{n} horas"},
    },
    "ro": {
        "second": {"one": "{n} secundă", "few": "{n} secunde", "other": "{n} de secunde"},
        "minute": {"one": "{n} minut", "few": "{n} minute", "other": "{n} de minute"},
        "hour": {"one": "{n} oră", "few": "{n} ore", "other": "{n} de ore"},
    },
    "ru": {
        "second": {"one": "{n} секунда", "few": "{n} секунды", "many": "{n} секунд"},
        "minute": {"one": "{n} минута", "few": "{n} минуты", "many": "{n} минут"},
        "hour": {"one": "{n} час", "few": "{n} часа", "many": "{n} часов"},
    },
    "shi": {
        "second": {"one": "{n} tasint", "few": "{n} tasinin", "other": "{n} tasinin"},
        "minute": {"one": "{n} tusdiqt", "few": "{n} tusdiqin", "other": "{n} tusdiqin"},
        "hour": {"one": "{n} tasragt", "few": "{n} tisragin", "other": "{n} tisragin"},
    },
    "si": {
        "second": "{n} තත්පරය",
        "minute": "{n} මිනිත්තුව",
        "hour": "{n} පැය",
    },
    "sk": {
        "second": {"one": "{n} sekunda", "few": "{n} sekundy", "other": "{n} sekúnd"},
        "minute": {"one": "{n} minúta", "few": "{n} minúty", "other": "{n} minút"},
        "hour": {"one": "{n} hodina", "few": "{n} hodiny", "other": "{n} hodín"},
    },
    "sl": {
        "second": {"one": "{n} sekunda", "two": "{n} sekundi", "few": "{n} sekunde", "other": "{n} sekund"},
        "minute": {"one": "{n} minuta", "two": "{n} minuti", "few": "{n} minute", "other": "{n} minut"},
        "hour": {"one": "{n} ura", "two": "{n} uri", "few": "{n} ure", "other": "{n} ur"},
    },
    "sq": {
        "second": {"one": "{n} sekondë", "other": "{n} sekonda"},
        "minute": {"one": "{n} minutë", "other": "{n} minuta"},
        "hour": {"one": "{n} orë", "other": "{n} orë"},
    },
    "sr": {
        "second": {"one": "{n} секунда", "few": "{n} секунде", "other": "{n} секунди"},
        "minute": {"one": "{n} минут", "few": "{n} минута", "other": "{n} минута"},
        "hour": {"one": "{n} сат", "few": "{n} сата", "other": "{n} сати"},
    },
    "sv": {
        "second": {"one": "{n} sekund", "other": "{n} sekunder"},
        "minute": {"one": "{n} minut", "other": "{n} minuter"},
        "hour": {"one": "{n} timme", "other": "{n} timmar"},
    },
    "sw": {
        "second": "{n} sekunde",
        "minute": "{n} dakika",
        "hour": "{n} saa",
    },
    "ta": {
        "second": "{n} விநாடி",
        "minute": "{n} நிமிடம்",
        "hour": "{n} மணி நேரம்",
    },
    "te": {
        "second": "{n} సెకను",
        "minute": "{n} నిమిషం",
        "hour": "{n} గంట",
    },
    "th": {
        "second": "{n} วินาที",
        "minute": "{n} นาที",
        "hour": "{n} ชั่วโมง",
    },
    "tr": {
        "second": "{n} saniye",
        "minute": "{n} dakika",
        "hour": "{n} saat",
    },
    "tzm": {
        "second": {"one": "{n} tasint", "other": "{n} tisinin"},
        "minute": {"one": "{n} tusdiqt", "other": "{n} tusdiqin"},
        "hour": {"one": "{n} tasragt", "other": "{n} tisragin"},
    },
    "uk": {
        "second": {"one": "{n} секунда", "few": "{n} секунди", "many": "{n} секунд"},
        "minute": {"one": "{n} хвилина", "few": "{n} хвилини", "many": "{n} хвилин"},
        "hour": {"one": "{n} година", "few": "{n} години", "many": "{n} годин"},
    },
    "ur": {
        "second": "{n} سیکنڈ",
        "minute": "{n} منٹ",
        "hour": "{n} گھنٹہ",
    },
    "uz": {
        "second": "{n} soniya",
        "minute": "{n} daqiqa",
        "hour": "{n} soat",
    },
    "vi": {
        "second": "{n} giây",
        "minute": "{n} phút",
        "hour": "{n} giờ",
    },
    "zh": {
        "second": "{n}秒",
        "minute": "{n}分钟",
        "hour": "{n}小时",
    },
}

# Relative time translations
_RELATIVE: dict[str, dict] = {
    "am": {"justNow": "አሁን", "ago": "ከ{0} በፊት", "inFuture": "በ{0} ውስጥ"},
    "ar": {"justNow": "الآن", "ago": "منذ {0}", "inFuture": "بعد {0}"},
    "az": {"justNow": "indi", "ago": "{0} əvvəl", "inFuture": "{0} sonra"},
    "bg": {"justNow": "току-що", "ago": "преди {0}", "inFuture": "след {0}"},
    "bn": {"justNow": "এইমাত্র", "ago": "{0} আগে", "inFuture": "{0} পরে"},
    "br": {"justNow": "bremañ", "ago": "{0} zo", "inFuture": "a-benn {0}"},
    "bs": {"justNow": "upravo", "ago": "prije {0}", "inFuture": "za {0}"},
    "ca": {"justNow": "ara mateix", "ago": "fa {0}", "inFuture": "d'aquí a {0}"},
    "cs": {"justNow": "právě teď", "ago": "před {0}", "inFuture": "za {0}"},
    "cy": {"justNow": "nawr", "ago": "{0} yn ôl", "inFuture": "mewn {0}"},
    "da": {"justNow": "lige nu", "ago": "{0} siden", "inFuture": "om {0}"},
    "de": {"justNow": "gerade eben", "ago": "vor {0}", "inFuture": "in {0}"},
    "el": {"justNow": "μόλις τώρα", "ago": "πριν από {0}", "inFuture": "σε {0}"},
    "en": {"justNow": "just now", "ago": "{0} ago", "inFuture": "in {0}"},
    "es": {"justNow": "ahora mismo", "ago": "hace {0}", "inFuture": "en {0}"},
    "et": {"justNow": "just praegu", "ago": "{0} tagasi", "inFuture": "{0} pärast"},
    "eu": {"justNow": "oraintxe", "ago": "duela {0}", "inFuture": "{0} barru"},
    "fa": {"justNow": "همین الان", "ago": "{0} پیش", "inFuture": "{0} دیگر"},
    "fi": {"justNow": "juuri nyt", "ago": "{0} sitten", "inFuture": "{0} kuluttua"},
    "fil": {"justNow": "ngayon lang", "ago": "{0} na ang nakalipas", "inFuture": "sa loob ng {0}"},
    "fr": {"justNow": "à l'instant", "ago": "il y a {0}", "inFuture": "dans {0}"},
    "ga": {"justNow": "díreach anois", "ago": "{0} ó shin", "inFuture": "i gceann {0}"},
    "gd": {"justNow": "an-dràsta", "ago": "o chionn {0}", "inFuture": "an ceann {0}"},
    "gu": {"justNow": "હમણાં", "ago": "{0} પહેલાં", "inFuture": "{0} પછી"},
    "gv": {"justNow": "nish hene", "ago": "{0} er dy henney", "inFuture": "ayns {0}"},
    "he": {"justNow": "הרגע", "ago": "לפני {0}", "inFuture": "בעוד {0}"},
    "hi": {"justNow": "अभी", "ago": "{0} पहले", "inFuture": "{0} में"},
    "hr": {"justNow": "upravo", "ago": "prije {0}", "inFuture": "za {0}"},
    "hu": {"justNow": "éppen most", "ago": "{0} ezelőtt", "inFuture": "{0} múlva"},
    "id": {"justNow": "baru saja", "ago": "{0} yang lalu", "inFuture": "dalam {0}"},
    "it": {"justNow": "proprio ora", "ago": "{0} fa", "inFuture": "tra {0}"},
    "ja": {"justNow": "たった今", "ago": "{0}前", "inFuture": "{0}後"},
    "jv": {"justNow": "saiki", "ago": "{0} kepungkur", "inFuture": "ing {0}"},
    "ka": {"justNow": "ახლახანს", "ago": "{0} წინ", "inFuture": "{0} შემდეგ"},
    "kk": {"justNow": "дәл қазір", "ago": "{0} бұрын", "inFuture": "{0} кейін"},
    "km": {"justNow": "ឥឡូវនេះ", "ago": "{0}មុន", "inFuture": "ក្នុង{0}"},
    "ko": {"justNow": "방금", "ago": "{0} 전", "inFuture": "{0} 후"},
    "kw": {"justNow": "lemmyn", "ago": "{0} a-dhia", "inFuture": "a-ji {0}"},
    "lt": {"justNow": "ką tik", "ago": "prieš {0}", "inFuture": "po {0}"},
    "lv": {"justNow": "tikko", "ago": "pirms {0}", "inFuture": "pēc {0}"},
    "mk": {"justNow": "токму сега", "ago": "пред {0}", "inFuture": "за {0}"},
    "mr": {"justNow": "आत्ताच", "ago": "{0} पूर्वी", "inFuture": "{0} मध्ये"},
    "ms": {"justNow": "baru sahaja", "ago": "{0} lalu", "inFuture": "dalam {0}"},
    "mt": {"justNow": "bħalissa", "ago": "{0} ilu", "inFuture": "fi {0}"},
    "my": {"justNow": "ယခုလေးတင်", "ago": "လွန်ခဲ့သော {0}", "inFuture": "{0} အတွင်း"},
    "nb": {"justNow": "akkurat nå", "ago": "{0} siden", "inFuture": "om {0}"},
    "ne": {"justNow": "भर्खरै", "ago": "{0} अगाडि", "inFuture": "{0} पछि"},
    "nl": {"justNow": "zojuist", "ago": "{0} geleden", "inFuture": "over {0}"},
    "pa": {"justNow": "ਹੁਣੇ", "ago": "{0} ਪਹਿਲਾਂ", "inFuture": "{0} ਵਿੱਚ"},
    "pl": {"justNow": "właśnie teraz", "ago": "{0} temu", "inFuture": "za {0}"},
    "pt": {"justNow": "agora mesmo", "ago": "há {0}", "inFuture": "em {0}"},
    "ro": {"justNow": "chiar acum", "ago": "acum {0}", "inFuture": "peste {0}"},
    "ru": {"justNow": "только что", "ago": "{0} назад", "inFuture": "через {0}"},
    "shi": {"justNow": "ɣilad", "ago": "ɣ {0} zzrin", "inFuture": "ɣ {0}"},
    "si": {"justNow": "දැන්", "ago": "{0}ට පෙර", "inFuture": "{0}කින්"},
    "sk": {"justNow": "práve teraz", "ago": "pred {0}", "inFuture": "o {0}"},
    "sl": {"justNow": "ravnokar", "ago": "pred {0}", "inFuture": "čez {0}"},
    "sq": {"justNow": "pikërisht tani", "ago": "{0} më parë", "inFuture": "për {0}"},
    "sr": {"justNow": "управо", "ago": "пре {0}", "inFuture": "за {0}"},
    "sv": {"justNow": "just nu", "ago": "{0} sedan", "inFuture": "om {0}"},
    "sw": {"justNow": "sasa hivi", "ago": "{0} iliyopita", "inFuture": "baada ya {0}"},
    "ta": {"justNow": "இப்போதுதான்", "ago": "{0} முன்", "inFuture": "{0} கழித்து"},
    "te": {"justNow": "ఇప్పుడే", "ago": "{0} క్రితం", "inFuture": "{0} తర్వాత"},
    "th": {"justNow": "เมื่อกี้", "ago": "{0}ที่แล้ว", "inFuture": "ใน{0}"},
    "tr": {"justNow": "az önce", "ago": "{0} önce", "inFuture": "{0} sonra"},
    "tzm": {"justNow": "ɣilad", "ago": "ɣ {0} zzrin", "inFuture": "ɣ {0}"},
    "uk": {"justNow": "щойно", "ago": "{0} тому", "inFuture": "через {0}"},
    "ur": {"justNow": "ابھی", "ago": "{0} پہلے", "inFuture": "{0} میں"},
    "uz": {"justNow": "hozir", "ago": "{0} oldin", "inFuture": "{0} ichida"},
    "vi": {"justNow": "vừa xong", "ago": "{0} trước", "inFuture": "trong {0}"},
    "zh": {"justNow": "刚刚", "ago": "{0}前", "inFuture": "{0}后"},
}

# Clock patterns for select locales (others get no clock section = digital fallback)
_CLOCK: dict[str, dict] = {
    "en": {
        "hours": ["twelve", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven"],
        "midnight": "midnight",
        "noon": "noon",
        "patterns": {
            "0": "{h} o'clock",
            "5": "five past {h}",
            "10": "ten past {h}",
            "15": "a quarter past {h}",
            "20": "twenty past {h}",
            "25": "twenty-five past {h}",
            "30": "half past {h}",
            "35": "twenty-five to {next_h}",
            "40": "twenty to {next_h}",
            "45": "a quarter to {next_h}",
            "50": "ten to {next_h}",
            "55": "five to {next_h}",
        },
    },
    "de": {
        "hours": ["zwölf", "eins", "zwei", "drei", "vier", "fünf", "sechs", "sieben", "acht", "neun", "zehn", "elf"],
        "midnight": "Mitternacht",
        "noon": "Mittag",
        "patterns": {
            "0": "{h} Uhr",
            "5": "fünf nach {h}",
            "10": "zehn nach {h}",
            "15": "Viertel nach {h}",
            "20": "zwanzig nach {h}",
            "25": "fünf vor halb {next_h}",
            "30": "halb {next_h}",
            "35": "fünf nach halb {next_h}",
            "40": "zwanzig vor {next_h}",
            "45": "Viertel vor {next_h}",
            "50": "zehn vor {next_h}",
            "55": "fünf vor {next_h}",
        },
    },
    "fr": {
        "hours": ["douze", "une", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf", "dix", "onze"],
        "midnight": "minuit",
        "noon": "midi",
        "patterns": {
            "0": "{h} heures",
            "5": "{h} heures cinq",
            "10": "{h} heures dix",
            "15": "{h} heures et quart",
            "20": "{h} heures vingt",
            "25": "{h} heures vingt-cinq",
            "30": "{h} heures et demie",
            "35": "{next_h} heures moins vingt-cinq",
            "40": "{next_h} heures moins vingt",
            "45": "{next_h} heures moins le quart",
            "50": "{next_h} heures moins dix",
            "55": "{next_h} heures moins cinq",
        },
    },
    "es": {
        "hours": ["doce", "una", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve", "diez", "once"],
        "midnight": "medianoche",
        "noon": "mediodía",
        "patterns": {
            "0": "{h} en punto",
            "5": "{h} y cinco",
            "10": "{h} y diez",
            "15": "{h} y cuarto",
            "20": "{h} y veinte",
            "25": "{h} y veinticinco",
            "30": "{h} y media",
            "35": "{next_h} menos veinticinco",
            "40": "{next_h} menos veinte",
            "45": "{next_h} menos cuarto",
            "50": "{next_h} menos diez",
            "55": "{next_h} menos cinco",
        },
    },
    "ja": {
        "hours": ["十二", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一"],
        "midnight": "午前零時",
        "noon": "正午",
        "patterns": {
            "0": "{h}時",
            "5": "{h}時五分",
            "10": "{h}時十分",
            "15": "{h}時十五分",
            "20": "{h}時二十分",
            "25": "{h}時二十五分",
            "30": "{h}時半",
            "35": "{h}時三十五分",
            "40": "{h}時四十分",
            "45": "{h}時四十五分",
            "50": "{h}時五十分",
            "55": "{h}時五十五分",
        },
    },
    "zh": {
        "hours": ["十二", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一"],
        "midnight": "午夜",
        "noon": "中午",
        "patterns": {
            "0": "{h}点整",
            "5": "{h}点零五分",
            "10": "{h}点十分",
            "15": "{h}点十五分",
            "20": "{h}点二十分",
            "25": "{h}点二十五分",
            "30": "{h}点半",
            "35": "{h}点三十五分",
            "40": "{h}点四十分",
            "45": "{h}点四十五分",
            "50": "{h}点五十分",
            "55": "{h}点五十五分",
        },
    },
    "ko": {
        "hours": ["열두", "한", "두", "세", "네", "다섯", "여섯", "일곱", "여덟", "아홉", "열", "열한"],
        "midnight": "자정",
        "noon": "정오",
        "patterns": {
            "0": "{h} 시",
            "5": "{h} 시 오 분",
            "10": "{h} 시 십 분",
            "15": "{h} 시 십오 분",
            "20": "{h} 시 이십 분",
            "25": "{h} 시 이십오 분",
            "30": "{h} 시 반",
            "35": "{h} 시 삼십오 분",
            "40": "{h} 시 사십 분",
            "45": "{h} 시 사십오 분",
            "50": "{h} 시 오십 분",
            "55": "{h} 시 오십오 분",
        },
    },
    "it": {
        "hours": ["dodici", "una", "due", "tre", "quattro", "cinque", "sei", "sette", "otto", "nove", "dieci", "undici"],
        "midnight": "mezzanotte",
        "noon": "mezzogiorno",
        "patterns": {
            "0": "{h}",
            "5": "{h} e cinque",
            "10": "{h} e dieci",
            "15": "{h} e un quarto",
            "20": "{h} e venti",
            "25": "{h} e venticinque",
            "30": "{h} e mezza",
            "35": "{next_h} meno venticinque",
            "40": "{next_h} meno venti",
            "45": "{next_h} meno un quarto",
            "50": "{next_h} meno dieci",
            "55": "{next_h} meno cinque",
        },
    },
    "pt": {
        "hours": ["doze", "uma", "duas", "três", "quatro", "cinco", "seis", "sete", "oito", "nove", "dez", "onze"],
        "midnight": "meia-noite",
        "noon": "meio-dia",
        "patterns": {
            "0": "{h} horas",
            "5": "{h} e cinco",
            "10": "{h} e dez",
            "15": "{h} e um quarto",
            "20": "{h} e vinte",
            "25": "{h} e vinte e cinco",
            "30": "{h} e meia",
            "35": "{next_h} menos vinte e cinco",
            "40": "{next_h} menos vinte",
            "45": "{next_h} menos um quarto",
            "50": "{next_h} menos dez",
            "55": "{next_h} menos cinco",
        },
    },
    "nl": {
        "hours": ["twaalf", "een", "twee", "drie", "vier", "vijf", "zes", "zeven", "acht", "negen", "tien", "elf"],
        "midnight": "middernacht",
        "noon": "twaalf uur 's middags",
        "patterns": {
            "0": "{h} uur",
            "5": "vijf over {h}",
            "10": "tien over {h}",
            "15": "kwart over {h}",
            "20": "tien voor half {next_h}",
            "25": "vijf voor half {next_h}",
            "30": "half {next_h}",
            "35": "vijf over half {next_h}",
            "40": "tien over half {next_h}",
            "45": "kwart voor {next_h}",
            "50": "tien voor {next_h}",
            "55": "vijf voor {next_h}",
        },
    },
}

# CLDR-sourced abbreviations (short = CLDR short width, narrow = CLDR narrow width)
from _cldr_duration_units import CLDR_NARROW, CLDR_SHORT, ENGLISH_SHELLS

# English abbreviations for locales not covered by CLDR
_ENGLISH_ABBREVS = {
    "second": "{n}s",
    "minute": "{n}m",
    "hour": "{n}h",
    "day": "{n}d",
    "week": "{n}w",
    "month": "{n}mo",
    "year": "{n}y",
}

# Compact clock settings for locales that use 24h
_24H_LOCALES = {
    "de", "fr", "es", "it", "pt", "nl", "da", "sv", "nb", "fi",
    "pl", "cs", "sk", "hu", "ro", "bg", "hr", "sr", "sl", "bs",
    "ru", "uk", "el", "tr", "et", "lt", "lv", "ja", "ko", "zh",
    "th", "vi", "id", "ms",
}


def _half_is_compact(half: str) -> bool:
    """True if the half marker is already compact (≤2 non-placeholder chars)."""
    stripped = half.replace("{0}", "").replace("{n}", "").strip()
    return len(stripped) <= 2


def _ensure_other(unit_forms: object) -> object:
    """Ensure dict-form units have an 'other' fallback (copy from 'many' or last)."""
    if isinstance(unit_forms, str):
        return unit_forms
    if "other" in unit_forms:
        return unit_forms
    result = dict(unit_forms)
    result["other"] = unit_forms.get("many", unit_forms.get("few", list(unit_forms.values())[-1]))
    return result


def bootstrap() -> None:
    os.makedirs(TIME_LOCALES, exist_ok=True)

    for fname in sorted(os.listdir(AGE_LOCALES)):
        if not fname.endswith(".json"):
            continue
        code = fname[:-5]

        with open(os.path.join(AGE_LOCALES, fname), encoding="utf-8") as f:
            age_data = json.load(f)

        # Skip en — we hand-wrote it
        if code == "en":
            continue

        time_units = _TIME_UNITS.get(code)
        if not time_units:
            print(f"Warning: no time units for {code}, skipping")
            continue

        relative = _RELATIVE.get(code)
        if not relative:
            print(f"Warning: no relative time for {code}, skipping")
            continue

        locale: dict = {
            "code": code,
            "name": age_data["name"],
            "pluralRule": age_data["pluralRule"],
            "units": {
                "second": _ensure_other(time_units["second"]),
                "minute": _ensure_other(time_units["minute"]),
                "hour": _ensure_other(time_units["hour"]),
                "day": age_data["units"]["day"],
                "week": age_data["units"]["week"],
                "month": age_data["units"]["month"],
                "year": age_data["units"]["year"],
            },
            "half": age_data["half"],
            "delimiter": age_data["delimiter"],
            "justNow": relative["justNow"],
            "ago": relative["ago"],
            "inFuture": relative["inFuture"],
        }

        # Add clock patterns if available
        clock = _CLOCK.get(code)
        if clock:
            locale["clock"] = clock

        # Short override — CLDR "short" width, or English fallback
        short: dict = {}
        if code in CLDR_SHORT:
            short["units"] = CLDR_SHORT[code]
        else:
            short["units"] = _ENGLISH_ABBREVS.copy()
        short["ago"] = relative["ago"]
        short["inFuture"] = relative["inFuture"]
        use24h = code in _24H_LOCALES
        short["clock"] = {"use24h": use24h}
        if not use24h:
            short["clock"]["amPm"] = ["AM", "PM"]
            short["clock"]["format"] = "{h}:{mm} {ampm}"
        else:
            short["clock"]["format"] = "{h}:{mm}"
        locale["short"] = short

        # Compact override — CLDR "narrow" width, or English fallback
        compact: dict = {}
        if code in CLDR_NARROW:
            compact["units"] = CLDR_NARROW[code]
        else:
            compact["units"] = _ENGLISH_ABBREVS.copy()
        compact["delimiter"] = ""
        # Override half marker to {n}½ for verbose locales
        if not _half_is_compact(age_data["half"]):
            compact["half"] = "{n}½"
        compact["ago"] = relative["ago"]
        compact["inFuture"] = relative["inFuture"]
        compact["clock"] = {"use24h": use24h}
        if not use24h:
            compact["clock"]["amPm"] = ["a", "p"]
            compact["clock"]["format"] = "{h}:{mm}{ampm}"
        else:
            compact["clock"]["format"] = "{h}:{mm}"
        locale["compact"] = compact

        out_path = os.path.join(TIME_LOCALES, f"{code}.json")
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(locale, f, ensure_ascii=False, indent=2)
            f.write("\n")

        print(f"  {code}: {age_data['name']}")

    print(f"\nDone. Locale files written to {TIME_LOCALES}/")


if __name__ == "__main__":
    bootstrap()
