# sayable-time — Pascal

Human-friendly clock time formatting — tells time the way people talk.

```pascal
uses SayableTime, SayableTimeLocales;
var Loc: TTimeLocale;
begin
  GetTimeLocale_en(Loc);
  WriteLn(FormatTime(Loc, tcNormal, '14:15'));  // "a quarter past two"
end.
```

## Installation

Copy the Pascal units into your project. Requires Free Pascal 3.2+. Zero external dependencies.

## Usage

```pascal
program Example;
uses SayableTimeTypes, SayableTime, SayableTimeLocales;

var
  EN: TTimeLocale;
  Result: string;
begin
  GetTimeLocale_en(EN);

  // Natural language clock time
  WriteLn(FormatTime(EN, tcNormal, '00:00'));   // "midnight"
  WriteLn(FormatTime(EN, tcNormal, '12:00'));   // "noon"
  WriteLn(FormatTime(EN, tcNormal, '15:00'));   // "three o'clock"
  WriteLn(FormatTime(EN, tcNormal, '14:15'));   // "a quarter past two"
  WriteLn(FormatTime(EN, tcNormal, '09:30'));   // "half past nine"
  WriteLn(FormatTime(EN, tcNormal, '10:45'));   // "a quarter to eleven"

  // Digital time
  WriteLn(FormatTime(EN, tcShort, '14:15'));    // "2:15 PM"
  WriteLn(FormatTime(EN, tcCompact, '14:15'));  // "2:15p"

  // Null check
  Result := FormatTime(EN, tcNormal, '');
  if IsTimeNullResult(Result) then
    WriteLn('null');
end.
```

## Internationalization

```pascal
var DE: TTimeLocale;
begin
  GetTimeLocale_de(DE);
  WriteLn(FormatTime(DE, tcNormal, '15:30'));  // "halb vier"
end.
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```pascal
WriteLn(FormatTime(EN, tcNormal,  '14:15'));  // "a quarter past two"
WriteLn(FormatTime(EN, tcShort,   '14:15'));  // "2:15 PM"
WriteLn(FormatTime(EN, tcCompact, '14:15'));  // "2:15p"
```

## API

```pascal
function FormatTime(const ALocale: TTimeLocale; ACompactness: TTimeCompactness;
  const AInput: string): string;

function GetTimeLocale(const ACode: string): TTimeLocalePtr;

function IsTimeNullResult(const AResult: string): Boolean;
```

**Parameters:**

- `AInput` — Time as `HH:MM` or ISO datetime string.

**Returns:** A string result. Use `IsTimeNullResult()` to check for null (empty/invalid input).

## Development

```bash
fpc -FEbuild -FUbuild -Fulocales test_format_time.pas && ./build/test_format_time
```

## License

[MIT](../../LICENSE.md)
