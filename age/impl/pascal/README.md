# sayable-age — Pascal

Human-friendly age formatting — how parents actually talk about little ones.

```pascal
uses SayableAge, SayableAgeLocales;
var Loc: TAgeLocale;
begin
  GetLocale_en(Loc);
  WriteLn(FormatAge(Loc, csNormal, '2025-06-01', '2025-06-15'));  // "2 weeks"
end.
```

## Installation

Copy the Pascal units into your project. Requires Free Pascal 3.2+. Zero external dependencies.

## Usage

```pascal
program Example;
uses SayableAgeTypes, SayableAge, SayableAgeLocales;

var
  EN: TAgeLocale;
  Result: string;
begin
  GetLocale_en(EN);

  // Human-readable age string
  WriteLn(FormatAge(EN, csNormal, '2025-06-15', '2025-06-15'));  // "Newborn"
  WriteLn(FormatAge(EN, csNormal, '2025-06-01', '2025-06-15'));  // "2 weeks"
  WriteLn(FormatAge(EN, csNormal, '2025-01-15', '2025-07-15'));  // "6 months"
  WriteLn(FormatAge(EN, csNormal, '2022-06-15', '2025-12-15'));  // "3½ years"

  // Developmental stage label
  WriteLn(FormatStage(EN, '2025-06-15', '2025-06-15', ''));  // "Newborn"
  WriteLn(FormatStage(EN, '2025-01-15', '2025-06-15', ''));  // "Infant"

  // Null check
  Result := FormatAge(EN, csNormal, '', '2025-06-15');
  if IsNullResult(Result) then
    WriteLn('null');
end.
```

## Internationalization

```pascal
var ES: TAgeLocale;
begin
  GetLocale_es(ES);
  WriteLn(FormatAge(ES, csNormal, '2025-01-01', '2025-07-15'));  // "6 meses"
end.
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```pascal
WriteLn(FormatAge(EN, csNormal,  '2025-01-15', '2025-07-15'));  // "6 months"
WriteLn(FormatAge(EN, csShort,   '2025-01-15', '2025-07-15'));  // "6 mo"
WriteLn(FormatAge(EN, csCompact, '2025-01-15', '2025-07-15'));  // "6m"
```

## API

```pascal
function FormatAge(const ALocale: TAgeLocale; ACompactness: TCompactness;
  const ADateOfBirth, AAsOf: string): string;

function FormatStage(const ALocale: TAgeLocale; const ADateOfBirth,
  AAsOf, AGender: string): string;

function GetLocale(const ACode: string): TAgeLocalePtr;

function IsNullResult(const AResult: string): Boolean;
```

**Parameters:**

- `ADateOfBirth` — `YYYY-MM-DD` string.
- `AAsOf` — Reference date as `YYYY-MM-DD`.
- `AGender` — `'m'` or `'f'` for gendered stage labels, empty for default.

**Returns:** A string result. Use `IsNullResult()` to check for null (empty/invalid input, future DOB, or age exceeding 500 years).

## Development

```bash
fpc -FEbuild -FUbuild -Fulocales test_format_age.pas && ./build/test_format_age
```

## License

[MIT](../../LICENSE.md)
