## Locale definitions for age formatting.

import std/[options, tables, strutils]

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

  StageLabel* = object
    case isGendered*: bool
    of true:
      masculine*: string
      feminine*: string
    of false:
      label*: string

  CompactnessOverride* = object
    units*: Option[OrderedTable[string, UnitForms]]
    half*: Option[string]
    delimiter*: Option[string]
    justBorn*: Option[string]

  AgeLocale* = object
    code*: string
    plural*: proc(n: int): PluralCategory {.noSideEffect.}
    units*: OrderedTable[string, UnitForms]
    half*: string
    delimiter*: string
    justBorn*: string
    stages*: OrderedTable[string, StageLabel]
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

proc stageNeutral*(s: string): StageLabel =
  StageLabel(isGendered: false, label: s)

proc stageGendered*(m, f: string): StageLabel =
  StageLabel(isGendered: true, masculine: m, feminine: f)


proc resolveUnit*(count: int, unitForms: UnitForms, locale: AgeLocale,
    half: string = ""): string =
  ## Resolve a unit count to its display string using locale rules.
  let baseN = $count
  var n = baseN
  if half.len > 0 and "{n}" in half:
    n = half.replace("{n}", baseN)

  var tmpl: string
  if unitForms.isSimple:
    tmpl = unitForms.template_str
  else:
    let cat = locale.plural(count)
    if cat in unitForms.forms:
      tmpl = unitForms.forms[cat]
    else:
      tmpl = unitForms.forms[pcOther]

  result = tmpl.replace("{n}", n)

  if half.len > 0 and "{0}" in half:
    result = half.replace("{0}", result)


proc resolveStage*(label: StageLabel, gender: string = ""): string =
  ## Resolve a stage label, optionally selecting a gendered variant.
  if not label.isGendered:
    return label.label
  if gender == "f":
    return label.feminine
  return label.masculine
