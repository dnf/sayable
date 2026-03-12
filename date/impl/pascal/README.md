# sayable-date — Pascal

Human-friendly date formatting — how people reference dates in conversation.

```pascal
uses SayableDate, SayableDateLocales;
var Loc: TDateLocale;
begin
  GetDateLocale_en(Loc);
  WriteLn(FormatDate(Loc, dcNormal, '2025-03-15'));  // "March 15th"
end.
```

## Installation

Copy the Pascal units into your project. Requires Free Pascal 3.2+. Zero external dependencies.

## Usage

```pascal
program Example;
uses SayableDateTypes, SayableDate, SayableDateLocales;

var
  EN: TDateLocale;
  Result: string;
begin
  GetDateLocale_en(EN);

  // Absolute date formatting
  WriteLn(FormatDate(EN, dcNormal, '2025-03-15'));      // "March 15th"
  WriteLn(FormatDate(EN, dcNormal, '2025-01-01'));      // "January 1st"
  WriteLn(FormatDateWithYear(EN, dcNormal, '2025-03-15'));  // "March 15th, 2025"

  // Relative date formatting
  WriteLn(FormatRelative(EN, dcNormal, '2025-03-16', '2025-03-15'));  // "tomorrow"
  WriteLn(FormatRelative(EN, dcNormal, '2025-03-14', '2025-03-15'));  // "yesterday"
  WriteLn(FormatRelative(EN, dcNormal, '2025-03-19', '2025-03-15'));  // "this Wednesday"

  // Null check
  Result := FormatDate(EN, dcNormal, '');
  if IsDateNullResult(Result) then
    WriteLn('null');
end.
```

## Internationalization

```pascal
var DE: TDateLocale;
begin
  GetDateLocale_de(DE);
  WriteLn(FormatDate(DE, dcNormal, '2025-03-15'));  // "15. März"
end.
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```pascal
WriteLn(FormatDate(EN, dcNormal,  '2025-03-15'));  // "March 15th"
WriteLn(FormatDate(EN, dcShort,   '2025-03-15'));  // "Mar 15"
WriteLn(FormatDate(EN, dcCompact, '2025-03-15'));  // "3/15"
```

## API

```pascal
function FormatDate(const ALocale: TDateLocale; ACompactness: TDateCompactness;
  const ADate: string): string;

function FormatDateWithYear(const ALocale: TDateLocale; ACompactness: TDateCompactness;
  const ADate: string): string;

function FormatRelative(const ALocale: TDateLocale; ACompactness: TDateCompactness;
  const ADate, AAsOf: string): string;

function GetDateLocale(const ACode: string): TDateLocalePtr;

function IsDateNullResult(const AResult: string): Boolean;
```

**Parameters:**

- `ADate` — `YYYY-MM-DD` string or ISO datetime.
- `AAsOf` — Reference date as `YYYY-MM-DD`.

**Returns:** A string result. Use `IsDateNullResult()` to check for null (empty/invalid input).

## Development

```bash
fpc -FEbuild -FUbuild -Fulocales test_format_date.pas && ./build/test_format_date
```

## License

[MIT](../../LICENSE.md)
