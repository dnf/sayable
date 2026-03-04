#!/usr/bin/env python3
"""One-time bootstrap: generate all 71 time locale JSON files.

Reads locale codes/names from age/locales/src/*.json and generates
clock time locale data for each. The 4 existing hand-written locales
(en, de, fr, ja) are overwritten to keep them generated and consistent.

Usage:
    python time/_bootstrap_locales.py
"""

import json
import os

ROOT = os.path.dirname(os.path.abspath(__file__))
AGE_LOCALES = os.path.join(os.path.dirname(ROOT), "age", "locales", "src")
TIME_LOCALES = os.path.join(ROOT, "locales", "src")

# ── Hour word names (0=twelve, 1=one, ..., 11=eleven) ───────────────
# Languages with natural-language hour names for clock reading.
# Languages not listed here use digital-style patterns instead.

_HOURS: dict[str, list[str]] = {
    "en": ["twelve", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven"],
    "de": ["zwölf", "eins", "zwei", "drei", "vier", "fünf", "sechs", "sieben", "acht", "neun", "zehn", "elf"],
    "fr": ["douze", "une", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf", "dix", "onze"],
    "es": ["doce", "una", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve", "diez", "once"],
    "it": ["dodici", "una", "due", "tre", "quattro", "cinque", "sei", "sette", "otto", "nove", "dieci", "undici"],
    "pt": ["doze", "uma", "duas", "três", "quatro", "cinco", "seis", "sete", "oito", "nove", "dez", "onze"],
    "nl": ["twaalf", "een", "twee", "drie", "vier", "vijf", "zes", "zeven", "acht", "negen", "tien", "elf"],
    "da": ["tolv", "et", "to", "tre", "fire", "fem", "seks", "syv", "otte", "ni", "ti", "elleve"],
    "sv": ["tolv", "ett", "två", "tre", "fyra", "fem", "sex", "sju", "åtta", "nio", "tio", "elva"],
    "nb": ["tolv", "en", "to", "tre", "fire", "fem", "seks", "sju", "åtte", "ni", "ti", "elleve"],
    "fi": ["kaksitoista", "yksi", "kaksi", "kolme", "neljä", "viisi", "kuusi", "seitsemän", "kahdeksan", "yhdeksän", "kymmenen", "yksitoista"],
    "pl": ["dwunasta", "pierwsza", "druga", "trzecia", "czwarta", "piąta", "szósta", "siódma", "ósma", "dziewiąta", "dziesiąta", "jedenasta"],
    "cs": ["dvanáct", "jedna", "dvě", "tři", "čtyři", "pět", "šest", "sedm", "osm", "devět", "deset", "jedenáct"],
    "sk": ["dvanásť", "jedna", "dve", "tri", "štyri", "päť", "šesť", "sedem", "osem", "deväť", "desať", "jedenásť"],
    "ru": ["двенадцать", "час", "два", "три", "четыре", "пять", "шесть", "семь", "восемь", "девять", "десять", "одиннадцать"],
    "uk": ["дванадцята", "перша", "друга", "третя", "четверта", "п'ята", "шоста", "сьома", "восьма", "дев'ята", "десята", "одинадцята"],
    "hr": ["dvanaest", "jedan", "dva", "tri", "četiri", "pet", "šest", "sedam", "osam", "devet", "deset", "jedanaest"],
    "sr": ["дванаест", "један", "два", "три", "четири", "пет", "шест", "седам", "осам", "девет", "десет", "једанаест"],
    "bs": ["dvanaest", "jedan", "dva", "tri", "četiri", "pet", "šest", "sedam", "osam", "devet", "deset", "jedanaest"],
    "sl": ["dvanajst", "ena", "dve", "tri", "štiri", "pet", "šest", "sedem", "osem", "devet", "deset", "enajst"],
    "bg": ["дванадесет", "един", "два", "три", "четири", "пет", "шест", "седем", "осем", "девет", "десет", "единадесет"],
    "mk": ["дванаесет", "еден", "два", "три", "четири", "пет", "шест", "седум", "осум", "девет", "десет", "единаесет"],
    "ro": ["douăsprezece", "unu", "două", "trei", "patru", "cinci", "șase", "șapte", "opt", "nouă", "zece", "unsprezece"],
    "hu": ["tizenkettő", "egy", "kettő", "három", "négy", "öt", "hat", "hét", "nyolc", "kilenc", "tíz", "tizenegy"],
    "et": ["kaksteist", "üks", "kaks", "kolm", "neli", "viis", "kuus", "seitse", "kaheksa", "üheksa", "kümme", "üksteist"],
    "lv": ["divpadsmit", "viens", "divi", "trīs", "četri", "pieci", "seši", "septiņi", "astoņi", "deviņi", "desmit", "vienpadsmit"],
    "lt": ["dvylika", "viena", "dvi", "trys", "keturios", "penkios", "šešios", "septynios", "aštuonios", "devynios", "dešimt", "vienuolika"],
    "sq": ["dymbëdhjetë", "një", "dy", "tre", "katër", "pesë", "gjashtë", "shtatë", "tetë", "nëntë", "dhjetë", "njëmbëdhjetë"],
    "el": ["δώδεκα", "μία", "δύο", "τρεις", "τέσσερις", "πέντε", "έξι", "εφτά", "οκτώ", "εννιά", "δέκα", "έντεκα"],
    "tr": ["on iki", "bir", "iki", "üç", "dört", "beş", "altı", "yedi", "sekiz", "dokuz", "on", "on bir"],
    "ca": ["dotze", "una", "dues", "tres", "quatre", "cinc", "sis", "set", "vuit", "nou", "deu", "onze"],
    "eu": ["hamabi", "bat", "bi", "hiru", "lau", "bost", "sei", "zazpi", "zortzi", "bederatzi", "hamar", "hamaika"],
    "ga": ["dó dhéag", "haon", "dó", "trí", "ceathair", "cúig", "sé", "seacht", "hocht", "naoi", "deich", "haon déag"],
    "gd": ["dà-dheug", "aon", "dà", "trì", "ceithir", "còig", "sia", "seachd", "ochd", "naoi", "deich", "aon-deug"],
    "cy": ["deuddeg", "un", "dau", "tri", "pedwar", "pump", "chwech", "saith", "wyth", "naw", "deg", "un ar ddeg"],
    "id": ["dua belas", "satu", "dua", "tiga", "empat", "lima", "enam", "tujuh", "delapan", "sembilan", "sepuluh", "sebelas"],
    "ms": ["dua belas", "satu", "dua", "tiga", "empat", "lima", "enam", "tujuh", "lapan", "sembilan", "sepuluh", "sebelas"],
    "sw": ["kumi na mbili", "moja", "mbili", "tatu", "nne", "tano", "sita", "saba", "nane", "tisa", "kumi", "kumi na moja"],
    "fil": ["dose", "una", "dos", "tres", "kwatro", "singko", "seis", "syete", "otso", "nuwebe", "diyes", "onse"],
    "ja": ["十二", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一"],
    "zh": ["十二", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一"],
    "ko": ["열두", "한", "두", "세", "네", "다섯", "여섯", "일곱", "여덟", "아홉", "열", "열한"],
    "hi": ["बारह", "एक", "दो", "तीन", "चार", "पाँच", "छह", "सात", "आठ", "नौ", "दस", "ग्यारह"],
    "bn": ["বারো", "এক", "দুই", "তিন", "চার", "পাঁচ", "ছয়", "সাত", "আট", "নয়", "দশ", "এগারো"],
    "ta": ["பன்னிரண்டு", "ஒன்று", "இரண்டு", "மூன்று", "நான்கு", "ஐந்து", "ஆறு", "ஏழு", "எட்டு", "ஒன்பது", "பத்து", "பதினொன்று"],
    "te": ["పన్నెండు", "ఒకటి", "రెండు", "మూడు", "నాలుగు", "ఐదు", "ఆరు", "ఏడు", "ఎనిమిది", "తొమ్మిది", "పది", "పదకొండు"],
    "gu": ["બાર", "એક", "બે", "ત્રણ", "ચાર", "પાંચ", "છ", "સાત", "આઠ", "નવ", "દસ", "અગિયાર"],
    "mr": ["बारा", "एक", "दोन", "तीन", "चार", "पाच", "सहा", "सात", "आठ", "नऊ", "दहा", "अकरा"],
    "pa": ["ਬਾਰਾਂ", "ਇੱਕ", "ਦੋ", "ਤਿੰਨ", "ਚਾਰ", "ਪੰਜ", "ਛੇ", "ਸੱਤ", "ਅੱਠ", "ਨੌਂ", "ਦਸ", "ਗਿਆਰਾਂ"],
    "ne": ["बाह्र", "एक", "दुई", "तीन", "चार", "पाँच", "छ", "सात", "आठ", "नौ", "दश", "एघार"],
    "he": ["שתים עשרה", "אחת", "שתיים", "שלוש", "ארבע", "חמש", "שש", "שבע", "שמונה", "תשע", "עשר", "אחת עשרה"],
    "ar": ["الثانية عشرة", "الواحدة", "الثانية", "الثالثة", "الرابعة", "الخامسة", "السادسة", "السابعة", "الثامنة", "التاسعة", "العاشرة", "الحادية عشرة"],
    "fa": ["دوازده", "یک", "دو", "سه", "چهار", "پنج", "شش", "هفت", "هشت", "نه", "ده", "یازده"],
    "ur": ["بارہ", "ایک", "دو", "تین", "چار", "پانچ", "چھ", "سات", "آٹھ", "نو", "دس", "گیارہ"],
    "th": ["สิบสอง", "หนึ่ง", "สอง", "สาม", "สี่", "ห้า", "หก", "เจ็ด", "แปด", "เก้า", "สิบ", "สิบเอ็ด"],
    "vi": ["mười hai", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín", "mười", "mười một"],
    "ka": ["თორმეტი", "ერთი", "ორი", "სამი", "ოთხი", "ხუთი", "ექვსი", "შვიდი", "რვა", "ცხრა", "ათი", "თერთმეტი"],
    "az": ["on iki", "bir", "iki", "üç", "dörd", "beş", "altı", "yeddi", "səkkiz", "doqquz", "on", "on bir"],
    "kk": ["он екі", "бір", "екі", "үш", "төрт", "бес", "алты", "жеті", "сегіз", "тоғыз", "он", "он бір"],
    "uz": ["o'n ikki", "bir", "ikki", "uch", "to'rt", "besh", "olti", "yetti", "sakkiz", "to'qqiz", "o'n", "o'n bir"],
    "jv": ["rolas", "siji", "loro", "telu", "papat", "lima", "enem", "pitu", "wolu", "sanga", "sepuluh", "sewelas"],
    "mt": ["tnax", "waħda", "tnejn", "tlieta", "erbgħa", "ħamsa", "sitta", "sebgħa", "tmienja", "disgħa", "għaxra", "ħdax"],
    "km": ["ដប់ពីរ", "មួយ", "ពីរ", "បី", "បួន", "ប្រាំ", "ប្រាំមួយ", "ប្រាំពីរ", "ប្រាំបី", "ប្រាំបួន", "ដប់", "ដប់មួយ"],
    "my": ["ဆယ့်နှစ်", "တစ်", "နှစ်", "သုံး", "လေး", "ငါး", "ခြောက်", "ခုနစ်", "ရှစ်", "ကိုး", "ဆယ်", "ဆယ့်တစ်"],
    "si": ["දොළහ", "එක", "දෙක", "තුන", "හතර", "පහ", "හය", "හත", "අට", "නවය", "දහය", "එකොළහ"],
    "am": ["አሥራ ሁለት", "አንድ", "ሁለት", "ሦስት", "አራት", "አምስት", "ስድስት", "ሰባት", "ስምንት", "ዘጠኝ", "አሥር", "አሥራ አንድ"],
}

# ── Midnight / noon translations ─────────────────────────────────────

_MIDNIGHT_NOON: dict[str, tuple[str, str]] = {
    "en": ("midnight", "noon"),
    "de": ("Mitternacht", "Mittag"),
    "fr": ("minuit", "midi"),
    "es": ("medianoche", "mediodía"),
    "it": ("mezzanotte", "mezzogiorno"),
    "pt": ("meia-noite", "meio-dia"),
    "nl": ("middernacht", "middag"),
    "da": ("midnat", "middag"),
    "sv": ("midnatt", "middag"),
    "nb": ("midnatt", "middag"),
    "fi": ("keskiyö", "keskipäivä"),
    "pl": ("północ", "południe"),
    "cs": ("půlnoc", "poledne"),
    "sk": ("polnoc", "poludnie"),
    "ru": ("полночь", "полдень"),
    "uk": ("опівніч", "полудень"),
    "hr": ("ponoć", "podne"),
    "sr": ("поноћ", "подне"),
    "bs": ("ponoć", "podne"),
    "sl": ("polnoč", "poldne"),
    "bg": ("полунощ", "обяд"),
    "mk": ("полноќ", "пладне"),
    "ro": ("miezul nopții", "amiază"),
    "hu": ("éjfél", "dél"),
    "et": ("kesköö", "keskpäev"),
    "lv": ("pusnakts", "pusdiena"),
    "lt": ("vidurnaktis", "vidurdienis"),
    "sq": ("mesnata", "mesdita"),
    "el": ("μεσάνυχτα", "μεσημέρι"),
    "tr": ("gece yarısı", "öğle"),
    "ca": ("mitjanit", "migdia"),
    "eu": ("gauerdia", "eguerdia"),
    "ga": ("meán oíche", "meán lae"),
    "gd": ("meadhan-oidhche", "meadhan-latha"),
    "cy": ("hanner nos", "hanner dydd"),
    "id": ("tengah malam", "tengah hari"),
    "ms": ("tengah malam", "tengah hari"),
    "sw": ("usiku wa manane", "adhuhuri"),
    "fil": ("hatinggabi", "tanghali"),
    "ja": ("午前零時", "正午"),
    "zh": ("午夜", "正午"),
    "ko": ("자정", "정오"),
    "hi": ("आधी रात", "दोपहर"),
    "bn": ("মধ্যরাত", "দুপুর"),
    "ta": ("நள்ளிரவு", "நண்பகல்"),
    "te": ("అర్ధరాత్రి", "మధ్యాహ్నం"),
    "gu": ("મધ્યરાત્રિ", "બપોર"),
    "mr": ("मध्यरात्र", "दुपार"),
    "pa": ("ਅੱਧੀ ਰਾਤ", "ਦੁਪਹਿਰ"),
    "ne": ("मध्यरात", "मध्यान्ह"),
    "he": ("חצות", "צהריים"),
    "ar": ("منتصف الليل", "الظهر"),
    "fa": ("نیمه‌شب", "ظهر"),
    "ur": ("آدھی رات", "دوپہر"),
    "th": ("เที่ยงคืน", "เที่ยงวัน"),
    "vi": ("nửa đêm", "trưa"),
    "ka": ("შუაღამე", "შუადღე"),
    "az": ("gecə yarısı", "günorta"),
    "kk": ("түн ортасы", "түс"),
    "uz": ("yarim tun", "tush"),
    "jv": ("tengah wengi", "awan"),
    "mt": ("nofsinhar", "nofsinhar"),
    "km": ("កណ្ដាលអធ្រាត្រ", "ថ្ងៃត្រង់"),
    "my": ("သန်းခေါင်", "မွန်းတည့်"),
    "si": ("මධ්‍යම රාත්‍රිය", "මධ්‍යාහ්නය"),
    "am": ("እኩለ ሌሊት", "እኩለ ቀን"),
    "br": ("hanternoz", "kreisteiz"),
    "gv": ("mean oie", "munlaa"),
    "kw": ("hanter nos", "hanter dydh"),
    "shi": ("ⵏⵚ ⵏ ⵉⴹ", "ⵜⵉⵣⵡⴰⵔⵏⵉⵏ"),
    "tzm": ("ⵏⵚ ⵏ ⵉⴹ", "ⵜⵉⵣⵡⴰⵔⵏⵉⵏ"),
}

# ── Clock pattern families ───────────────────────────────────────────
# Each family defines how clock patterns are structured.
# Languages not listed default to digital-only (no natural patterns).

# "past/to" family: "X past H" / "X to next_H" (like English)
_PAST_TO = {
    "5": ("five", "cinq", "cinco"), "10": ("ten", "dix", "diez"),
    "15": ("quarter", "quart", "cuarto"), "20": ("twenty", "vingt", "veinte"),
    "25": ("twenty-five", "vingt-cinq", "veinticinco"),
    "30": ("half", "demie", "media"),
}

# Minute words per language for building patterns
_MINUTE_WORDS: dict[str, dict[str, str]] = {
    "en": {"5": "five", "10": "ten", "15": "a quarter", "20": "twenty", "25": "twenty-five", "30": "half"},
    "de": {"5": "fünf", "10": "zehn", "15": "Viertel", "20": "zwanzig", "25": "fünf vor halb", "30": "halb"},
    "fr": {"5": "cinq", "10": "dix", "15": "et quart", "20": "vingt", "25": "vingt-cinq", "30": "et demie"},
    "es": {"5": "cinco", "10": "diez", "15": "cuarto", "20": "veinte", "25": "veinticinco", "30": "media"},
    "it": {"5": "cinque", "10": "dieci", "15": "un quarto", "20": "venti", "25": "venticinque", "30": "mezza"},
    "pt": {"5": "cinco", "10": "dez", "15": "um quarto", "20": "vinte", "25": "vinte e cinco", "30": "meia"},
    "nl": {"5": "vijf", "10": "tien", "15": "kwart", "20": "twintig", "25": "vijf voor half", "30": "half"},
    "da": {"5": "fem", "10": "ti", "15": "kvart", "20": "tyve", "25": "fem i halv", "30": "halv"},
    "sv": {"5": "fem", "10": "tio", "15": "kvart", "20": "tjugo", "25": "fem i halv", "30": "halv"},
    "nb": {"5": "fem", "10": "ti", "15": "kvart", "20": "tjue", "25": "fem på halv", "30": "halv"},
    "pl": {"5": "pięć", "10": "dziesięć", "15": "piętnaście", "20": "dwadzieścia", "25": "dwadzieścia pięć", "30": "trzydzieści"},
    "cs": {"5": "pět", "10": "deset", "15": "čtvrt", "20": "dvacet", "25": "dvacet pět", "30": "půl"},
    "sk": {"5": "päť", "10": "desať", "15": "štvrť", "20": "dvadsať", "25": "dvadsať päť", "30": "pol"},
    "ro": {"5": "cinci", "10": "zece", "15": "un sfert", "20": "douăzeci", "25": "douăzeci și cinci", "30": "jumătate"},
    "hu": {"5": "öt", "10": "tíz", "15": "negyed", "20": "húsz", "25": "huszonöt", "30": "fél"},
    "el": {"5": "πέντε", "10": "δέκα", "15": "τέταρτο", "20": "είκοσι", "25": "είκοσι πέντε", "30": "μισή"},
    "tr": {"5": "beş", "10": "on", "15": "çeyrek", "20": "yirmi", "25": "yirmi beş", "30": "buçuk"},
    "ca": {"5": "cinc", "10": "deu", "15": "un quart", "20": "vint", "25": "vint-i-cinc", "30": "mitja"},
    "sq": {"5": "pesë", "10": "dhjetë", "15": "një çerek", "20": "njëzet", "25": "njëzet e pesë", "30": "gjysma"},
    "hr": {"5": "pet", "10": "deset", "15": "petnaest", "20": "dvadeset", "25": "dvadeset pet", "30": "trideset"},
    "sr": {"5": "пет", "10": "десет", "15": "петнаест", "20": "двадесет", "25": "двадесет пет", "30": "тридесет"},
    "bs": {"5": "pet", "10": "deset", "15": "petnaest", "20": "dvadeset", "25": "dvadeset pet", "30": "trideset"},
    "sl": {"5": "pet", "10": "deset", "15": "petnajst", "20": "dvajset", "25": "dvajset pet", "30": "trideset"},
    "bg": {"5": "пет", "10": "десет", "15": "петнадесет", "20": "двадесет", "25": "двадесет и пет", "30": "тридесет"},
    "mk": {"5": "пет", "10": "десет", "15": "петнаесет", "20": "дваесет", "25": "дваесет и пет", "30": "триесет"},
    "ru": {"5": "пять", "10": "десять", "15": "пятнадцать", "20": "двадцать", "25": "двадцать пять", "30": "тридцать"},
    "uk": {"5": "п'ять", "10": "десять", "15": "п'ятнадцять", "20": "двадцять", "25": "двадцять п'ять", "30": "тридцять"},
    "et": {"5": "viis", "10": "kümme", "15": "veerand", "20": "kakskümmend", "25": "kakskümmend viis", "30": "pool"},
    "lv": {"5": "pieci", "10": "desmit", "15": "piecpadsmit", "20": "divdesmit", "25": "divdesmit pieci", "30": "trīsdesmit"},
    "lt": {"5": "penkios", "10": "dešimt", "15": "penkiolika", "20": "dvidešimt", "25": "dvidešimt penkios", "30": "trisdešimt"},
    "fi": {"5": "viisi", "10": "kymmenen", "15": "vartti", "20": "kaksikymmentä", "25": "kaksikymmentäviisi", "30": "puoli"},
    "id": {"5": "lima", "10": "sepuluh", "15": "seperempat", "20": "dua puluh", "25": "dua puluh lima", "30": "setengah"},
    "ms": {"5": "lima", "10": "sepuluh", "15": "suku", "20": "dua puluh", "25": "dua puluh lima", "30": "setengah"},
    "sw": {"5": "tano", "10": "kumi", "15": "robo", "20": "ishirini", "25": "ishirini na tano", "30": "nusu"},
    "fil": {"5": "lima", "10": "sampu", "15": "labinlima", "20": "dalawampu", "25": "dalawampu't lima", "30": "tatlumpu"},
    "vi": {"5": "năm", "10": "mười", "15": "mười lăm", "20": "hai mươi", "25": "hai mươi lăm", "30": "ba mươi"},
    "az": {"5": "beş", "10": "on", "15": "on beş", "20": "iyirmi", "25": "iyirmi beş", "30": "otuz"},
    "kk": {"5": "бес", "10": "он", "15": "он бес", "20": "жиырма", "25": "жиырма бес", "30": "отыз"},
    "uz": {"5": "besh", "10": "o'n", "15": "o'n besh", "20": "yigirma", "25": "yigirma besh", "30": "o'ttiz"},
    "ka": {"5": "ხუთი", "10": "ათი", "15": "თხუთმეტი", "20": "ოცი", "25": "ოცდახუთი", "30": "ოცდაათი"},
    "he": {"5": "חמש", "10": "עשר", "15": "רבע", "20": "עשרים", "25": "עשרים וחמש", "30": "חצי"},
    "fa": {"5": "پنج", "10": "ده", "15": "ربع", "20": "بیست", "25": "بیست و پنج", "30": "نیم"},
}

# ── Pattern templates by language family ─────────────────────────────

def _make_past_to_patterns(code: str, mw: dict[str, str]) -> dict[str, str]:
    """Generate past/to patterns for languages using that structure."""
    h = "{h}"
    nh = "{next_h}"
    if code == "de":
        return {
            "0": f"{h} Uhr", "5": f"fünf nach {h}", "10": f"zehn nach {h}",
            "15": f"Viertel nach {h}", "20": f"zwanzig nach {h}", "25": f"fünf vor halb {nh}",
            "30": f"halb {nh}", "35": f"fünf nach halb {nh}", "40": f"zwanzig vor {nh}",
            "45": f"Viertel vor {nh}", "50": f"zehn vor {nh}", "55": f"fünf vor {nh}",
        }
    if code == "fr":
        return {
            "0": f"{h} heures", "5": f"{h} heures cinq", "10": f"{h} heures dix",
            "15": f"{h} heures et quart", "20": f"{h} heures vingt", "25": f"{h} heures vingt-cinq",
            "30": f"{h} heures et demie", "35": f"{h} heures trente-cinq", "40": f"{h} heures quarante",
            "45": f"{h} heures moins le quart", "50": f"{h} heures cinquante", "55": f"{h} heures cinquante-cinq",
        }
    if code in ("es",):
        return {
            "0": f"{h} en punto", "5": f"{h} y {mw['5']}", "10": f"{h} y {mw['10']}",
            "15": f"{h} y {mw['15']}", "20": f"{h} y {mw['20']}", "25": f"{h} y {mw['25']}",
            "30": f"{h} y {mw['30']}", "35": f"{nh} menos {mw['25']}", "40": f"{nh} menos {mw['20']}",
            "45": f"{nh} menos {mw['15']}", "50": f"{nh} menos {mw['10']}", "55": f"{nh} menos {mw['5']}",
        }
    if code in ("it",):
        return {
            "0": f"le {h}", "5": f"{h} e {mw['5']}", "10": f"{h} e {mw['10']}",
            "15": f"{h} e {mw['15']}", "20": f"{h} e {mw['20']}", "25": f"{h} e {mw['25']}",
            "30": f"{h} e {mw['30']}", "35": f"{nh} meno {mw['25']}", "40": f"{nh} meno {mw['20']}",
            "45": f"{nh} meno {mw['15']}", "50": f"{nh} meno {mw['10']}", "55": f"{nh} meno {mw['5']}",
        }
    if code in ("pt",):
        return {
            "0": f"{h} horas", "5": f"{h} e {mw['5']}", "10": f"{h} e {mw['10']}",
            "15": f"{h} e {mw['15']}", "20": f"{h} e {mw['20']}", "25": f"{h} e {mw['25']}",
            "30": f"{h} e {mw['30']}", "35": f"{mw['25']} para as {nh}", "40": f"{mw['20']} para as {nh}",
            "45": f"{mw['15']} para as {nh}", "50": f"{mw['10']} para as {nh}", "55": f"{mw['5']} para as {nh}",
        }
    if code in ("nl",):
        return {
            "0": f"{h} uur", "5": f"{mw['5']} over {h}", "10": f"{mw['10']} over {h}",
            "15": f"{mw['15']} over {h}", "20": f"{mw['20']} over {h}", "25": f"{mw['25']} {nh}",
            "30": f"{mw['30']} {nh}", "35": f"{mw['5']} over half {nh}", "40": f"{mw['20']} voor {nh}",
            "45": f"{mw['15']} voor {nh}", "50": f"{mw['10']} voor {nh}", "55": f"{mw['5']} voor {nh}",
        }
    if code in ("da",):
        return {
            "0": f"klokken {h}", "5": f"{mw['5']} over {h}", "10": f"{mw['10']} over {h}",
            "15": f"{mw['15']} over {h}", "20": f"{mw['20']} over {h}", "25": f"{mw['25']} {nh}",
            "30": f"{mw['30']} {nh}", "35": f"{mw['5']} over halv {nh}", "40": f"{mw['20']} i {nh}",
            "45": f"{mw['15']} i {nh}", "50": f"{mw['10']} i {nh}", "55": f"{mw['5']} i {nh}",
        }
    if code in ("sv",):
        return {
            "0": f"klockan {h}", "5": f"{mw['5']} över {h}", "10": f"{mw['10']} över {h}",
            "15": f"{mw['15']} över {h}", "20": f"{mw['20']} över {h}", "25": f"{mw['25']} {nh}",
            "30": f"{mw['30']} {nh}", "35": f"{mw['5']} över halv {nh}", "40": f"{mw['20']} i {nh}",
            "45": f"{mw['15']} i {nh}", "50": f"{mw['10']} i {nh}", "55": f"{mw['5']} i {nh}",
        }
    if code in ("nb",):
        return {
            "0": f"klokka {h}", "5": f"{mw['5']} over {h}", "10": f"{mw['10']} over {h}",
            "15": f"{mw['15']} over {h}", "20": f"{mw['20']} over {h}", "25": f"{mw['25']} {nh}",
            "30": f"{mw['30']} {nh}", "35": f"{mw['5']} over halv {nh}", "40": f"{mw['20']} på {nh}",
            "45": f"{mw['15']} på {nh}", "50": f"{mw['10']} på {nh}", "55": f"{mw['5']} på {nh}",
        }
    if code in ("tr",):
        return {
            "0": f"saat {h}", "5": f"{h}'i {mw['5']} geçiyor", "10": f"{h}'i {mw['10']} geçiyor",
            "15": f"{h}'i {mw['15']} geçiyor", "20": f"{h}'i {mw['20']} geçiyor", "25": f"{h}'i {mw['25']} geçiyor",
            "30": f"{h} {mw['30']}", "35": f"{nh}'e {mw['25']} var", "40": f"{nh}'e {mw['20']} var",
            "45": f"{nh}'e {mw['15']} var", "50": f"{nh}'e {mw['10']} var", "55": f"{nh}'e {mw['5']} var",
        }
    if code in ("el",):
        return {
            "0": f"{h} η ώρα", "5": f"{h} και {mw['5']}", "10": f"{h} και {mw['10']}",
            "15": f"{h} και {mw['15']}", "20": f"{h} και {mw['20']}", "25": f"{h} και {mw['25']}",
            "30": f"{h} και {mw['30']}", "35": f"{nh} παρά {mw['25']}", "40": f"{nh} παρά {mw['20']}",
            "45": f"{nh} παρά {mw['15']}", "50": f"{nh} παρά {mw['10']}", "55": f"{nh} παρά {mw['5']}",
        }
    if code in ("he",):
        return {
            "0": f"השעה {h}", "5": f"{h} ו{mw['5']}", "10": f"{h} ו{mw['10']}",
            "15": f"{h} ו{mw['15']}", "20": f"{h} ו{mw['20']}", "25": f"{h} ו{mw['25']}",
            "30": f"{h} ו{mw['30']}", "35": f"{mw['25']} ל{nh}", "40": f"{mw['20']} ל{nh}",
            "45": f"{mw['15']} ל{nh}", "50": f"{mw['10']} ל{nh}", "55": f"{mw['5']} ל{nh}",
        }
    if code in ("fa",):
        return {
            "0": f"ساعت {h}", "5": f"{h} و {mw['5']} دقیقه", "10": f"{h} و {mw['10']} دقیقه",
            "15": f"{h} و {mw['15']}", "20": f"{h} و {mw['20']} دقیقه", "25": f"{h} و {mw['25']} دقیقه",
            "30": f"{h} و {mw['30']}", "35": f"{mw['25']} دقیقه به {nh}", "40": f"{mw['20']} دقیقه به {nh}",
            "45": f"{mw['15']} به {nh}", "50": f"{mw['10']} دقیقه به {nh}", "55": f"{mw['5']} دقیقه به {nh}",
        }
    # Default "past/to" pattern for most languages
    past = "past" if code == "en" else "po" if code in ("cs", "sk") else "na" if code in ("bg",) else "lewat" if code in ("id", "ms") else "kupita" if code == "sw" else "qua" if code == "vi" else "keçir" if code == "az" else "dan" if code == "fil" else "efter" if code == "et" else "pēc" if code == "lv" else "po" if code in ("pl", "sl", "hr", "bs", "sr", "mk", "ru", "uk") else "peste" if code == "ro" else "múlt" if code == "hu" else "yli" if code == "fi" else "minuta" if code in ("lt",) else "wedi" if code == "cy" else "past"
    to = "to" if code == "en" else "do" if code in ("cs", "sk", "pl", "sl") else "do" if code in ("hr", "bs", "sr", "mk", "ru", "uk", "bg") else "menjelang" if code in ("id", "ms") else "kabla ya" if code == "sw" else "trước" if code == "vi" else "qalmış" if code == "az" else "bago mag" if code == "fil" else "enne" if code == "et" else "līdz" if code == "lv" else "iki" if code == "lt" else "înainte de" if code == "ro" else "múlva" if code == "hu" else "vaille" if code == "fi" else "i" if code == "cy" else "to"
    oclock = "o'clock" if code == "en" else "hodin" if code in ("cs",) else "hodín" if code == "sk" else "ura" if code in ("sl",) else "sati" if code in ("hr", "bs") else "часа" if code in ("sr",) else "часа" if code in ("bg", "ru", "uk", "mk") else "ore" if code == "ro" else "óra" if code == "hu" else "" if code in ("fi", "et", "lv", "lt", "pl") else "o'r gloch" if code == "cy" else "o'clock"

    return {
        "0": f"{h} {oclock}".strip() if oclock else h,
        "5": f"{mw['5']} {past} {h}", "10": f"{mw['10']} {past} {h}",
        "15": f"{mw['15']} {past} {h}", "20": f"{mw['20']} {past} {h}",
        "25": f"{mw['25']} {past} {h}", "30": f"{mw['30']} {past} {h}",
        "35": f"{mw['25']} {to} {nh}", "40": f"{mw['20']} {to} {nh}",
        "45": f"{mw['15']} {to} {nh}", "50": f"{mw['10']} {to} {nh}",
        "55": f"{mw['5']} {to} {nh}",
    }


def _make_suffix_patterns(code: str) -> dict[str, str]:
    """Generate patterns for languages that use H時M分 structure (CJK etc.)."""
    h = "{h}"
    if code == "ja":
        return {
            "0": f"{h}時", "5": f"{h}時五分", "10": f"{h}時十分", "15": f"{h}時十五分",
            "20": f"{h}時二十分", "25": f"{h}時二十五分", "30": f"{h}時半",
            "35": f"{h}時三十五分", "40": f"{h}時四十分", "45": f"{h}時四十五分",
            "50": f"{h}時五十分", "55": f"{h}時五十五分",
        }
    if code == "zh":
        return {
            "0": f"{h}点整", "5": f"{h}点五分", "10": f"{h}点十分", "15": f"{h}点十五分",
            "20": f"{h}点二十分", "25": f"{h}点二十五分", "30": f"{h}点半",
            "35": f"{h}点三十五分", "40": f"{h}点四十分", "45": f"{h}点四十五分",
            "50": f"{h}点五十分", "55": f"{h}点五十五分",
        }
    if code == "ko":
        return {
            "0": f"{h} 시", "5": f"{h} 시 오 분", "10": f"{h} 시 십 분", "15": f"{h} 시 십오 분",
            "20": f"{h} 시 이십 분", "25": f"{h} 시 이십오 분", "30": f"{h} 시 반",
            "35": f"{h} 시 삼십오 분", "40": f"{h} 시 사십 분", "45": f"{h} 시 사십오 분",
            "50": f"{h} 시 오십 분", "55": f"{h} 시 오십오 분",
        }
    if code == "th":
        return {
            "0": f"{h} นาฬิกา", "5": f"{h} นาฬิกา ห้านาที", "10": f"{h} นาฬิกา สิบนาที",
            "15": f"{h} นาฬิกา สิบห้านาที", "20": f"{h} นาฬิกา ยี่สิบนาที",
            "25": f"{h} นาฬิกา ยี่สิบห้านาที", "30": f"{h} นาฬิกา ครึ่ง",
            "35": f"{h} นาฬิกา สามสิบห้านาที", "40": f"{h} นาฬิกา สี่สิบนาที",
            "45": f"{h} นาฬิกา สี่สิบห้านาที", "50": f"{h} นาฬิกา ห้าสิบนาที",
            "55": f"{h} นาฬิกา ห้าสิบห้านาที",
        }
    return {}


def _make_digital_patterns(h: str = "{h}") -> dict[str, str]:
    """Simple H:MM digital-style patterns for languages without natural clock reading."""
    return {
        "0": f"{h}:00", "5": f"{h}:05", "10": f"{h}:10", "15": f"{h}:15",
        "20": f"{h}:20", "25": f"{h}:25", "30": f"{h}:30",
        "35": f"{h}:35", "40": f"{h}:40", "45": f"{h}:45",
        "50": f"{h}:50", "55": f"{h}:55",
    }


# Locales that use 24-hour clock in short/compact mode
_24H_LOCALES = {
    "de", "fr", "es", "it", "pt", "nl", "da", "sv", "nb", "fi",
    "pl", "cs", "sk", "ru", "uk", "hr", "sr", "bs", "sl", "bg",
    "mk", "ro", "hu", "et", "lv", "lt", "sq", "el", "tr", "ca",
    "eu", "ga", "gd", "cy", "br", "gv", "kw",
    "ja", "zh", "ko", "vi", "th",
    "id", "ms", "jv", "sw",
    "ka", "az", "kk", "uz",
    "mt",
    "he", "fa",
    "am", "km", "my", "si",
    "shi", "tzm",
}


def get_patterns(code: str) -> dict[str, str] | None:
    """Get clock patterns for a locale. Returns None if digital-only."""
    # CJK/suffix-style
    if code in ("ja", "zh", "ko", "th"):
        return _make_suffix_patterns(code)

    # Languages with minute-word data → past/to patterns
    if code in _MINUTE_WORDS:
        return _make_past_to_patterns(code, _MINUTE_WORDS[code])

    # Languages with hour names but no minute words → they still get
    # natural patterns using their numerals in digital style within pattern
    return None


def build_locale(code: str, name: str) -> dict:
    """Build a complete time locale dict."""
    midnight, noon = _MIDNIGHT_NOON.get(code, ("midnight", "noon"))
    hours = _HOURS.get(code)
    patterns = get_patterns(code)

    locale: dict = {"code": code, "name": name}

    if hours and patterns:
        locale["clock"] = {
            "hours": hours,
            "midnight": midnight,
            "noon": noon,
            "patterns": patterns,
        }
    else:
        # Digital-only: use positional hour names as digit strings
        locale["clock"] = {
            "hours": hours if hours else [str(i) for i in [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]],
            "midnight": midnight,
            "noon": noon,
            "patterns": _make_digital_patterns("{h}"),
        }

    use24h = code in _24H_LOCALES

    if use24h:
        locale["short"] = {"clock": {"use24h": True, "format": "{h}:{mm}"}}
        # Some languages use special compact formats
        if code == "fr":
            locale["compact"] = {"clock": {"use24h": True, "format": "{h}h{mm}"}}
        else:
            locale["compact"] = {"clock": {"use24h": True, "format": "{h}:{mm}"}}
    else:
        locale["short"] = {"clock": {"use24h": False, "amPm": ["AM", "PM"], "format": "{h}:{mm} {ampm}"}}
        locale["compact"] = {"clock": {"use24h": False, "amPm": ["a", "p"], "format": "{h}:{mm}{ampm}"}}

    return locale


def main() -> None:
    os.makedirs(TIME_LOCALES, exist_ok=True)

    age_locales = []
    for fname in sorted(os.listdir(AGE_LOCALES)):
        if not fname.endswith(".json"):
            continue
        with open(os.path.join(AGE_LOCALES, fname), encoding="utf-8") as f:
            data = json.load(f)
            age_locales.append((data["code"], data["name"]))

    generated = 0
    for code, name in age_locales:
        locale = build_locale(code, name)
        out = os.path.join(TIME_LOCALES, f"{code}.json")
        with open(out, "w", encoding="utf-8") as f:
            json.dump(locale, f, ensure_ascii=False, indent=2)
            f.write("\n")
        generated += 1

    print(f"Generated {generated} locale files")


if __name__ == "__main__":
    main()
