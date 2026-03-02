# parent-time — Haskell

A thoughtful time formatting library that reflects how we think about little ones.

```haskell
import ParentTime.Formatter (formatAgePure)
import ParentTime.Types (Compactness(..))
import qualified ParentTime.Locales.En as En

formatAgePure En.locale Normal "2025-06-01" "2025-06-15"
-- Just "2 weeks"
```

## Setup

Cabal project. Not published to Hackage — use as a local dependency.

```bash
cd src/haskell
cabal build
```

Requires GHC 9.2+ and `base >= 4.16`. Zero external dependencies beyond `base`.

## Usage

```haskell
import ParentTime.Formatter (formatAgePure, formatStagePure)
import ParentTime.Types (Compactness(..))
import qualified ParentTime.Locales.En as En

formatAgePure En.locale Normal "2025-01-15" "2025-07-15"
-- Just "6 months"

formatStagePure En.locale "2025-01-15" "2025-06-15" Nothing
-- Just "Infant"
```

## Internationalization

```haskell
import qualified ParentTime.Locales.Ja as Ja

formatAgePure Ja.locale Normal "2025-01-01" "2025-07-15"
-- Just "6ヶ月"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

```haskell
formatAgePure   :: Locale -> Compactness -> String -> String -> Maybe String
formatStagePure :: Locale -> String -> String -> Maybe Gender -> Maybe String

formatAge       :: Locale -> Compactness -> String -> IO (Maybe String)
formatStage     :: Locale -> String -> Maybe Gender -> IO (Maybe String)
```

The `Pure` variants take an explicit `asOf` date. The IO variants default to today.

**Parameters:**

- `locale` — A `Locale` value (e.g., `En.locale`).
- `Compactness` — `Normal`, `Short`, or `Compact`.
- `dob` — `"YYYY-MM-DD"` string. Returns `Nothing` for empty strings.
- `asOf` — Reference date (`"YYYY-MM-DD"`).

**Returns:** `Maybe String` — `Just` the formatted string, or `Nothing` on invalid input.

## Development

```bash
cabal test       # Run tests
cabal build      # Build library
```

## License

[MIT](../../LICENSE.md)
