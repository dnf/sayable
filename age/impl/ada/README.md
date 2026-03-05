# sayable-age -- Ada

Human-friendly age formatting — how parents actually talk about little ones.

```ada
with Parenttime;
with Parenttime_Types; use Parenttime_Types;
with Parenttime_Locales;

Loc : Locale_Access := Parenttime_Locales.Get_Locale ("en");
Put_Line (Parenttime.Format_Age (Loc.all, Normal, "2025-06-01", "2025-06-15"));
--  "2 weeks"
```

## Building

GPRbuild project with Ada 2012 -- no external dependencies.

```bash
cd src/ada
gprbuild -P sayableage.gpr -XBUILD_MODE=build
```

Requires GNAT (GCC Ada compiler) and GPRbuild.

## Usage

```ada
with Parenttime;
with Parenttime_Types; use Parenttime_Types;
with Parenttime_Locales;

procedure Example is
   Loc    : Locale_Access := Parenttime_Locales.Get_Locale ("en");
   Result : constant String :=
     Parenttime.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15");
begin
   Put_Line (Result);  --  "6 months"

   Put_Line (Parenttime.Format_Stage (Loc.all, "2025-01-15", "2025-06-15"));
   --  "Infant"
end Example;
```

## Internationalization

```ada
Ja : Locale_Access := Parenttime_Locales.Get_Locale ("ja");
Put_Line (Parenttime.Format_Age (Ja.all, Normal, "2025-01-01", "2025-07-15"));
--  "6ヶ月"
```

110 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

```ada
function Format_Age
  (Loc   : Locale;
   Comp  : Compactness;       --  Normal, Short, or Compact
   DOB   : String;            --  YYYY-MM-DD
   As_Of : String) return String;

function Format_Stage
  (Loc    : Locale;
   DOB    : String;
   As_Of  : String;
   Gender : String := "") return String;  --  "m" or "f"

function Get_Locale (Code : String) return Locale_Access;
```

**Parameters:**

- `DOB` -- `YYYY-MM-DD` string.
- `As_Of` -- Reference date (`YYYY-MM-DD`).

**Returns:** `Format_Age` and `Format_Stage` return strings. `Get_Locale` returns an access type (null if the code is not found).

## Development

```bash
gprbuild -P sayableage.gpr -XBUILD_MODE=test
./build/test_format_age
```

## License

[MIT](../../LICENSE.md)
