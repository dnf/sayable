# sayable-age — Elm

Human-friendly age formatting — how parents actually talk about little ones.
Pure functions, no IO.

```elm
import SayableAge.Formatter exposing (formatAge)
import SayableAge.Types exposing (Compactness(..))
import SayableAge.Locales.En as En

formatAge En.locale Normal "2025-01-15" "2025-07-15" == Just "6 months"
```

## Setup

Elm 0.19 application (not published to the Elm package registry). Add as a local source dependency in your `elm.json`:

```json
{
    "type": "application",
    "source-directories": [
        "src",
        "path/to/age/impl/elm/src"
    ]
}
```

Only depends on `elm/core`. Zero external dependencies.

## Usage

```elm
import SayableAge.Formatter exposing (formatAge, formatStage)
import SayableAge.Types exposing (Compactness(..))
import SayableAge.Locales.En as En

formatAge En.locale Normal "2025-01-15" "2025-07-15"
-- Just "6 months"

formatStage En.locale "2025-01-15" "2025-06-15" Nothing
-- Just "Infant"
```

## Internationalization

```elm
import SayableAge.Locales.Ja as Ja

formatAge Ja.locale Normal "2025-01-01" "2025-07-15"
-- Just "6ヶ月"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

```elm
formatAge   : Locale -> Compactness -> String -> String -> Maybe String
formatStage : Locale -> String -> String -> Maybe Gender -> Maybe String
```

Both functions are pure — no `Cmd`, no `Task`, no side effects.

**Parameters:**

- `locale` — A `Locale` record (e.g., `En.locale`).
- `Compactness` — `Normal`, `Short`, or `Compact`.
- `dob` — `"YYYY-MM-DD"` string. Returns `Nothing` for empty strings.
- `asOf` — Reference date (`"YYYY-MM-DD"`).

**Returns:** `Maybe String` — `Just` the formatted string, or `Nothing` on invalid input.

## Development

```bash
elm-test    # Run tests
```

## License

[MIT](../../LICENSE.md)
