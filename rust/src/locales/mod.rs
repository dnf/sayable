//! Built-in locale definitions for 49 languages.
//!
//! Each submodule exports a `locale()` function returning an [`AgeLocale`].
//! Prefer using the static constants (e.g., [`EN`], [`JA`]) for lazy-initialized access.

#![allow(missing_docs)]

pub mod ar;
pub mod bg;
pub mod bn;
pub mod bs;
pub mod ca;
pub mod cs;
pub mod da;
pub mod de;
pub mod el;
pub mod en;
pub mod es;
pub mod et;
pub mod eu;
pub mod fa;
pub mod fi;
pub mod fr;
pub mod ga;
pub mod gu;
pub mod hi;
pub mod hr;
pub mod hu;
pub mod it;
pub mod ja;
pub mod jv;
pub mod ko;
pub mod lt;
pub mod lv;
pub mod mr;
pub mod ms;
pub mod nb;
pub mod nl;
pub mod pa;
pub mod pl;
pub mod pt;
pub mod ro;
pub mod ru;
pub mod sk;
pub mod sl;
pub mod sq;
pub mod sr;
pub mod sv;
pub mod ta;
pub mod te;
pub mod th;
pub mod tr;
pub mod uk;
pub mod ur;
pub mod vi;
pub mod zh;

use crate::types::AgeLocale;

// Locale constants using thread_local for zero-cost initialization.
// Each locale is constructed once per use via its locale() function.

/// Arabic locale constant.
pub static AR: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(ar::locale);
/// Bulgarian locale constant.
pub static BG: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(bg::locale);
/// Bengali locale constant.
pub static BN: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(bn::locale);
/// Bosnian locale constant.
pub static BS: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(bs::locale);
/// Catalan locale constant.
pub static CA: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(ca::locale);
/// Czech locale constant.
pub static CS: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(cs::locale);
/// Danish locale constant.
pub static DA: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(da::locale);
/// German locale constant.
pub static DE: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(de::locale);
/// Greek locale constant.
pub static EL: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(el::locale);
/// English locale constant.
pub static EN: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(en::locale);
/// Spanish locale constant.
pub static ES: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(es::locale);
/// Estonian locale constant.
pub static ET: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(et::locale);
/// Basque locale constant.
pub static EU: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(eu::locale);
/// Persian locale constant.
pub static FA: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(fa::locale);
/// Finnish locale constant.
pub static FI: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(fi::locale);
/// French locale constant.
pub static FR: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(fr::locale);
/// Irish locale constant.
pub static GA: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(ga::locale);
/// Gujarati locale constant.
pub static GU: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(gu::locale);
/// Hindi locale constant.
pub static HI: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(hi::locale);
/// Croatian locale constant.
pub static HR: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(hr::locale);
/// Hungarian locale constant.
pub static HU: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(hu::locale);
/// Italian locale constant.
pub static IT: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(it::locale);
/// Japanese locale constant.
pub static JA: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(ja::locale);
/// Javanese locale constant.
pub static JV: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(jv::locale);
/// Korean locale constant.
pub static KO: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(ko::locale);
/// Lithuanian locale constant.
pub static LT: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(lt::locale);
/// Latvian locale constant.
pub static LV: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(lv::locale);
/// Marathi locale constant.
pub static MR: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(mr::locale);
/// Malay locale constant.
pub static MS: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(ms::locale);
/// Norwegian Bokmål locale constant.
pub static NB: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(nb::locale);
/// Dutch locale constant.
pub static NL: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(nl::locale);
/// Punjabi locale constant.
pub static PA: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(pa::locale);
/// Polish locale constant.
pub static PL: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(pl::locale);
/// Portuguese locale constant.
pub static PT: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(pt::locale);
/// Romanian locale constant.
pub static RO: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(ro::locale);
/// Russian locale constant.
pub static RU: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(ru::locale);
/// Slovak locale constant.
pub static SK: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(sk::locale);
/// Slovenian locale constant.
pub static SL: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(sl::locale);
/// Albanian locale constant.
pub static SQ: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(sq::locale);
/// Serbian locale constant.
pub static SR: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(sr::locale);
/// Swedish locale constant.
pub static SV: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(sv::locale);
/// Tamil locale constant.
pub static TA: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(ta::locale);
/// Telugu locale constant.
pub static TE: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(te::locale);
/// Thai locale constant.
pub static TH: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(th::locale);
/// Turkish locale constant.
pub static TR: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(tr::locale);
/// Ukrainian locale constant.
pub static UK: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(uk::locale);
/// Urdu locale constant.
pub static UR: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(ur::locale);
/// Vietnamese locale constant.
pub static VI: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(vi::locale);
/// Chinese locale constant.
pub static ZH: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new(zh::locale);
