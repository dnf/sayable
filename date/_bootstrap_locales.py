#!/usr/bin/env python3
"""One-time bootstrap: generate all 71 date locale JSON files.

Reads locale codes/names from age/locales/src/*.json and adds
CLDR-sourced month names, weekday names, ordinals, date patterns,
and relative date terms for each locale.

Usage:
    python date/_bootstrap_locales.py
"""

import json
import os

ROOT = os.path.dirname(os.path.abspath(__file__))
AGE_LOCALES = os.path.join(os.path.dirname(ROOT), "age", "locales", "src")
DATE_LOCALES = os.path.join(ROOT, "locales", "src")

# ── Month names (full) ───────────────────────────────────────────────

_MONTHS: dict[str, list[str]] = {
    "am": ["ጃንዋሪ", "ፌብሩወሪ", "ማርች", "ኤፕሪል", "ሜይ", "ጁን", "ጁላይ", "ኦገስት", "ሴፕቴምበር", "ኦክቶበር", "ኖቬምበር", "ዲሴምበር"],
    "ar": ["يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو", "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"],
    "az": ["yanvar", "fevral", "mart", "aprel", "may", "iyun", "iyul", "avqust", "sentyabr", "oktyabr", "noyabr", "dekabr"],
    "bg": ["януари", "февруари", "март", "април", "май", "юни", "юли", "август", "септември", "октомври", "ноември", "декември"],
    "bn": ["জানুয়ারি", "ফেব্রুয়ারি", "মার্চ", "এপ্রিল", "মে", "জুন", "জুলাই", "আগস্ট", "সেপ্টেম্বর", "অক্টোবর", "নভেম্বর", "ডিসেম্বর"],
    "br": ["Genver", "C'hwevrer", "Meurzh", "Ebrel", "Mae", "Mezheven", "Gouere", "Eost", "Gwengolo", "Here", "Du", "Kerzu"],
    "bs": ["januar", "februar", "mart", "april", "maj", "juni", "juli", "august", "septembar", "oktobar", "novembar", "decembar"],
    "ca": ["gener", "febrer", "març", "abril", "maig", "juny", "juliol", "agost", "setembre", "octubre", "novembre", "desembre"],
    "cs": ["leden", "únor", "březen", "duben", "květen", "červen", "červenec", "srpen", "září", "říjen", "listopad", "prosinec"],
    "cy": ["Ionawr", "Chwefror", "Mawrth", "Ebrill", "Mai", "Mehefin", "Gorffennaf", "Awst", "Medi", "Hydref", "Tachwedd", "Rhagfyr"],
    "da": ["januar", "februar", "marts", "april", "maj", "juni", "juli", "august", "september", "oktober", "november", "december"],
    "de": ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"],
    "el": ["Ιανουαρίου", "Φεβρουαρίου", "Μαρτίου", "Απριλίου", "Μαΐου", "Ιουνίου", "Ιουλίου", "Αυγούστου", "Σεπτεμβρίου", "Οκτωβρίου", "Νοεμβρίου", "Δεκεμβρίου"],
    "en": ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
    "es": ["enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"],
    "et": ["jaanuar", "veebruar", "märts", "aprill", "mai", "juuni", "juuli", "august", "september", "oktoober", "november", "detsember"],
    "eu": ["urtarril", "otsail", "martxo", "apiril", "maiatz", "ekain", "uztail", "abuztu", "irail", "urri", "azaro", "abendu"],
    "fa": ["ژانویه", "فوریه", "مارس", "آوریل", "مه", "ژوئن", "ژوئیه", "اوت", "سپتامبر", "اکتبر", "نوامبر", "دسامبر"],
    "fi": ["tammikuu", "helmikuu", "maaliskuu", "huhtikuu", "toukokuu", "kesäkuu", "heinäkuu", "elokuu", "syyskuu", "lokakuu", "marraskuu", "joulukuu"],
    "fil": ["Enero", "Pebrero", "Marso", "Abril", "Mayo", "Hunyo", "Hulyo", "Agosto", "Setyembre", "Oktubre", "Nobyembre", "Disyembre"],
    "fr": ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"],
    "ga": ["Eanáir", "Feabhra", "Márta", "Aibreán", "Bealtaine", "Meitheamh", "Iúil", "Lúnasa", "Meán Fómhair", "Deireadh Fómhair", "Samhain", "Nollaig"],
    "gd": ["Am Faoilleach", "An Gearran", "Am Màrt", "An Giblean", "An Cèitean", "An t-Ògmhios", "An t-Iuchar", "An Lùnastal", "An t-Sultain", "An Dàmhair", "An t-Samhain", "An Dùbhlachd"],
    "gu": ["જાન્યુઆરી", "ફેબ્રુઆરી", "માર્ચ", "એપ્રિલ", "મે", "જૂન", "જુલાઈ", "ઑગસ્ટ", "સપ્ટેમ્બર", "ઑક્ટોબર", "નવેમ્બર", "ડિસેમ્બર"],
    "gv": ["Jerrey Geuree", "Toshiaght Arree", "Mayrnt", "Averil", "Boaldyn", "Mean Souree", "Jerrey Souree", "Luanistyn", "Mean Fouyir", "Jerrey Fouyir", "Mee Houney", "Mee ny Nollick"],
    "he": ["ינואר", "פברואר", "מרץ", "אפריל", "מאי", "יוני", "יולי", "אוגוסט", "ספטמבר", "אוקטובר", "נובמבר", "דצמבר"],
    "hi": ["जनवरी", "फ़रवरी", "मार्च", "अप्रैल", "मई", "जून", "जुलाई", "अगस्त", "सितंबर", "अक्तूबर", "नवंबर", "दिसंबर"],
    "hr": ["siječanj", "veljača", "ožujak", "travanj", "svibanj", "lipanj", "srpanj", "kolovoz", "rujan", "listopad", "studeni", "prosinac"],
    "hu": ["január", "február", "március", "április", "május", "június", "július", "augusztus", "szeptember", "október", "november", "december"],
    "id": ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"],
    "it": ["gennaio", "febbraio", "marzo", "aprile", "maggio", "giugno", "luglio", "agosto", "settembre", "ottobre", "novembre", "dicembre"],
    "ja": ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
    "jv": ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"],
    "ka": ["იანვარი", "თებერვალი", "მარტი", "აპრილი", "მაისი", "ივნისი", "ივლისი", "აგვისტო", "სექტემბერი", "ოქტომბერი", "ნოემბერი", "დეკემბერი"],
    "kk": ["қаңтар", "ақпан", "наурыз", "сәуір", "мамыр", "маусым", "шілде", "тамыз", "қыркүйек", "қазан", "қараша", "желтоқсан"],
    "km": ["មករា", "កុម្ភៈ", "មីនា", "មេសា", "ឧសភា", "មិថុនា", "កក្កដា", "សីហា", "កញ្ញា", "តុលា", "វិច្ឆិកា", "ធ្នូ"],
    "ko": ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"],
    "kw": ["Genver", "Hwevrer", "Meurth", "Ebrel", "Me", "Metheven", "Gortheren", "Est", "Gwynngala", "Hedra", "Du", "Kevardhu"],
    "lt": ["sausis", "vasaris", "kovas", "balandis", "gegužė", "birželis", "liepa", "rugpjūtis", "rugsėjis", "spalis", "lapkritis", "gruodis"],
    "lv": ["janvāris", "februāris", "marts", "aprīlis", "maijs", "jūnijs", "jūlijs", "augusts", "septembris", "oktobris", "novembris", "decembris"],
    "mk": ["јануари", "февруари", "март", "април", "мај", "јуни", "јули", "август", "септември", "октомври", "ноември", "декември"],
    "mr": ["जानेवारी", "फेब्रुवारी", "मार्च", "एप्रिल", "मे", "जून", "जुलै", "ऑगस्ट", "सप्टेंबर", "ऑक्टोबर", "नोव्हेंबर", "डिसेंबर"],
    "ms": ["Januari", "Februari", "Mac", "April", "Mei", "Jun", "Julai", "Ogos", "September", "Oktober", "November", "Disember"],
    "mt": ["Jannar", "Frar", "Marzu", "April", "Mejju", "Ġunju", "Lulju", "Awwissu", "Settembru", "Ottubru", "Novembru", "Diċembru"],
    "my": ["ဇန်နဝါရီ", "ဖေဖော်ဝါရီ", "မတ်", "ဧပြီ", "မေ", "ဇွန်", "ဇူလိုင်", "ဩဂုတ်", "စက်တင်ဘာ", "အောက်တိုဘာ", "နိုဝင်ဘာ", "ဒီဇင်ဘာ"],
    "nb": ["januar", "februar", "mars", "april", "mai", "juni", "juli", "august", "september", "oktober", "november", "desember"],
    "ne": ["जनवरी", "फेब्रुअरी", "मार्च", "अप्रिल", "मे", "जुन", "जुलाई", "अगस्ट", "सेप्टेम्बर", "अक्टोबर", "नोभेम्बर", "डिसेम्बर"],
    "nl": ["januari", "februari", "maart", "april", "mei", "juni", "juli", "augustus", "september", "oktober", "november", "december"],
    "pa": ["ਜਨਵਰੀ", "ਫ਼ਰਵਰੀ", "ਮਾਰਚ", "ਅਪ੍ਰੈਲ", "ਮਈ", "ਜੂਨ", "ਜੁਲਾਈ", "ਅਗਸਤ", "ਸਤੰਬਰ", "ਅਕਤੂਬਰ", "ਨਵੰਬਰ", "ਦਸੰਬਰ"],
    "pl": ["styczeń", "luty", "marzec", "kwiecień", "maj", "czerwiec", "lipiec", "sierpień", "wrzesień", "październik", "listopad", "grudzień"],
    "pt": ["janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"],
    "ro": ["ianuarie", "februarie", "martie", "aprilie", "mai", "iunie", "iulie", "august", "septembrie", "octombrie", "noiembrie", "decembrie"],
    "ru": ["январь", "февраль", "март", "апрель", "май", "июнь", "июль", "август", "сентябрь", "октябрь", "ноябрь", "декабрь"],
    "shi": ["ⵉⵏⵏⴰⵢⵔ", "ⴱⵕⴰⵢⵕ", "ⵎⴰⵕⵚ", "ⵉⴱⵔⵉⵔ", "ⵎⴰⵢⵢⵓ", "ⵢⵓⵏⵢⵓ", "ⵢⵓⵍⵢⵓⵣ", "ⵖⵓⵛⵜ", "ⵛⵓⵜⴰⵏⴱⵉⵔ", "ⴽⵜⵓⴱⵔ", "ⵏⵓⵡⴰⵏⴱⵉⵔ", "ⴷⵓⵊⴰⵏⴱⵉⵔ"],
    "si": ["ජනවාරි", "පෙබරවාරි", "මාර්තු", "අප්‍රේල්", "මැයි", "ජූනි", "ජූලි", "අගෝස්තු", "සැප්තැම්බර්", "ඔක්තෝබර්", "නොවැම්බර්", "දෙසැම්බර්"],
    "sk": ["január", "február", "marec", "apríl", "máj", "jún", "júl", "august", "september", "október", "november", "december"],
    "sl": ["januar", "februar", "marec", "april", "maj", "junij", "julij", "avgust", "september", "oktober", "november", "december"],
    "sq": ["janar", "shkurt", "mars", "prill", "maj", "qershor", "korrik", "gusht", "shtator", "tetor", "nëntor", "dhjetor"],
    "sr": ["јануар", "фебруар", "март", "април", "мај", "јун", "јул", "август", "септембар", "октобар", "новембар", "децембар"],
    "sv": ["januari", "februari", "mars", "april", "maj", "juni", "juli", "augusti", "september", "oktober", "november", "december"],
    "sw": ["Januari", "Februari", "Machi", "Aprili", "Mei", "Juni", "Julai", "Agosti", "Septemba", "Oktoba", "Novemba", "Desemba"],
    "ta": ["ஜனவரி", "பிப்ரவரி", "மார்ச்", "ஏப்ரல்", "மே", "ஜூன்", "ஜூலை", "ஆகஸ்ட்", "செப்டம்பர்", "அக்டோபர்", "நவம்பர்", "டிசம்பர்"],
    "te": ["జనవరి", "ఫిబ్రవరి", "మార్చి", "ఏప్రిల్", "మే", "జూన్", "జులై", "ఆగస్టు", "సెప్టెంబర్", "అక్టోబర్", "నవంబర్", "డిసెంబర్"],
    "th": ["มกราคม", "กุมภาพันธ์", "มีนาคม", "เมษายน", "พฤษภาคม", "มิถุนายน", "กรกฎาคม", "สิงหาคม", "กันยายน", "ตุลาคม", "พฤศจิกายน", "ธันวาคม"],
    "tr": ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"],
    "tzm": ["ⵉⵏⵏⴰⵢⵔ", "ⴱⵕⴰⵢⵕ", "ⵎⴰⵕⵚ", "ⵉⴱⵔⵉⵔ", "ⵎⴰⵢⵢⵓ", "ⵢⵓⵏⵢⵓ", "ⵢⵓⵍⵢⵓⵣ", "ⵖⵓⵛⵜ", "ⵛⵓⵜⴰⵏⴱⵉⵔ", "ⴽⵜⵓⴱⵔ", "ⵏⵓⵡⴰⵏⴱⵉⵔ", "ⴷⵓⵊⴰⵏⴱⵉⵔ"],
    "uk": ["січень", "лютий", "березень", "квітень", "травень", "червень", "липень", "серпень", "вересень", "жовтень", "листопад", "грудень"],
    "ur": ["جنوری", "فروری", "مارچ", "اپریل", "مئی", "جون", "جولائی", "اگست", "ستمبر", "اکتوبر", "نومبر", "دسمبر"],
    "uz": ["yanvar", "fevral", "mart", "aprel", "may", "iyun", "iyul", "avgust", "sentabr", "oktabr", "noyabr", "dekabr"],
    "vi": ["tháng 1", "tháng 2", "tháng 3", "tháng 4", "tháng 5", "tháng 6", "tháng 7", "tháng 8", "tháng 9", "tháng 10", "tháng 11", "tháng 12"],
    "zh": ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
}

# ── Short month names ────────────────────────────────────────────────

_SHORT_MONTHS: dict[str, list[str]] = {
    "am": ["ጃንዋ", "ፌብሩ", "ማርች", "ኤፕሪ", "ሜይ", "ጁን", "ጁላይ", "ኦገስ", "ሴፕቴ", "ኦክቶ", "ኖቬም", "ዲሴም"],
    "ar": ["ينا", "فبر", "مار", "أبر", "ماي", "يون", "يول", "أغس", "سبت", "أكت", "نوف", "ديس"],
    "az": ["yan", "fev", "mar", "apr", "may", "iyn", "iyl", "avq", "sen", "okt", "noy", "dek"],
    "bg": ["яну", "фев", "мар", "апр", "май", "юни", "юли", "авг", "сеп", "окт", "ное", "дек"],
    "bn": ["জানু", "ফেব্রু", "মার্চ", "এপ্রি", "মে", "জুন", "জুলাই", "আগ", "সেপ্টে", "অক্টো", "নভে", "ডিসে"],
    "br": ["Gen", "C'hwe", "Meur", "Ebr", "Mae", "Mezh", "Goue", "Eost", "Gwen", "Here", "Du", "Ker"],
    "bs": ["jan", "feb", "mar", "apr", "maj", "jun", "jul", "aug", "sep", "okt", "nov", "dec"],
    "ca": ["gen", "feb", "març", "abr", "maig", "juny", "jul", "ag", "set", "oct", "nov", "des"],
    "cs": ["led", "úno", "bře", "dub", "kvě", "čvn", "čvc", "srp", "zář", "říj", "lis", "pro"],
    "cy": ["Ion", "Chw", "Maw", "Ebr", "Mai", "Meh", "Gor", "Aws", "Med", "Hyd", "Tac", "Rha"],
    "da": ["jan", "feb", "mar", "apr", "maj", "jun", "jul", "aug", "sep", "okt", "nov", "dec"],
    "de": ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"],
    "el": ["Ιαν", "Φεβ", "Μαρ", "Απρ", "Μαΐ", "Ιουν", "Ιουλ", "Αυγ", "Σεπ", "Οκτ", "Νοε", "Δεκ"],
    "en": ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
    "es": ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"],
    "et": ["jaan", "veebr", "märts", "apr", "mai", "juuni", "juuli", "aug", "sept", "okt", "nov", "dets"],
    "eu": ["urt", "ots", "mar", "api", "mai", "eka", "uzt", "abu", "ira", "urr", "aza", "abe"],
    "fa": ["ژان", "فور", "مار", "آور", "مه", "ژوئن", "ژوئیه", "اوت", "سپت", "اکت", "نوا", "دسا"],
    "fi": ["tammi", "helmi", "maalis", "huhti", "touko", "kesä", "heinä", "elo", "syys", "loka", "marras", "joulu"],
    "fil": ["Ene", "Peb", "Mar", "Abr", "May", "Hun", "Hul", "Ago", "Set", "Okt", "Nob", "Dis"],
    "fr": ["janv.", "févr.", "mars", "avr.", "mai", "juin", "juil.", "août", "sept.", "oct.", "nov.", "déc."],
    "ga": ["Ean", "Feabh", "Már", "Aib", "Beal", "Meith", "Iúil", "Lún", "MFómh", "DFómh", "Samh", "Noll"],
    "gd": ["Faoi", "Gearr", "Màrt", "Gibl", "Cèit", "Ògmh", "Iuch", "Lùna", "Sult", "Dàmh", "Samh", "Dùbh"],
    "gu": ["જાન્યુ", "ફેબ્રુ", "માર્ચ", "એપ્રિ", "મે", "જૂન", "જુલાઈ", "ઑગ", "સપ્ટે", "ઑક્ટો", "નવે", "ડિસે"],
    "gv": ["JGeur", "TArr", "Mayr", "Aver", "Boal", "MSour", "JSour", "Luan", "MFouy", "JFouy", "MHoun", "MNoll"],
    "he": ["ינו׳", "פבר׳", "מרץ", "אפר׳", "מאי", "יוני", "יולי", "אוג׳", "ספט׳", "אוק׳", "נוב׳", "דצמ׳"],
    "hi": ["जन", "फ़र", "मार्च", "अप्रैल", "मई", "जून", "जुल", "अग", "सित", "अक्तू", "नव", "दिस"],
    "hr": ["sij", "velj", "ožu", "tra", "svi", "lip", "srp", "kol", "ruj", "lis", "stu", "pro"],
    "hu": ["jan", "feb", "már", "ápr", "máj", "jún", "júl", "aug", "szept", "okt", "nov", "dec"],
    "id": ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agt", "Sep", "Okt", "Nov", "Des"],
    "it": ["gen", "feb", "mar", "apr", "mag", "giu", "lug", "ago", "set", "ott", "nov", "dic"],
    "ja": ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
    "jv": ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agt", "Sep", "Okt", "Nov", "Des"],
    "ka": ["იან", "თებ", "მარ", "აპრ", "მაი", "ივნ", "ივლ", "აგვ", "სექ", "ოქტ", "ნოე", "დეკ"],
    "kk": ["қаң", "ақп", "нау", "сәу", "мам", "мау", "шіл", "там", "қыр", "қаз", "қар", "жел"],
    "km": ["មករា", "កុម្ភៈ", "មីនា", "មេសា", "ឧសភា", "មិថុ", "កក្ក", "សីហា", "កញ្ញា", "តុលា", "វិច្ឆិ", "ធ្នូ"],
    "ko": ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"],
    "kw": ["Gen", "Hwe", "Meu", "Ebr", "Me", "Met", "Gor", "Est", "Gwy", "Hed", "Du", "Kev"],
    "lt": ["saus", "vas", "kov", "bal", "geg", "birž", "liep", "rugp", "rugs", "spal", "lapkr", "gruod"],
    "lv": ["janv", "febr", "marts", "apr", "maijs", "jūn", "jūl", "aug", "sept", "okt", "nov", "dec"],
    "mk": ["јан", "фев", "мар", "апр", "мај", "јун", "јул", "авг", "сеп", "окт", "ное", "дек"],
    "mr": ["जाने", "फेब्रु", "मार्च", "एप्रि", "मे", "जून", "जुलै", "ऑग", "सप्टें", "ऑक्टो", "नोव्हें", "डिसें"],
    "ms": ["Jan", "Feb", "Mac", "Apr", "Mei", "Jun", "Jul", "Ogo", "Sep", "Okt", "Nov", "Dis"],
    "mt": ["Jan", "Fra", "Mar", "Apr", "Mej", "Ġun", "Lul", "Aww", "Set", "Ott", "Nov", "Diċ"],
    "my": ["ဇန်", "ဖေ", "မတ်", "ဧ", "မေ", "ဇွန်", "ဇူ", "ဩ", "စက်", "အောက်", "နို", "ဒီ"],
    "nb": ["jan", "feb", "mar", "apr", "mai", "jun", "jul", "aug", "sep", "okt", "nov", "des"],
    "ne": ["जन", "फेब", "मार्च", "अप्रि", "मे", "जुन", "जुलाई", "अग", "सेप्ट", "अक्ट", "नोभे", "डिसे"],
    "nl": ["jan", "feb", "mrt", "apr", "mei", "jun", "jul", "aug", "sep", "okt", "nov", "dec"],
    "pa": ["ਜਨ", "ਫ਼ਰ", "ਮਾਰਚ", "ਅਪ੍ਰੈ", "ਮਈ", "ਜੂਨ", "ਜੁਲਾ", "ਅਗ", "ਸਤੰ", "ਅਕਤੂ", "ਨਵੰ", "ਦਸੰ"],
    "pl": ["sty", "lut", "mar", "kwi", "maj", "cze", "lip", "sie", "wrz", "paź", "lis", "gru"],
    "pt": ["jan", "fev", "mar", "abr", "mai", "jun", "jul", "ago", "set", "out", "nov", "dez"],
    "ro": ["ian", "feb", "mar", "apr", "mai", "iun", "iul", "aug", "sep", "oct", "nov", "dec"],
    "ru": ["янв", "фев", "мар", "апр", "май", "июн", "июл", "авг", "сен", "окт", "ноя", "дек"],
    "shi": ["ⵉⵏⵏ", "ⴱⵕⴰ", "ⵎⴰⵕ", "ⵉⴱⵔ", "ⵎⴰⵢ", "ⵢⵓⵏ", "ⵢⵓⵍ", "ⵖⵓⵛ", "ⵛⵓⵜ", "ⴽⵜⵓ", "ⵏⵓⵡ", "ⴷⵓⵊ"],
    "si": ["ජන", "පෙබ", "මාර්", "අප්‍", "මැයි", "ජූනි", "ජූලි", "අගෝ", "සැප්", "ඔක්", "නොවැ", "දෙසැ"],
    "sk": ["jan", "feb", "mar", "apr", "máj", "jún", "júl", "aug", "sep", "okt", "nov", "dec"],
    "sl": ["jan", "feb", "mar", "apr", "maj", "jun", "jul", "avg", "sep", "okt", "nov", "dec"],
    "sq": ["jan", "shk", "mar", "pri", "maj", "qer", "kor", "gush", "sht", "tet", "nën", "dhj"],
    "sr": ["јан", "феб", "мар", "апр", "мај", "јун", "јул", "авг", "сеп", "окт", "нов", "дец"],
    "sv": ["jan", "feb", "mar", "apr", "maj", "jun", "jul", "aug", "sep", "okt", "nov", "dec"],
    "sw": ["Jan", "Feb", "Mac", "Apr", "Mei", "Jun", "Jul", "Ago", "Sep", "Okt", "Nov", "Des"],
    "ta": ["ஜன", "பிப்", "மார்", "ஏப்", "மே", "ஜூன்", "ஜூலை", "ஆக", "செப்", "அக்", "நவ", "டிச"],
    "te": ["జన", "ఫిబ్ర", "మార్చి", "ఏప్రి", "మే", "జూన్", "జులై", "ఆగ", "సెప్టెం", "అక్టో", "నవం", "డిసెం"],
    "th": ["ม.ค.", "ก.พ.", "มี.ค.", "เม.ย.", "พ.ค.", "มิ.ย.", "ก.ค.", "ส.ค.", "ก.ย.", "ต.ค.", "พ.ย.", "ธ.ค."],
    "tr": ["Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"],
    "tzm": ["ⵉⵏⵏ", "ⴱⵕⴰ", "ⵎⴰⵕ", "ⵉⴱⵔ", "ⵎⴰⵢ", "ⵢⵓⵏ", "ⵢⵓⵍ", "ⵖⵓⵛ", "ⵛⵓⵜ", "ⴽⵜⵓ", "ⵏⵓⵡ", "ⴷⵓⵊ"],
    "uk": ["січ", "лют", "бер", "квіт", "трав", "черв", "лип", "серп", "вер", "жовт", "лист", "груд"],
    "ur": ["جن", "فر", "مار", "اپر", "مئی", "جون", "جول", "اگ", "ست", "اکت", "نو", "دس"],
    "uz": ["yan", "fev", "mar", "apr", "may", "iyn", "iyl", "avg", "sen", "okt", "noy", "dek"],
    "vi": ["Th1", "Th2", "Th3", "Th4", "Th5", "Th6", "Th7", "Th8", "Th9", "Th10", "Th11", "Th12"],
    "zh": ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
}

# ── Weekday names (full, starting Sunday) ────────────────────────────

_WEEKDAYS: dict[str, list[str]] = {
    "am": ["እሑድ", "ሰኞ", "ማክሰኞ", "ረቡዕ", "ሐሙስ", "ዓርብ", "ቅዳሜ"],
    "ar": ["الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت"],
    "az": ["bazar", "bazar ertəsi", "çərşənbə axşamı", "çərşənbə", "cümə axşamı", "cümə", "şənbə"],
    "bg": ["неделя", "понеделник", "вторник", "сряда", "четвъртък", "петък", "събота"],
    "bn": ["রবিবার", "সোমবার", "মঙ্গলবার", "বুধবার", "বৃহস্পতিবার", "শুক্রবার", "শনিবার"],
    "br": ["Sul", "Lun", "Meurzh", "Merc'her", "Yaou", "Gwener", "Sadorn"],
    "bs": ["nedjelja", "ponedjeljak", "utorak", "srijeda", "četvrtak", "petak", "subota"],
    "ca": ["diumenge", "dilluns", "dimarts", "dimecres", "dijous", "divendres", "dissabte"],
    "cs": ["neděle", "pondělí", "úterý", "středa", "čtvrtek", "pátek", "sobota"],
    "cy": ["Dydd Sul", "Dydd Llun", "Dydd Mawrth", "Dydd Mercher", "Dydd Iau", "Dydd Gwener", "Dydd Sadwrn"],
    "da": ["søndag", "mandag", "tirsdag", "onsdag", "torsdag", "fredag", "lørdag"],
    "de": ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"],
    "el": ["Κυριακή", "Δευτέρα", "Τρίτη", "Τετάρτη", "Πέμπτη", "Παρασκευή", "Σάββατο"],
    "en": ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
    "es": ["domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado"],
    "et": ["pühapäev", "esmaspäev", "teisipäev", "kolmapäev", "neljapäev", "reede", "laupäev"],
    "eu": ["igandea", "astelehena", "asteartea", "asteazkena", "osteguna", "ostirala", "larunbata"],
    "fa": ["یکشنبه", "دوشنبه", "سه‌شنبه", "چهارشنبه", "پنجشنبه", "جمعه", "شنبه"],
    "fi": ["sunnuntai", "maanantai", "tiistai", "keskiviikko", "torstai", "perjantai", "lauantai"],
    "fil": ["Linggo", "Lunes", "Martes", "Miyerkules", "Huwebes", "Biyernes", "Sabado"],
    "fr": ["dimanche", "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi"],
    "ga": ["Dé Domhnaigh", "Dé Luain", "Dé Máirt", "Dé Céadaoin", "Déardaoin", "Dé hAoine", "Dé Sathairn"],
    "gd": ["DiDòmhnaich", "DiLuain", "DiMàirt", "DiCiadain", "DiarDaoin", "DihAoine", "DiSathairne"],
    "gu": ["રવિવાર", "સોમવાર", "મંગળવાર", "બુધવાર", "ગુરુવાર", "શુક્રવાર", "શનિવાર"],
    "gv": ["Jedoonee", "Jelhein", "Jemayrt", "Jercean", "Jerdein", "Jeheiney", "Jesarn"],
    "he": ["יום ראשון", "יום שני", "יום שלישי", "יום רביעי", "יום חמישי", "יום שישי", "שבת"],
    "hi": ["रविवार", "सोमवार", "मंगलवार", "बुधवार", "गुरुवार", "शुक्रवार", "शनिवार"],
    "hr": ["nedjelja", "ponedjeljak", "utorak", "srijeda", "četvrtak", "petak", "subota"],
    "hu": ["vasárnap", "hétfő", "kedd", "szerda", "csütörtök", "péntek", "szombat"],
    "id": ["Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu"],
    "it": ["domenica", "lunedì", "martedì", "mercoledì", "giovedì", "venerdì", "sabato"],
    "ja": ["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"],
    "jv": ["Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu"],
    "ka": ["კვირა", "ორშაბათი", "სამშაბათი", "ოთხშაბათი", "ხუთშაბათი", "პარასკევი", "შაბათი"],
    "kk": ["жексенбі", "дүйсенбі", "сейсенбі", "сәрсенбі", "бейсенбі", "жұма", "сенбі"],
    "km": ["អាទិត្យ", "ចន្ទ", "អង្គារ", "ពុធ", "ព្រហស្បតិ៍", "សុក្រ", "សៅរ៍"],
    "ko": ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"],
    "kw": ["De Sul", "De Lun", "De Merth", "De Merher", "De Yow", "De Gwener", "De Sadorn"],
    "lt": ["sekmadienis", "pirmadienis", "antradienis", "trečiadienis", "ketvirtadienis", "penktadienis", "šeštadienis"],
    "lv": ["svētdiena", "pirmdiena", "otrdiena", "trešdiena", "ceturtdiena", "piektdiena", "sestdiena"],
    "mk": ["недела", "понеделник", "вторник", "среда", "четврток", "петок", "сабота"],
    "mr": ["रविवार", "सोमवार", "मंगळवार", "बुधवार", "गुरुवार", "शुक्रवार", "शनिवार"],
    "ms": ["Ahad", "Isnin", "Selasa", "Rabu", "Khamis", "Jumaat", "Sabtu"],
    "mt": ["Il-Ħadd", "It-Tnejn", "It-Tlieta", "L-Erbgħa", "Il-Ħamis", "Il-Ġimgħa", "Is-Sibt"],
    "my": ["တနင်္ဂနွေ", "တနင်္လာ", "အင်္ဂါ", "ဗုဒ္ဓဟူး", "ကြာသပတေး", "သောကြာ", "စနေ"],
    "nb": ["søndag", "mandag", "tirsdag", "onsdag", "torsdag", "fredag", "lørdag"],
    "ne": ["आइतबार", "सोमबार", "मंगलबार", "बुधबार", "बिहिबार", "शुक्रबार", "शनिबार"],
    "nl": ["zondag", "maandag", "dinsdag", "woensdag", "donderdag", "vrijdag", "zaterdag"],
    "pa": ["ਐਤਵਾਰ", "ਸੋਮਵਾਰ", "ਮੰਗਲਵਾਰ", "ਬੁੱਧਵਾਰ", "ਵੀਰਵਾਰ", "ਸ਼ੁੱਕਰਵਾਰ", "ਸ਼ਨਿੱਚਰਵਾਰ"],
    "pl": ["niedziela", "poniedziałek", "wtorek", "środa", "czwartek", "piątek", "sobota"],
    "pt": ["domingo", "segunda-feira", "terça-feira", "quarta-feira", "quinta-feira", "sexta-feira", "sábado"],
    "ro": ["duminică", "luni", "marți", "miercuri", "joi", "vineri", "sâmbătă"],
    "ru": ["воскресенье", "понедельник", "вторник", "среда", "четверг", "пятница", "суббота"],
    "shi": ["ⴰⵙⴰⵎⴰⵙ", "ⴰⵢⵏⴰⵙ", "ⴰⵙⵉⵏⴰⵙ", "ⴰⴽⵕⴰⵙ", "ⴰⴽⵡⴰⵙ", "ⴰⵙⵉⵎⵡⴰⵙ", "ⴰⵙⵉⴹⵢⴰⵙ"],
    "si": ["ඉරිදා", "සඳුදා", "අඟහරුවාදා", "බදාදා", "බ්‍රහස්පතින්දා", "සිකුරාදා", "සෙනසුරාදා"],
    "sk": ["nedeľa", "pondelok", "utorok", "streda", "štvrtok", "piatok", "sobota"],
    "sl": ["nedelja", "ponedeljek", "torek", "sreda", "četrtek", "petek", "sobota"],
    "sq": ["e diel", "e hënë", "e martë", "e mërkurë", "e enjte", "e premte", "e shtunë"],
    "sr": ["недеља", "понедељак", "уторак", "среда", "четвртак", "петак", "субота"],
    "sv": ["söndag", "måndag", "tisdag", "onsdag", "torsdag", "fredag", "lördag"],
    "sw": ["Jumapili", "Jumatatu", "Jumanne", "Jumatano", "Alhamisi", "Ijumaa", "Jumamosi"],
    "ta": ["ஞாயிறு", "திங்கள்", "செவ்வாய்", "புதன்", "வியாழன்", "வெள்ளி", "சனி"],
    "te": ["ఆదివారం", "సోమవారం", "మంగళవారం", "బుధవారం", "గురువారం", "శుక్రవారం", "శనివారం"],
    "th": ["วันอาทิตย์", "วันจันทร์", "วันอังคาร", "วันพุธ", "วันพฤหัสบดี", "วันศุกร์", "วันเสาร์"],
    "tr": ["Pazar", "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi"],
    "tzm": ["ⴰⵙⴰⵎⴰⵙ", "ⴰⵢⵏⴰⵙ", "ⴰⵙⵉⵏⴰⵙ", "ⴰⴽⵕⴰⵙ", "ⴰⴽⵡⴰⵙ", "ⴰⵙⵉⵎⵡⴰⵙ", "ⴰⵙⵉⴹⵢⴰⵙ"],
    "uk": ["неділя", "понеділок", "вівторок", "середа", "четвер", "п'ятниця", "субота"],
    "ur": ["اتوار", "پیر", "منگل", "بدھ", "جمعرات", "جمعہ", "ہفتہ"],
    "uz": ["yakshanba", "dushanba", "seshanba", "chorshanba", "payshanba", "juma", "shanba"],
    "vi": ["Chủ Nhật", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy"],
    "zh": ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"],
}

# ── Short weekday names ──────────────────────────────────────────────

_SHORT_WEEKDAYS: dict[str, list[str]] = {
    "am": ["እሑድ", "ሰኞ", "ማክሰ", "ረቡዕ", "ሐሙስ", "ዓርብ", "ቅዳሜ"],
    "ar": ["أحد", "إثن", "ثلا", "أرب", "خمي", "جمع", "سبت"],
    "az": ["B.", "B.e.", "Ç.a.", "Ç.", "C.a.", "C.", "Ş."],
    "bg": ["нд", "пн", "вт", "ср", "чт", "пт", "сб"],
    "bn": ["রবি", "সোম", "মঙ্গ", "বুধ", "বৃহ", "শুক্র", "শনি"],
    "br": ["Sul", "Lun", "Meu", "Mer", "Yao", "Gwe", "Sad"],
    "bs": ["ned", "pon", "uto", "sri", "čet", "pet", "sub"],
    "ca": ["dg", "dl", "dt", "dc", "dj", "dv", "ds"],
    "cs": ["ne", "po", "út", "st", "čt", "pá", "so"],
    "cy": ["Sul", "Llu", "Maw", "Mer", "Iau", "Gwe", "Sad"],
    "da": ["søn", "man", "tir", "ons", "tor", "fre", "lør"],
    "de": ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"],
    "el": ["Κυρ", "Δευ", "Τρί", "Τετ", "Πέμ", "Παρ", "Σάβ"],
    "en": ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
    "es": ["dom", "lun", "mar", "mié", "jue", "vie", "sáb"],
    "et": ["P", "E", "T", "K", "N", "R", "L"],
    "eu": ["ig", "al", "ar", "az", "og", "or", "lr"],
    "fa": ["یکش", "دوش", "سه‌ش", "چهار", "پنجش", "جمعه", "شنبه"],
    "fi": ["su", "ma", "ti", "ke", "to", "pe", "la"],
    "fil": ["Lin", "Lun", "Mar", "Miy", "Huw", "Biy", "Sab"],
    "fr": ["dim", "lun", "mar", "mer", "jeu", "ven", "sam"],
    "ga": ["Domh", "Luan", "Máirt", "Céad", "Déar", "Aoine", "Sath"],
    "gd": ["DiD", "DiL", "DiM", "DiC", "Dia", "Dih", "DiS"],
    "gu": ["રવિ", "સોમ", "મંગ", "બુધ", "ગુરુ", "શુક્ર", "શનિ"],
    "gv": ["Jed", "Jel", "Jem", "Jer", "Jerd", "Jeh", "Jes"],
    "he": ["א׳", "ב׳", "ג׳", "ד׳", "ה׳", "ו׳", "ש׳"],
    "hi": ["रवि", "सोम", "मंगल", "बुध", "गुरु", "शुक्र", "शनि"],
    "hr": ["ned", "pon", "uto", "sri", "čet", "pet", "sub"],
    "hu": ["V", "H", "K", "Sze", "Cs", "P", "Szo"],
    "id": ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"],
    "it": ["dom", "lun", "mar", "mer", "gio", "ven", "sab"],
    "ja": ["日", "月", "火", "水", "木", "金", "土"],
    "jv": ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"],
    "ka": ["კვი", "ორშ", "სამ", "ოთხ", "ხუთ", "პარ", "შაბ"],
    "kk": ["жс", "дс", "сс", "ср", "бс", "жм", "сб"],
    "km": ["អា", "ច", "អ", "ពុ", "ព្រ", "សុ", "ស"],
    "ko": ["일", "월", "화", "수", "목", "금", "토"],
    "kw": ["Sul", "Lun", "Mth", "Mhr", "Yow", "Gwe", "Sad"],
    "lt": ["sk", "pr", "an", "tr", "kt", "pn", "št"],
    "lv": ["sv", "pr", "ot", "tr", "ce", "pk", "se"],
    "mk": ["нед", "пон", "вто", "сре", "чет", "пет", "саб"],
    "mr": ["रवि", "सोम", "मंगळ", "बुध", "गुरु", "शुक्र", "शनि"],
    "ms": ["Ahd", "Isn", "Sel", "Rab", "Kha", "Jum", "Sab"],
    "mt": ["Ħad", "Tne", "Tli", "Erb", "Ħam", "Ġim", "Sib"],
    "my": ["တနင်္ဂ", "တနင်္လာ", "အင်္ဂါ", "ဗုဒ္ဓ", "ကြာ", "သော", "စနေ"],
    "nb": ["søn", "man", "tir", "ons", "tor", "fre", "lør"],
    "ne": ["आइत", "सोम", "मंगल", "बुध", "बिहि", "शुक्र", "शनि"],
    "nl": ["zo", "ma", "di", "wo", "do", "vr", "za"],
    "pa": ["ਐਤ", "ਸੋਮ", "ਮੰਗ", "ਬੁੱਧ", "ਵੀਰ", "ਸ਼ੁੱਕ", "ਸ਼ਨਿ"],
    "pl": ["ndz", "pon", "wt", "śr", "czw", "pt", "sob"],
    "pt": ["dom", "seg", "ter", "qua", "qui", "sex", "sáb"],
    "ro": ["dum", "lun", "mar", "mie", "joi", "vin", "sâm"],
    "ru": ["вс", "пн", "вт", "ср", "чт", "пт", "сб"],
    "shi": ["ⴰⵙⴰ", "ⴰⵢⵏ", "ⴰⵙⵉ", "ⴰⴽⵕ", "ⴰⴽⵡ", "ⴰⵙⵉⵎ", "ⴰⵙⵉⴹ"],
    "si": ["ඉරි", "සඳු", "අඟ", "බදා", "බ්‍ර", "සිකු", "සෙන"],
    "sk": ["ne", "po", "ut", "st", "št", "pi", "so"],
    "sl": ["ned", "pon", "tor", "sre", "čet", "pet", "sob"],
    "sq": ["Die", "Hën", "Mar", "Mër", "Enj", "Pre", "Sht"],
    "sr": ["нед", "пон", "уто", "сре", "чет", "пет", "суб"],
    "sv": ["sön", "mån", "tis", "ons", "tor", "fre", "lör"],
    "sw": ["Jpi", "Jtt", "Jnn", "Jtn", "Alh", "Iju", "Jms"],
    "ta": ["ஞாயி", "திங்", "செவ்", "புத", "வியா", "வெள்", "சனி"],
    "te": ["ఆది", "సోమ", "మంగ", "బుధ", "గురు", "శుక్ర", "శని"],
    "th": ["อา.", "จ.", "อ.", "พ.", "พฤ.", "ศ.", "ส."],
    "tr": ["Paz", "Pzt", "Sal", "Çar", "Per", "Cum", "Cmt"],
    "tzm": ["ⴰⵙⴰ", "ⴰⵢⵏ", "ⴰⵙⵉ", "ⴰⴽⵕ", "ⴰⴽⵡ", "ⴰⵙⵉⵎ", "ⴰⵙⵉⴹ"],
    "uk": ["нд", "пн", "вт", "ср", "чт", "пт", "сб"],
    "ur": ["اتو", "پیر", "منگ", "بدھ", "جمع", "جمعہ", "ہفتہ"],
    "uz": ["yak", "dush", "sesh", "chor", "pay", "jum", "shan"],
    "vi": ["CN", "T2", "T3", "T4", "T5", "T6", "T7"],
    "zh": ["周日", "周一", "周二", "周三", "周四", "周五", "周六"],
}

# ── Day ordinal formatting ───────────────────────────────────────────
# (dayFormat, dayFormatExceptions) — how to render the day number in date context

_DAY_FORMAT: dict[str, tuple[str, dict[str, str]]] = {
    # Most languages: bare number
    "default": ("{n}", {}),
    # English: ordinal suffixes
    "en": ("{n}th", {"1": "{n}st", "2": "{n}nd", "3": "{n}rd", "21": "{n}st", "22": "{n}nd", "23": "{n}rd", "31": "{n}st"}),
    # German/Austrian: number + period
    "de": ("{n}.", {}),
    # Czech/Slovak: number + period
    "cs": ("{n}.", {}),
    "sk": ("{n}.", {}),
    # Spanish: bare number
    "es": ("{n}", {}),
    # French: "1er" for 1st, bare number otherwise
    "fr": ("{n}", {"1": "{n}er"}),
    # Italian: bare number (1° optional but not standard in dates)
    "it": ("{n}", {}),
    # Portuguese: bare number
    "pt": ("{n}", {}),
    # Japanese: 日 suffix
    "ja": ("{n}日", {}),
    # Korean: 일 suffix
    "ko": ("{n}일", {}),
    # Chinese: 日 suffix
    "zh": ("{n}日", {}),
    # Thai: bare number
    "th": ("{n}", {}),
    # Vietnamese: bare number
    "vi": ("{n}", {}),
    # Hungarian: number + period
    "hu": ("{n}.", {}),
    # Turkish: bare number
    "tr": ("{n}", {}),
    # Finnish: number + period
    "fi": ("{n}.", {}),
    # Swedish: bare number
    "sv": ("{n}", {}),
    # Norwegian: number + period
    "nb": ("{n}.", {}),
    # Danish: number + period
    "da": ("{n}.", {}),
    # Dutch: bare number
    "nl": ("{n}", {}),
    # Polish: bare number
    "pl": ("{n}", {}),
    # Romanian: bare number
    "ro": ("{n}", {}),
    # Croatian: number + period
    "hr": ("{n}.", {}),
    # Serbian: number + period
    "sr": ("{n}.", {}),
    # Slovenian: number + period
    "sl": ("{n}.", {}),
    # Bulgarian: bare number
    "bg": ("{n}", {}),
    # Greek: bare number
    "el": ("{n}", {}),
    # Icelandic: number + period
    # Estonian: number + period
    "et": ("{n}.", {}),
    # Latvian: number + period
    "lv": ("{n}.", {}),
    # Lithuanian: number + period
    "lt": ("{n}.", {}),
    # Bosnian: number + period
    "bs": ("{n}.", {}),
    # Macedonian: bare number
    "mk": ("{n}", {}),
    # Albanian: bare number
    "sq": ("{n}", {}),
    # Maltese: bare number
    "mt": ("{n}", {}),
    # Welsh: bare number
    "cy": ("{n}", {}),
    # Breton: bare number
    "br": ("{n}", {}),
    # Basque: bare number
    "eu": ("{n}", {}),
    # Catalan: bare number
    "ca": ("{n}", {}),
    # Galician (ga): bare number
    "ga": ("{n}", {}),
    # Scottish Gaelic
    "gd": ("{n}", {}),
}

# ── Date patterns ────────────────────────────────────────────────────
# (datePattern, datePatternWithYear)

_DATE_PATTERNS: dict[str, tuple[str, str]] = {
    # Default: day month (European standard)
    "default": ("{day} {month}", "{day} {month} {year}"),
    # English: month day
    "en": ("{month} {day}", "{month} {day}, {year}"),
    # German: day. month
    "de": ("{day} {month}", "{day} {month} {year}"),
    # French: day month
    "fr": ("{day} {month}", "{day} {month} {year}"),
    # Spanish: day de month
    "es": ("{day} de {month}", "{day} de {month} de {year}"),
    # Italian: day month
    "it": ("{day} {month}", "{day} {month} {year}"),
    # Portuguese: day de month
    "pt": ("{day} de {month}", "{day} de {month} de {year}"),
    # Japanese: month day (uses numeric month names already)
    "ja": ("{month}{day}", "{year}年{month}{day}"),
    # Korean: month day
    "ko": ("{month} {day}", "{year}년 {month} {day}"),
    # Chinese: month day
    "zh": ("{month}{day}", "{year}年{month}{day}"),
    # Hungarian: month day. (reversed from most European)
    "hu": ("{month} {day}", "{year}. {month} {day}"),
    # Turkish: day month
    "tr": ("{day} {month}", "{day} {month} {year}"),
    # Finnish: day month
    "fi": ("{day} {month}", "{day} {month} {year}"),
    # Catalan: day month (with article)
    "ca": ("{day} de {month}", "{day} de {month} de {year}"),
    # Basque: month day
    "eu": ("{month}ren {day}", "{year}ko {month}ren {day}"),
    # Vietnamese: day tháng m
    "vi": ("{day} {month}", "{day} {month} {year}"),
    # Thai: day month
    "th": ("{day} {month}", "{day} {month} {year}"),
    # Filipino: month day
    "fil": ("{month} {day}", "{month} {day}, {year}"),
}

# ── Compact patterns ─────────────────────────────────────────────────

_COMPACT_PATTERNS: dict[str, tuple[str, str]] = {
    # Default: d/m
    "default": ("{d}/{m}", "{d}/{m}/{yy}"),
    # US-style: m/d
    "en": ("{m}/{d}", "{m}/{d}/{yy}"),
    "fil": ("{m}/{d}", "{m}/{d}/{yy}"),
    # German: d.m.
    "de": ("{d}.{m}.", "{d}.{m}.{yy}"),
    # Japanese/Chinese/Korean: m/d
    "ja": ("{m}/{d}", "{yy}/{m}/{d}"),
    "ko": ("{m}/{d}", "{yy}/{m}/{d}"),
    "zh": ("{m}/{d}", "{yy}/{m}/{d}"),
    # Dot-separated (many European)
    "hu": ("{m}.{d}.", "{yy}.{m}.{d}."),
    # Dash-separated
    "sv": ("{d}/{m}", "{yy}-{m}-{d}"),
    "nb": ("{d}.{m}.", "{d}.{m}.{yy}"),
    "da": ("{d}.{m}.", "{d}.{m}.{yy}"),
    "fi": ("{d}.{m}.", "{d}.{m}.{yy}"),
    "et": ("{d}.{m}.", "{d}.{m}.{yy}"),
    "lv": ("{d}.{m}.", "{d}.{m}.{yy}"),
    "lt": ("{m}-{d}", "{yy}-{m}-{d}"),
    "cs": ("{d}.{m}.", "{d}.{m}.{yy}"),
    "sk": ("{d}.{m}.", "{d}.{m}.{yy}"),
    "sl": ("{d}.{m}.", "{d}.{m}.{yy}"),
    "hr": ("{d}.{m}.", "{d}.{m}.{yy}"),
    "bs": ("{d}.{m}.", "{d}.{m}.{yy}"),
    "sr": ("{d}.{m}.", "{d}.{m}.{yy}"),
    "mk": ("{d}.{m}.", "{d}.{m}.{yy}"),
    "pl": ("{d}.{m}.", "{d}.{m}.{yy}"),
    "ro": ("{d}.{m}.", "{d}.{m}.{yy}"),
    "tr": ("{d}.{m}.", "{d}.{m}.{yy}"),
}

# ── Short date patterns ──────────────────────────────────────────────

_SHORT_PATTERNS: dict[str, tuple[str, str]] = {
    # Default: same structure as normal but with abbreviated month
    "default": ("{day} {month}", "{day} {month} {year}"),
    "en": ("{month} {day}", "{month} {day}, {year}"),
    "es": ("{day} {month}", "{day} {month} {year}"),
    "pt": ("{day} {month}", "{day} {month} {year}"),
    "ca": ("{day} {month}", "{day} {month} {year}"),
    "ja": ("{month}{day}", "{year}年{month}{day}"),
    "ko": ("{month} {day}", "{year}년 {month} {day}"),
    "zh": ("{month}{day}", "{year}年{month}{day}"),
    "hu": ("{month} {day}", "{year}. {month} {day}"),
    "eu": ("{month} {day}", "{year} {month} {day}"),
    "fil": ("{month} {day}", "{month} {day}, {year}"),
}

# ── Genitive month names (for date context) ─────────────────────────
# Languages where month form changes in date expressions

_MONTHS_IN_DATE: dict[str, list[str]] = {
    "cs": ["ledna", "února", "března", "dubna", "května", "června", "července", "srpna", "září", "října", "listopadu", "prosince"],
    "el": ["Ιανουαρίου", "Φεβρουαρίου", "Μαρτίου", "Απριλίου", "Μαΐου", "Ιουνίου", "Ιουλίου", "Αυγούστου", "Σεπτεμβρίου", "Οκτωβρίου", "Νοεμβρίου", "Δεκεμβρίου"],
    "fi": ["tammikuuta", "helmikuuta", "maaliskuuta", "huhtikuuta", "toukokuuta", "kesäkuuta", "heinäkuuta", "elokuuta", "syyskuuta", "lokakuuta", "marraskuuta", "joulukuuta"],
    "hr": ["siječnja", "veljače", "ožujka", "travnja", "svibnja", "lipnja", "srpnja", "kolovoza", "rujna", "listopada", "studenoga", "prosinca"],
    "lt": ["sausio", "vasario", "kovo", "balandžio", "gegužės", "birželio", "liepos", "rugpjūčio", "rugsėjo", "spalio", "lapkričio", "gruodžio"],
    "pl": ["stycznia", "lutego", "marca", "kwietnia", "maja", "czerwca", "lipca", "sierpnia", "września", "października", "listopada", "grudnia"],
    "ro": ["ianuarie", "februarie", "martie", "aprilie", "mai", "iunie", "iulie", "august", "septembrie", "octombrie", "noiembrie", "decembrie"],
    "ru": ["января", "февраля", "марта", "апреля", "мая", "июня", "июля", "августа", "сентября", "октября", "ноября", "декабря"],
    "sk": ["januára", "februára", "marca", "apríla", "mája", "júna", "júla", "augusta", "septembra", "októbra", "novembra", "decembra"],
    "sl": ["januarja", "februarja", "marca", "aprila", "maja", "junija", "julija", "avgusta", "septembra", "oktobra", "novembra", "decembra"],
    "uk": ["січня", "лютого", "березня", "квітня", "травня", "червня", "липня", "серпня", "вересня", "жовтня", "листопада", "грудня"],
}

# ── Relative date terms ──────────────────────────────────────────────

_RELATIVE: dict[str, dict[str, str | None]] = {
    "am": {"today": "ዛሬ", "tomorrow": "ነገ", "yesterday": "ትናንት", "dayAfterTomorrow": "ከነገ ወዲያ", "dayBeforeYesterday": "ከትናንት በፊት", "thisWeekday": "ይህ {weekday}", "nextWeekday": "ቀጣይ {weekday}", "lastWeekday": "ያለፈው {weekday}"},
    "ar": {"today": "اليوم", "tomorrow": "غداً", "yesterday": "أمس", "dayAfterTomorrow": "بعد غد", "dayBeforeYesterday": "أول أمس", "thisWeekday": "هذا {weekday}", "nextWeekday": "{weekday} القادم", "lastWeekday": "{weekday} الماضي"},
    "az": {"today": "bu gün", "tomorrow": "sabah", "yesterday": "dünən", "dayAfterTomorrow": "birisi gün", "dayBeforeYesterday": "srağagün", "thisWeekday": "bu {weekday}", "nextWeekday": "gələn {weekday}", "lastWeekday": "keçən {weekday}"},
    "bg": {"today": "днес", "tomorrow": "утре", "yesterday": "вчера", "dayAfterTomorrow": "вдругиден", "dayBeforeYesterday": "онзи ден", "thisWeekday": "този {weekday}", "nextWeekday": "следващият {weekday}", "lastWeekday": "миналият {weekday}"},
    "bn": {"today": "আজ", "tomorrow": "আগামীকাল", "yesterday": "গতকাল", "dayAfterTomorrow": "পরশু", "dayBeforeYesterday": "গত পরশু", "thisWeekday": "এই {weekday}", "nextWeekday": "আগামী {weekday}", "lastWeekday": "গত {weekday}"},
    "br": {"today": "hiziv", "tomorrow": "warc'hoazh", "yesterday": "dec'h", "dayAfterTomorrow": None, "dayBeforeYesterday": None, "thisWeekday": "ar {weekday}-mañ", "nextWeekday": "{weekday} a zeu", "lastWeekday": "{weekday} paseet"},
    "bs": {"today": "danas", "tomorrow": "sutra", "yesterday": "jučer", "dayAfterTomorrow": "prekosutra", "dayBeforeYesterday": "prekjučer", "thisWeekday": "ovaj {weekday}", "nextWeekday": "sljedeći {weekday}", "lastWeekday": "prošli {weekday}"},
    "ca": {"today": "avui", "tomorrow": "demà", "yesterday": "ahir", "dayAfterTomorrow": "demà passat", "dayBeforeYesterday": "abans-d'ahir", "thisWeekday": "aquest {weekday}", "nextWeekday": "{weekday} que ve", "lastWeekday": "{weekday} passat"},
    "cs": {"today": "dnes", "tomorrow": "zítra", "yesterday": "včera", "dayAfterTomorrow": "pozítří", "dayBeforeYesterday": "předevčírem", "thisWeekday": "toto {weekday}", "nextWeekday": "příští {weekday}", "lastWeekday": "minulé {weekday}"},
    "cy": {"today": "heddiw", "tomorrow": "yfory", "yesterday": "ddoe", "dayAfterTomorrow": "drennydd", "dayBeforeYesterday": "echdoe", "thisWeekday": "y {weekday} hwn", "nextWeekday": "{weekday} nesaf", "lastWeekday": "{weekday} diwethaf"},
    "da": {"today": "i dag", "tomorrow": "i morgen", "yesterday": "i går", "dayAfterTomorrow": "i overmorgen", "dayBeforeYesterday": "i forgårs", "thisWeekday": "denne {weekday}", "nextWeekday": "næste {weekday}", "lastWeekday": "sidste {weekday}"},
    "de": {"today": "heute", "tomorrow": "morgen", "yesterday": "gestern", "dayAfterTomorrow": "übermorgen", "dayBeforeYesterday": "vorgestern", "thisWeekday": "diesen {weekday}", "nextWeekday": "nächsten {weekday}", "lastWeekday": "letzten {weekday}"},
    "el": {"today": "σήμερα", "tomorrow": "αύριο", "yesterday": "χθες", "dayAfterTomorrow": "μεθαύριο", "dayBeforeYesterday": "προχθές", "thisWeekday": "αυτή την {weekday}", "nextWeekday": "επόμενη {weekday}", "lastWeekday": "περασμένη {weekday}"},
    "en": {"today": "today", "tomorrow": "tomorrow", "yesterday": "yesterday", "dayAfterTomorrow": "the day after tomorrow", "dayBeforeYesterday": "the day before yesterday", "thisWeekday": "this {weekday}", "nextWeekday": "next {weekday}", "lastWeekday": "last {weekday}"},
    "es": {"today": "hoy", "tomorrow": "mañana", "yesterday": "ayer", "dayAfterTomorrow": "pasado mañana", "dayBeforeYesterday": "anteayer", "thisWeekday": "este {weekday}", "nextWeekday": "el próximo {weekday}", "lastWeekday": "el pasado {weekday}"},
    "et": {"today": "täna", "tomorrow": "homme", "yesterday": "eile", "dayAfterTomorrow": "ülehomme", "dayBeforeYesterday": "üleeile", "thisWeekday": "see {weekday}", "nextWeekday": "järgmine {weekday}", "lastWeekday": "eelmine {weekday}"},
    "eu": {"today": "gaur", "tomorrow": "bihar", "yesterday": "atzo", "dayAfterTomorrow": "etzi", "dayBeforeYesterday": "herenegun", "thisWeekday": "{weekday} hau", "nextWeekday": "hurrengo {weekday}", "lastWeekday": "aurreko {weekday}"},
    "fa": {"today": "امروز", "tomorrow": "فردا", "yesterday": "دیروز", "dayAfterTomorrow": "پس‌فردا", "dayBeforeYesterday": "پریروز", "thisWeekday": "این {weekday}", "nextWeekday": "{weekday} آینده", "lastWeekday": "{weekday} گذشته"},
    "fi": {"today": "tänään", "tomorrow": "huomenna", "yesterday": "eilen", "dayAfterTomorrow": "ylihuomenna", "dayBeforeYesterday": "toissapäivänä", "thisWeekday": "tämä {weekday}", "nextWeekday": "ensi {weekday}", "lastWeekday": "viime {weekday}"},
    "fil": {"today": "ngayon", "tomorrow": "bukas", "yesterday": "kahapon", "dayAfterTomorrow": "samakalawa", "dayBeforeYesterday": "kamakalawa", "thisWeekday": "itong {weekday}", "nextWeekday": "susunod na {weekday}", "lastWeekday": "nakaraang {weekday}"},
    "fr": {"today": "aujourd'hui", "tomorrow": "demain", "yesterday": "hier", "dayAfterTomorrow": "après-demain", "dayBeforeYesterday": "avant-hier", "thisWeekday": "ce {weekday}", "nextWeekday": "{weekday} prochain", "lastWeekday": "{weekday} dernier"},
    "ga": {"today": "inniu", "tomorrow": "amárach", "yesterday": "inné", "dayAfterTomorrow": "arú amárach", "dayBeforeYesterday": "arú inné", "thisWeekday": "an {weekday} seo", "nextWeekday": "{weekday} seo chugainn", "lastWeekday": "{weekday} seo caite"},
    "gd": {"today": "an-diugh", "tomorrow": "a-màireach", "yesterday": "an-dè", "dayAfterTomorrow": "an-earar", "dayBeforeYesterday": "a-bhòin-dè", "thisWeekday": "{weekday} seo", "nextWeekday": "{weekday} sa tighinn", "lastWeekday": "{weekday} seo chaidh"},
    "gu": {"today": "આજે", "tomorrow": "આવતીકાલે", "yesterday": "ગઈકાલે", "dayAfterTomorrow": "પરમદિવસે", "dayBeforeYesterday": "ગયા પરમદિવસે", "thisWeekday": "આ {weekday}", "nextWeekday": "આવતા {weekday}", "lastWeekday": "ગયા {weekday}"},
    "gv": {"today": "jiu", "tomorrow": "mairagh", "yesterday": "jea", "dayAfterTomorrow": None, "dayBeforeYesterday": None, "thisWeekday": "y {weekday} shoh", "nextWeekday": "{weekday} cheet", "lastWeekday": "{weekday} shaghey"},
    "he": {"today": "היום", "tomorrow": "מחר", "yesterday": "אתמול", "dayAfterTomorrow": "מחרתיים", "dayBeforeYesterday": "שלשום", "thisWeekday": "{weekday} הזה", "nextWeekday": "{weekday} הבא", "lastWeekday": "{weekday} שעבר"},
    "hi": {"today": "आज", "tomorrow": "कल", "yesterday": "कल", "dayAfterTomorrow": "परसों", "dayBeforeYesterday": "परसों", "thisWeekday": "इस {weekday}", "nextWeekday": "अगले {weekday}", "lastWeekday": "पिछले {weekday}"},
    "hr": {"today": "danas", "tomorrow": "sutra", "yesterday": "jučer", "dayAfterTomorrow": "prekosutra", "dayBeforeYesterday": "prekjučer", "thisWeekday": "ovaj {weekday}", "nextWeekday": "sljedeći {weekday}", "lastWeekday": "prošli {weekday}"},
    "hu": {"today": "ma", "tomorrow": "holnap", "yesterday": "tegnap", "dayAfterTomorrow": "holnapután", "dayBeforeYesterday": "tegnapelőtt", "thisWeekday": "ezen a {weekday}", "nextWeekday": "jövő {weekday}", "lastWeekday": "múlt {weekday}"},
    "id": {"today": "hari ini", "tomorrow": "besok", "yesterday": "kemarin", "dayAfterTomorrow": "lusa", "dayBeforeYesterday": "kemarin lusa", "thisWeekday": "{weekday} ini", "nextWeekday": "{weekday} depan", "lastWeekday": "{weekday} lalu"},
    "it": {"today": "oggi", "tomorrow": "domani", "yesterday": "ieri", "dayAfterTomorrow": "dopodomani", "dayBeforeYesterday": "l'altro ieri", "thisWeekday": "questo {weekday}", "nextWeekday": "{weekday} prossimo", "lastWeekday": "{weekday} scorso"},
    "ja": {"today": "今日", "tomorrow": "明日", "yesterday": "昨日", "dayAfterTomorrow": "明後日", "dayBeforeYesterday": "一昨日", "thisWeekday": "今度の{weekday}", "nextWeekday": "来週の{weekday}", "lastWeekday": "先週の{weekday}"},
    "jv": {"today": "dina iki", "tomorrow": "sesuk", "yesterday": "wingi", "dayAfterTomorrow": "embèn", "dayBeforeYesterday": "dhèk wingi", "thisWeekday": "{weekday} iki", "nextWeekday": "{weekday} ngarep", "lastWeekday": "{weekday} wingi"},
    "ka": {"today": "დღეს", "tomorrow": "ხვალ", "yesterday": "გუშინ", "dayAfterTomorrow": "ზეგ", "dayBeforeYesterday": "გუშინწინ", "thisWeekday": "ამ {weekday}", "nextWeekday": "მომავალ {weekday}", "lastWeekday": "გასულ {weekday}"},
    "kk": {"today": "бүгін", "tomorrow": "ертең", "yesterday": "кеше", "dayAfterTomorrow": "бүрсігүні", "dayBeforeYesterday": "алдыңғы күні", "thisWeekday": "осы {weekday}", "nextWeekday": "келесі {weekday}", "lastWeekday": "өткен {weekday}"},
    "km": {"today": "ថ្ងៃនេះ", "tomorrow": "ថ្ងៃស្អែក", "yesterday": "ម្សិលមិញ", "dayAfterTomorrow": "ខានស្អែក", "dayBeforeYesterday": "ម្សិលម៉្ង៉ៃ", "thisWeekday": "{weekday}នេះ", "nextWeekday": "{weekday}ក្រោយ", "lastWeekday": "{weekday}មុន"},
    "ko": {"today": "오늘", "tomorrow": "내일", "yesterday": "어제", "dayAfterTomorrow": "모레", "dayBeforeYesterday": "그저께", "thisWeekday": "이번 {weekday}", "nextWeekday": "다음 {weekday}", "lastWeekday": "지난 {weekday}"},
    "kw": {"today": "hedhyw", "tomorrow": "a-vorow", "yesterday": "de", "dayAfterTomorrow": None, "dayBeforeYesterday": None, "thisWeekday": "an {weekday} ma", "nextWeekday": "{weekday} a dheu", "lastWeekday": "{weekday} eus passyes"},
    "lt": {"today": "šiandien", "tomorrow": "rytoj", "yesterday": "vakar", "dayAfterTomorrow": "poryt", "dayBeforeYesterday": "užvakar", "thisWeekday": "šį {weekday}", "nextWeekday": "kitą {weekday}", "lastWeekday": "praėjusį {weekday}"},
    "lv": {"today": "šodien", "tomorrow": "rīt", "yesterday": "vakar", "dayAfterTomorrow": "parīt", "dayBeforeYesterday": "aizvakar", "thisWeekday": "šī {weekday}", "nextWeekday": "nākamā {weekday}", "lastWeekday": "pagājusī {weekday}"},
    "mk": {"today": "денес", "tomorrow": "утре", "yesterday": "вчера", "dayAfterTomorrow": "задутре", "dayBeforeYesterday": "завчера", "thisWeekday": "оваа {weekday}", "nextWeekday": "следната {weekday}", "lastWeekday": "минатата {weekday}"},
    "mr": {"today": "आज", "tomorrow": "उद्या", "yesterday": "काल", "dayAfterTomorrow": "परवा", "dayBeforeYesterday": "परवा", "thisWeekday": "हा {weekday}", "nextWeekday": "पुढील {weekday}", "lastWeekday": "मागील {weekday}"},
    "ms": {"today": "hari ini", "tomorrow": "esok", "yesterday": "semalam", "dayAfterTomorrow": "lusa", "dayBeforeYesterday": "kelmarin", "thisWeekday": "{weekday} ini", "nextWeekday": "{weekday} depan", "lastWeekday": "{weekday} lepas"},
    "mt": {"today": "illum", "tomorrow": "għada", "yesterday": "ilbieraħ", "dayAfterTomorrow": "pitgħada", "dayBeforeYesterday": "il-bieraħ l-ieħor", "thisWeekday": "dan {weekday}", "nextWeekday": "{weekday} li ġej", "lastWeekday": "{weekday} li għadda"},
    "my": {"today": "ယနေ့", "tomorrow": "မနက်ဖြန်", "yesterday": "မနေ့က", "dayAfterTomorrow": "သန်ဘက်ခါ", "dayBeforeYesterday": "တစ်နေ့က", "thisWeekday": "ဒီ{weekday}", "nextWeekday": "နောက် {weekday}", "lastWeekday": "ပြီးခဲ့သော {weekday}"},
    "nb": {"today": "i dag", "tomorrow": "i morgen", "yesterday": "i går", "dayAfterTomorrow": "i overmorgen", "dayBeforeYesterday": "i forgårs", "thisWeekday": "denne {weekday}", "nextWeekday": "neste {weekday}", "lastWeekday": "forrige {weekday}"},
    "ne": {"today": "आज", "tomorrow": "भोलि", "yesterday": "हिजो", "dayAfterTomorrow": "पर्सि", "dayBeforeYesterday": "अस्ति", "thisWeekday": "यो {weekday}", "nextWeekday": "अर्को {weekday}", "lastWeekday": "गत {weekday}"},
    "nl": {"today": "vandaag", "tomorrow": "morgen", "yesterday": "gisteren", "dayAfterTomorrow": "overmorgen", "dayBeforeYesterday": "eergisteren", "thisWeekday": "deze {weekday}", "nextWeekday": "volgende {weekday}", "lastWeekday": "afgelopen {weekday}"},
    "pa": {"today": "ਅੱਜ", "tomorrow": "ਕੱਲ੍ਹ", "yesterday": "ਕੱਲ੍ਹ", "dayAfterTomorrow": "ਪਰਸੋਂ", "dayBeforeYesterday": "ਪਰਸੋਂ", "thisWeekday": "ਇਸ {weekday}", "nextWeekday": "ਅਗਲੇ {weekday}", "lastWeekday": "ਪਿਛਲੇ {weekday}"},
    "pl": {"today": "dzisiaj", "tomorrow": "jutro", "yesterday": "wczoraj", "dayAfterTomorrow": "pojutrze", "dayBeforeYesterday": "przedwczoraj", "thisWeekday": "ten {weekday}", "nextWeekday": "następny {weekday}", "lastWeekday": "zeszły {weekday}"},
    "pt": {"today": "hoje", "tomorrow": "amanhã", "yesterday": "ontem", "dayAfterTomorrow": "depois de amanhã", "dayBeforeYesterday": "anteontem", "thisWeekday": "esta {weekday}", "nextWeekday": "próxima {weekday}", "lastWeekday": "passada {weekday}"},
    "ro": {"today": "azi", "tomorrow": "mâine", "yesterday": "ieri", "dayAfterTomorrow": "poimâine", "dayBeforeYesterday": "alaltăieri", "thisWeekday": "această {weekday}", "nextWeekday": "{weekday} viitoare", "lastWeekday": "{weekday} trecută"},
    "ru": {"today": "сегодня", "tomorrow": "завтра", "yesterday": "вчера", "dayAfterTomorrow": "послезавтра", "dayBeforeYesterday": "позавчера", "thisWeekday": "эта {weekday}", "nextWeekday": "следующая {weekday}", "lastWeekday": "прошлая {weekday}"},
    "shi": {"today": "ⴰⵙⵙⴰ", "tomorrow": "ⴰⵙⴽⴽⴰ", "yesterday": "ⵉⴹⵍⵍⵉ", "dayAfterTomorrow": None, "dayBeforeYesterday": None, "thisWeekday": "{weekday} ⴰⴷ", "nextWeekday": "{weekday} ⴷ ⵉⴷⴷⴰⵏ", "lastWeekday": "{weekday} ⵉⵣⵔⵉⵏ"},
    "si": {"today": "අද", "tomorrow": "හෙට", "yesterday": "ඊයේ", "dayAfterTomorrow": "අනිද්දා", "dayBeforeYesterday": "පෙරේදා", "thisWeekday": "මේ {weekday}", "nextWeekday": "ඊළඟ {weekday}", "lastWeekday": "පසුගිය {weekday}"},
    "sk": {"today": "dnes", "tomorrow": "zajtra", "yesterday": "včera", "dayAfterTomorrow": "pozajtra", "dayBeforeYesterday": "predvčerom", "thisWeekday": "tento {weekday}", "nextWeekday": "budúci {weekday}", "lastWeekday": "minulý {weekday}"},
    "sl": {"today": "danes", "tomorrow": "jutri", "yesterday": "včeraj", "dayAfterTomorrow": "pojutrišnjem", "dayBeforeYesterday": "predvčerajšnjim", "thisWeekday": "ta {weekday}", "nextWeekday": "naslednji {weekday}", "lastWeekday": "prejšnji {weekday}"},
    "sq": {"today": "sot", "tomorrow": "nesër", "yesterday": "dje", "dayAfterTomorrow": "pasnesër", "dayBeforeYesterday": "pardje", "thisWeekday": "këtë {weekday}", "nextWeekday": "{weekday} tjetër", "lastWeekday": "{weekday} e kaluar"},
    "sr": {"today": "данас", "tomorrow": "сутра", "yesterday": "јуче", "dayAfterTomorrow": "прекосутра", "dayBeforeYesterday": "прекјуче", "thisWeekday": "овај {weekday}", "nextWeekday": "следећи {weekday}", "lastWeekday": "прошли {weekday}"},
    "sv": {"today": "idag", "tomorrow": "imorgon", "yesterday": "igår", "dayAfterTomorrow": "i övermorgon", "dayBeforeYesterday": "i förrgår", "thisWeekday": "denna {weekday}", "nextWeekday": "nästa {weekday}", "lastWeekday": "förra {weekday}"},
    "sw": {"today": "leo", "tomorrow": "kesho", "yesterday": "jana", "dayAfterTomorrow": "kesho kutwa", "dayBeforeYesterday": "juzi", "thisWeekday": "{weekday} hii", "nextWeekday": "{weekday} ijayo", "lastWeekday": "{weekday} iliyopita"},
    "ta": {"today": "இன்று", "tomorrow": "நாளை", "yesterday": "நேற்று", "dayAfterTomorrow": "நாளை மறுநாள்", "dayBeforeYesterday": "முந்தா நாள்", "thisWeekday": "இந்த {weekday}", "nextWeekday": "அடுத்த {weekday}", "lastWeekday": "கடந்த {weekday}"},
    "te": {"today": "ఈ రోజు", "tomorrow": "రేపు", "yesterday": "నిన్న", "dayAfterTomorrow": "ఎల్లుండి", "dayBeforeYesterday": "మొన్న", "thisWeekday": "ఈ {weekday}", "nextWeekday": "వచ్చే {weekday}", "lastWeekday": "గత {weekday}"},
    "th": {"today": "วันนี้", "tomorrow": "พรุ่งนี้", "yesterday": "เมื่อวาน", "dayAfterTomorrow": "มะรืน", "dayBeforeYesterday": "เมื่อวานซืน", "thisWeekday": "{weekday}นี้", "nextWeekday": "{weekday}หน้า", "lastWeekday": "{weekday}ที่แล้ว"},
    "tr": {"today": "bugün", "tomorrow": "yarın", "yesterday": "dün", "dayAfterTomorrow": "öbür gün", "dayBeforeYesterday": "evvelsi gün", "thisWeekday": "bu {weekday}", "nextWeekday": "gelecek {weekday}", "lastWeekday": "geçen {weekday}"},
    "tzm": {"today": "ⴰⵙⵙⴰ", "tomorrow": "ⴰⵙⴽⴽⴰ", "yesterday": "ⵉⴹⵍⵍⵉ", "dayAfterTomorrow": None, "dayBeforeYesterday": None, "thisWeekday": "{weekday} ⴰⴷ", "nextWeekday": "{weekday} ⴷ ⵉⴷⴷⴰⵏ", "lastWeekday": "{weekday} ⵉⵣⵔⵉⵏ"},
    "uk": {"today": "сьогодні", "tomorrow": "завтра", "yesterday": "вчора", "dayAfterTomorrow": "післязавтра", "dayBeforeYesterday": "позавчора", "thisWeekday": "цієї {weekday}", "nextWeekday": "наступної {weekday}", "lastWeekday": "минулої {weekday}"},
    "ur": {"today": "آج", "tomorrow": "کل", "yesterday": "کل", "dayAfterTomorrow": "پرسوں", "dayBeforeYesterday": "پرسوں", "thisWeekday": "اس {weekday}", "nextWeekday": "اگلے {weekday}", "lastWeekday": "پچھلے {weekday}"},
    "uz": {"today": "bugun", "tomorrow": "ertaga", "yesterday": "kecha", "dayAfterTomorrow": "indinga", "dayBeforeYesterday": "kechagina", "thisWeekday": "bu {weekday}", "nextWeekday": "keyingi {weekday}", "lastWeekday": "o'tgan {weekday}"},
    "vi": {"today": "hôm nay", "tomorrow": "ngày mai", "yesterday": "hôm qua", "dayAfterTomorrow": "ngày kia", "dayBeforeYesterday": "hôm kia", "thisWeekday": "{weekday} này", "nextWeekday": "{weekday} tới", "lastWeekday": "{weekday} trước"},
    "zh": {"today": "今天", "tomorrow": "明天", "yesterday": "昨天", "dayAfterTomorrow": "后天", "dayBeforeYesterday": "前天", "thisWeekday": "这个{weekday}", "nextWeekday": "下{weekday}", "lastWeekday": "上{weekday}"},
}


def _get_day_format(code: str) -> tuple[str, dict[str, str]]:
    """Get ordinal day format for a locale."""
    if code in _DAY_FORMAT:
        return _DAY_FORMAT[code]
    return _DAY_FORMAT["default"]


def _get_date_pattern(code: str) -> tuple[str, str]:
    """Get date pattern for a locale."""
    if code in _DATE_PATTERNS:
        return _DATE_PATTERNS[code]
    return _DATE_PATTERNS["default"]


def _get_compact_pattern(code: str) -> tuple[str, str]:
    """Get compact date pattern for a locale."""
    if code in _COMPACT_PATTERNS:
        return _COMPACT_PATTERNS[code]
    return _COMPACT_PATTERNS["default"]


def _get_short_pattern(code: str) -> tuple[str, str]:
    """Get short date pattern for a locale."""
    if code in _SHORT_PATTERNS:
        return _SHORT_PATTERNS[code]
    return _SHORT_PATTERNS["default"]


def build_locale(code: str, name: str) -> dict:
    """Build a complete date locale dict for the given code."""
    months = _MONTHS.get(code, _MONTHS["en"])
    weekdays = _WEEKDAYS.get(code, _WEEKDAYS["en"])
    short_months = _SHORT_MONTHS.get(code, _SHORT_MONTHS["en"])
    short_weekdays = _SHORT_WEEKDAYS.get(code, _SHORT_WEEKDAYS["en"])

    day_fmt, day_exc = _get_day_format(code)
    date_pat, date_pat_year = _get_date_pattern(code)
    compact_pat, compact_pat_year = _get_compact_pattern(code)
    short_pat, short_pat_year = _get_short_pattern(code)

    rel = _RELATIVE.get(code, _RELATIVE["en"])

    locale: dict = {
        "code": code,
        "name": name,
        "months": months,
        "weekdays": weekdays,
        "dayFormat": day_fmt,
    }

    if day_exc:
        locale["dayFormatExceptions"] = day_exc

    locale["datePattern"] = date_pat
    locale["datePatternWithYear"] = date_pat_year
    locale["today"] = rel["today"]
    locale["tomorrow"] = rel["tomorrow"]
    locale["yesterday"] = rel["yesterday"]

    if rel.get("dayAfterTomorrow"):
        locale["dayAfterTomorrow"] = rel["dayAfterTomorrow"]
    if rel.get("dayBeforeYesterday"):
        locale["dayBeforeYesterday"] = rel["dayBeforeYesterday"]
    if rel.get("thisWeekday"):
        locale["thisWeekday"] = rel["thisWeekday"]
    if rel.get("nextWeekday"):
        locale["nextWeekday"] = rel["nextWeekday"]
    if rel.get("lastWeekday"):
        locale["lastWeekday"] = rel["lastWeekday"]

    if code in _MONTHS_IN_DATE:
        locale["monthsInDate"] = _MONTHS_IN_DATE[code]

    # Short override
    short: dict = {}
    short["months"] = short_months
    short["weekdays"] = short_weekdays

    # Short uses bare number for day format unless locale has specific short ordinal
    short_day_fmt = "{n}"
    # German-style locales keep the period in short mode too
    if day_fmt.endswith("."):
        short_day_fmt = "{n}."
    # CJK locales keep their suffix
    if code in ("ja", "ko", "zh"):
        short_day_fmt = day_fmt
    short["dayFormat"] = short_day_fmt

    short["datePattern"] = short_pat
    short["datePatternWithYear"] = short_pat_year

    locale["short"] = short

    # Compact override
    compact: dict = {}
    compact["datePattern"] = compact_pat
    compact["datePatternWithYear"] = compact_pat_year
    locale["compact"] = compact

    return locale


def main() -> None:
    os.makedirs(DATE_LOCALES, exist_ok=True)

    # Read all age locales to get code/name pairs
    age_locales = []
    for fname in sorted(os.listdir(AGE_LOCALES)):
        if not fname.endswith(".json"):
            continue
        with open(os.path.join(AGE_LOCALES, fname), encoding="utf-8") as f:
            data = json.load(f)
            age_locales.append((data["code"], data["name"]))

    generated = 0
    skipped = 0
    for code, name in age_locales:
        if code not in _MONTHS:
            print(f"  SKIP {code} ({name}) — no month data")
            skipped += 1
            continue
        if code not in _WEEKDAYS:
            print(f"  SKIP {code} ({name}) — no weekday data")
            skipped += 1
            continue
        if code not in _RELATIVE:
            print(f"  SKIP {code} ({name}) — no relative data")
            skipped += 1
            continue

        locale = build_locale(code, name)
        out = os.path.join(DATE_LOCALES, f"{code}.json")
        with open(out, "w", encoding="utf-8") as f:
            json.dump(locale, f, ensure_ascii=False, indent=2)
            f.write("\n")
        generated += 1

    print(f"\nGenerated {generated} locale files, skipped {skipped}")


if __name__ == "__main__":
    main()
