# sayable-duration — Pascal

Human-friendly duration and relative time formatting — how people talk about time spans.

```pascal
uses SayableDuration, SayableDurationLocales;
var Loc: TDurationLocale;
begin
  GetDurLocale_en(Loc);
  WriteLn(FormatDuration(Loc, durNormal, 5400));  // "1½ hours"
end.
```

## Installation

Copy the Pascal units into your project. Requires Free Pascal 3.2+. Zero external dependencies.

## Usage

```pascal
program Example;
uses SayableDurationTypes, SayableDuration, SayableDurationLocales;

var
  EN: TDurationLocale;
  Result: string;
begin
  GetDurLocale_en(EN);

  // Duration from seconds
  WriteLn(FormatDuration(EN, durNormal, 0));      // "just now"
  WriteLn(FormatDuration(EN, durNormal, 45));     // "45 seconds"
  WriteLn(FormatDuration(EN, durNormal, 3600));   // "1 hour"
  WriteLn(FormatDuration(EN, durNormal, 5400));   // "1½ hours"
  WriteLn(FormatDuration(EN, durNormal, 86400));  // "1 day"

  // Duration from ISO timestamps
  WriteLn(FormatDurationISO(EN, durNormal,
    '2025-01-15T10:00:00', '2025-01-15T11:30:00'));  // "1½ hours"

  // Relative time
  WriteLn(FormatSince(EN, durNormal,
    '2025-01-15T10:00:00', '2025-01-15T10:45:00'));  // "45 minutes ago"
  WriteLn(FormatUntil(EN, durNormal,
    '2025-01-15T13:00:00', '2025-01-15T10:00:00'));  // "in 3 hours"

  // Null check
  Result := FormatDuration(EN, durNormal, -1);
  if IsDurNullResult(Result) then
    WriteLn('null');
end.
```

## Internationalization

```pascal
var DE: TDurationLocale;
begin
  GetDurLocale_de(DE);
  WriteLn(FormatDuration(DE, durNormal, 3600));  // "1 Stunde"
end.
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```pascal
WriteLn(FormatDuration(EN, durNormal,  3600));  // "1 hour"
WriteLn(FormatDuration(EN, durShort,   3600));  // "1h"
WriteLn(FormatDuration(EN, durCompact, 3600));  // "1h"
```

## API

```pascal
function FormatDuration(const ALocale: TDurationLocale; ACompactness: TDurCompactness;
  ATotalSeconds: Int64): string;

function FormatDurationISO(const ALocale: TDurationLocale; ACompactness: TDurCompactness;
  const AStart, AEnd: string): string;

function FormatSince(const ALocale: TDurationLocale; ACompactness: TDurCompactness;
  const AStart, AAsOf: string): string;

function FormatUntil(const ALocale: TDurationLocale; ACompactness: TDurCompactness;
  const ATarget, AAsOf: string): string;

function GetDurLocale(const ACode: string): TDurationLocalePtr;

function IsDurNullResult(const AResult: string): Boolean;
```

**Parameters:**

- `ATotalSeconds` — Duration in seconds (negative returns null).
- `AStart`, `AEnd`, `AAsOf`, `ATarget` — ISO 8601 datetime strings.

**Returns:** A string result. Use `IsDurNullResult()` to check for null (invalid input, negative duration).

## Development

```bash
fpc -FEbuild -FUbuild -Fulocales test_format_duration.pas && ./build/test_format_duration
```

## License

[MIT](../../LICENSE.md)
