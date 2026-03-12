## Locale definitions for duration formatting.

import std/[options, tables]

type
  PluralCategory* = enum
    pcZero = "zero"
    pcOne = "one"
    pcTwo = "two"
    pcFew = "few"
    pcMany = "many"
    pcOther = "other"

  UnitForms* = object
    case isSimple*: bool
    of true:
      template_str*: string
    of false:
      forms*: OrderedTable[PluralCategory, string]

  CompactnessOverride* = object
    units*: Option[OrderedTable[string, UnitForms]]
    half*: Option[string]
    delimiter*: Option[string]
    ago*: Option[string]
    inFuture*: Option[string]

  DurationLocale* = object
    code*: string
    plural*: proc(n: int): PluralCategory {.noSideEffect.}
    units*: OrderedTable[string, UnitForms]
    half*: string
    delimiter*: string
    justNow*: string
    ago*: string
    inFuture*: string
    short*: Option[CompactnessOverride]
    compact*: Option[CompactnessOverride]

  Compactness* = enum
    cNormal = "normal"
    cShort = "short"
    cCompact = "compact"


proc simpleUnit*(tmpl: string): UnitForms =
  UnitForms(isSimple: true, template_str: tmpl)

proc pluralUnit*(pairs: openArray[(PluralCategory, string)]): UnitForms =
  var t: OrderedTable[PluralCategory, string]
  for (cat, val) in pairs:
    t[cat] = val
  UnitForms(isSimple: false, forms: t)


proc resolveUnit*(count: int, unitForms: UnitForms,
    locale: DurationLocale, half: string = ""): string =
  ## Resolve a unit count to its display string using locale rules.
  let baseN = $count
  var n = baseN
  if half.len > 0 and "{n}" in half:
    n = half.replace("{n}", baseN)

  var tmpl: string
  if unitForms.isSimple:
    tmpl = unitForms.template_str
  else:
    # Half-marked values use "other" plural (e.g. "1½ hours" not "1½ hour")
    let cat = if half.len > 0: pcOther else: locale.plural(count)
    if cat in unitForms.forms:
      tmpl = unitForms.forms[cat]
    else:
      tmpl = unitForms.forms[pcOther]

  result = tmpl.replace("{n}", n)

  if half.len > 0 and "{0}" in half:
    result = half.replace("{0}", result)
