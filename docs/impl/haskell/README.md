# Haskell Style Guide

A comprehensive, actionable guide to idiomatic Haskell coding style and best practices. Intended for code auditing Haskell implementations.

## Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Code Formatting](#2-code-formatting)
3. [Type System](#3-type-system)
4. [Module Design](#4-module-design)
5. [Function Design](#5-function-design)
6. [Error Handling](#6-error-handling)
7. [Laziness and Strictness](#7-laziness-and-strictness)
8. [Common Idioms](#8-common-idioms)
9. [Text and Strings](#9-text-and-strings)
10. [Things to Avoid](#10-things-to-avoid)
11. [Tooling](#11-tooling)
12. [References](#12-references)

---

## 1. Naming Conventions

### Modules

Use `UpperCamelCase` with hierarchical dot-separated namespaces. Module names should reflect their contents and position in the hierarchy.

```haskell
module SayableAge.Formatter       -- good
module SayableAge.Types           -- good
module SayableAge.Internal        -- good: signals private internals
module SayableAge.Locales.En      -- good: hierarchical locale
```

### Types, Type Classes, and Constructors

Use `UpperCamelCase` for all type-level names: data types, newtypes, type aliases, type classes, and data constructors. Write abbreviations in mixed case, not all-caps.

```haskell
data PluralCategory = Zero | One | Two | Few | Many | Other  -- good
data UnitForms = Simple String | Pluralized [(PluralCategory, String)]  -- good

data TomlException   -- good: abbreviation in mixed case
data TOMLException   -- bad: all-caps abbreviation
```

### Functions and Variables

Use `lowerCamelCase` for functions, local bindings, and pattern variables. Names should be descriptive but not excessively long.

```haskell
formatAgePure    -- good: descriptive, camelCase
resolveUnit      -- good
stageKey         -- good

fmt              -- bad: too terse for a non-generic function
formatTheAgeOfAPersonPurely  -- bad: unnecessarily verbose
```

For short-lived local bindings in generic contexts, single-letter names are acceptable when the type makes the purpose clear:

```haskell
map f xs          -- acceptable: standard higher-order pattern
foldr (\x acc -> ...) z xs  -- acceptable: clear from context
```

### Type Variables

Use short lowercase names. Single letters (`a`, `b`, `m`) are standard for unconstrained variables. Use descriptive names when they improve clarity:

```haskell
class Functor f where         -- f for the type constructor
  fmap :: (a -> b) -> f a -> f b

class MonadReader r m where   -- r for "reader environment", m for "monad"

type family Key map :: Type   -- descriptive when it aids understanding
```

Kind variables use `k` by convention.

### Record Fields

Prefix record fields with a short form of the type name to avoid name clashes (Haskell has a flat namespace for record fields within a module). This is the traditional approach; `DuplicateRecordFields` is an alternative but has trade-offs.

```haskell
data Locale = Locale
    { localeCode      :: String
    , localePlural    :: Int -> PluralCategory
    , localeDay       :: UnitForms
    }

data Stages = Stages
    { stageNewborn  :: StageLabel
    , stageInfant   :: StageLabel
    , stageToddler  :: StageLabel
    }
```

### Operators

Avoid creating new operators unless the domain strongly warrants them (e.g., mathematical DSLs). If you do create operators, provide named function aliases. If using unicode symbols, provide ASCII alternatives.

---

## 2. Code Formatting

### Formatter Choice

Use an automated formatter for consistency. The two leading options:

- **[Ormolu](https://github.com/tweag/ormolu)** -- opinionated, zero-configuration, uses 2-space indentation. Enforces a single style with no options.
- **[Fourmolu](https://github.com/fourmolu/fourmolu)** -- fork of Ormolu with configurable options (indentation size, import grouping, etc.). Uses 4-space indentation by default. Configured via `fourmolu.yaml`.

Both use GHC's own parser, are idempotent, and respect programmer intent about single-line vs multi-line layout. Pick one and enforce it project-wide.

### Indentation

Use spaces, never tabs. The most common conventions:

- **2 spaces** (Ormolu default, common in libraries)
- **4 spaces** (Fourmolu default, Kowainik style guide)

Whichever you choose, be consistent. The critical rule: **indentation of a line must not depend on the length of any identifier in a preceding line.** This prevents cascading reformats when renaming.

```haskell
-- good: indentation is fixed
resolveLocale loc compactness =
    let mOvr = case compactness of
            Normal  -> Nothing
            Short   -> localeShort loc
            Compact -> localeCompact loc
    in ...

-- bad: indentation depends on identifier length
resolveLocale loc compactness =
                                let mOvr = ...
```

### Line Length

Keep lines under **90 characters** (Kowainik) or **80 characters** (Haskell Wiki). Long locale data lines are an expected exception. Break long type signatures and function applications across lines.

```haskell
-- break long signatures: one constraint/argument per line
formatTier
    :: Locale
    -> UnitForms
    -> UnitForms
    -> UnitForms
    -> UnitForms
    -> String
    -> String
    -> String
    -> Int
    -> Int
    -> String
```

### Whitespace

- No trailing whitespace on any line.
- Files must end with a single newline.
- Surround binary operators with single spaces: `x + y`, not `x+y`.
- Space after lambda backslash: `\x -> x + 1`, not `\x->x+1`.
- No space before a comma; one space after: `(a, b, c)`.

### Comma-Leading Style

Use comma-leading (also called "Utrecht style") for lists, records, exports, and imports. This produces cleaner diffs because adding an item only changes one line.

```haskell
-- good: comma-leading
data Locale = Locale
    { localeCode      :: String
    , localePlural    :: Int -> PluralCategory
    , localeDay       :: UnitForms
    , localeWeek      :: UnitForms
    }

-- good: comma-leading exports
module SayableAge.Types
    ( PluralCategory(..)
    , UnitForms(..)
    , Compactness(..)
    ) where
```

### `where` vs `let`

Both are valid; use them in their natural contexts:

- **`where`** -- preferred in pure function definitions. Reads top-down: state the main computation first, then define helpers.
- **`let`** -- preferred in `do` blocks and when bindings need to refer to each other in order or when you need the binding before the expression that uses it.

Do not mix `let` and `where` in the same definition; it hurts readability.

```haskell
-- good: where for pure helpers
parseDate s
    | length s < 10 = Nothing
    | otherwise     = Just (y, m, d)
  where
    yStr = take 4 s
    y = read yStr :: Int

-- good: let in do blocks
formatAge loc compactness dob mAsOf = do
    let fallback = ...
    asOf <- case mAsOf of ...
    return (formatAgePure loc compactness dob asOf)
```

### `do` Notation

Indent the body of a `do` block consistently. Align statements at the same level. Avoid unnecessary `do` when a single expression suffices.

```haskell
-- good
main :: IO ()
main = do
    contents <- readFile "input.txt"
    let result = process contents
    putStrLn result

-- unnecessary do
greet :: IO ()
greet = do            -- bad: do with single statement
    putStrLn "hello"

greet :: IO ()
greet = putStrLn "hello"  -- good: no do needed
```

### Alignment of Operators

Align `=`, `->`, `::`, and guards when it improves readability, but do not let alignment create excessive whitespace or depend on identifier length.

```haskell
-- good: aligned guards
stageKey months
    | months < 2   = "newborn"
    | months < 12  = "infant"
    | months < 36  = "toddler"
    | months < 156 = "child"
    | months < 216 = "teenager"
    | otherwise    = "adult"

-- good: aligned case arrows
daysInMonth y m = case m of
    1  -> 31
    2  -> if isLeapYear y then 29 else 28
    3  -> 31
    4  -> 30
```

---

## 3. Type System

### Algebraic Data Types

Haskell's ADTs are one of its greatest strengths. Use them to make illegal states unrepresentable.

```haskell
-- good: encode all possibilities in the type
data PluralCategory = Zero | One | Two | Few | Many | Other

-- good: distinguish structurally different cases
data UnitForms = Simple String | Pluralized [(PluralCategory, String)]

-- bad: stringly-typed
type PluralCategory = String  -- allows any string, not just valid categories
```

Use record syntax for product types with more than two or three fields:

```haskell
-- good: named fields
data Locale = Locale
    { localeCode      :: String
    , localePlural    :: Int -> PluralCategory
    , localeDay       :: UnitForms
    }

-- acceptable for small products
data Point = Point Double Double
```

Do not use record syntax on sum types with multiple constructors (it generates partial accessor functions):

```haskell
-- bad: record fields on a sum type
data Shape
    = Circle    { radius :: Double }
    | Rectangle { width :: Double, height :: Double }
    -- radius (Rectangle 3 4) is a runtime crash
```

### Newtypes

Use `newtype` instead of `type` for type-safe wrappers. A `newtype` has zero runtime overhead (it is erased at compile time) but provides type safety that `type` synonyms do not.

```haskell
-- good: newtype for type safety, zero runtime cost
newtype UserId = UserId Int
newtype Email = Email String

-- bad: type alias provides no safety
type UserId = Int  -- can accidentally pass any Int as a UserId
```

Use `type` aliases only for specializing generic types or for local readability:

```haskell
type Map = Data.Map.Map String Value  -- acceptable: specialization
```

### Type Classes

Define type classes when you have a genuine abstraction shared across multiple types. Avoid "God classes" with many methods. Prefer small, composable classes.

```haskell
-- good: focused type class
class HasLocaleCode a where
    localeCode :: a -> String

-- bad: kitchen-sink class
class Formattable a where
    format :: a -> String
    parse :: String -> a
    validate :: a -> Bool
    -- too many unrelated responsibilities
```

Provide default implementations when a sensible one exists. Document laws that instances must satisfy.

### Type Families and GADTs

Use type families for type-level computation when needed. Use GADTs when you need the type checker to track more information through pattern matching. Both are powerful but add complexity; reach for them only when simpler alternatives fall short.

```haskell
{-# LANGUAGE GADTs #-}

data Expr a where
    LitInt  :: Int -> Expr Int
    LitBool :: Bool -> Expr Bool
    Add     :: Expr Int -> Expr Int -> Expr Int
    If      :: Expr Bool -> Expr a -> Expr a -> Expr a
```

### Phantom Types

Use phantom type parameters to encode invariants at the type level without runtime cost:

```haskell
data Validated
data Unvalidated

newtype Input a = Input String

validate :: Input Unvalidated -> Maybe (Input Validated)
-- The phantom parameter prevents mixing validated and unvalidated inputs
```

### Deriving

Always derive instances when possible. Use `DerivingStrategies` to make the derivation mechanism explicit:

```haskell
{-# LANGUAGE DerivingStrategies #-}

data PluralCategory = Zero | One | Two | Few | Many | Other
    deriving stock (Eq, Show, Ord, Enum, Bounded)

newtype UserId = UserId Int
    deriving stock (Show)
    deriving newtype (Eq, Ord, Num)
```

The three strategies:
- **`stock`** -- GHC's built-in derivation (Eq, Ord, Show, Read, Enum, Bounded, etc.)
- **`newtype`** -- reuse the inner type's instance (requires `GeneralizedNewtypeDeriving`)
- **`anyclass`** -- use the class's default method implementations (for classes with defaults)

---

## 4. Module Design

### Explicit Export Lists

Always write explicit export lists. This defines the public API, prevents accidental exposure of internals, and produces better documentation.

```haskell
module SayableAge.Types
    ( PluralCategory(..)     -- export type + all constructors
    , UnitForms(..)
    , Compactness(..)        -- export type + all constructors
    , Locale(..)
    , resolveStageLabel      -- export specific functions
    , lookupUnitForm
    ) where
```

Use `(..)` to export all constructors of a type. Use explicit constructor lists when you want to hide some constructors (smart constructor pattern):

```haskell
module Validated
    ( Email       -- type only, constructor hidden
    , mkEmail     -- smart constructor
    ) where
```

### Import Organization

Organize imports in consistent groups, separated by blank lines. A common ordering:

1. Standard library / `base` imports
2. Third-party library imports (if any)
3. Project-internal imports

Within each group, sort alphabetically.

```haskell
import Data.Char (isDigit)
import Data.List (intercalate, isPrefixOf)

import SayableAge.Internal (computeAge, today)
import SayableAge.Types
```

### Qualified Imports

Use `import qualified` for modules whose names would clash with Prelude or with each other. The standard conventions:

```haskell
import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as BSL
import qualified Data.HashMap.Strict as HM
import qualified Data.IntMap.Strict as IM
import qualified Data.Sequence as Seq
```

### Explicit Import Lists vs Qualified

Use either explicit import lists or qualified imports for all non-Prelude modules. This makes dependencies obvious and prevents breakage when upstream modules add new exports.

```haskell
-- good: explicit list
import Data.Char (isDigit, isAlpha, toLower)

-- good: qualified
import qualified Data.Map.Strict as Map

-- bad: unqualified blanket import (except for re-export modules)
import Data.Map
```

The exception: a top-level facade module that re-exports everything from internal modules may use unqualified blanket imports.

```haskell
-- acceptable: re-export module
module SayableAge
    ( formatAgePure
    , formatStagePure
    , module SayableAge.Types
    , module SayableAge.Locales
    ) where

import SayableAge.Formatter (formatAge, formatAgePure, formatStage, formatStagePure)
import SayableAge.Locales
import SayableAge.Types
```

### Internal Modules

Use an `Internal` module to separate private implementation details from public API. Name it `YourModule.Internal`. The public module re-exports only what users need.

```haskell
-- SayableAge.Internal: exports everything for testing, but not for users
module SayableAge.Internal
    ( parseDate
    , isLeapYear
    , daysInMonth
    , daysBetween
    , computeAge
    , today
    ) where

-- SayableAge.Formatter: imports Internal, exposes only the public API
module SayableAge.Formatter
    ( formatAgePure
    , formatStagePure
    ) where

import SayableAge.Internal (computeAge, today)
```

### Module Header Documentation

Include a Haddock module header with purpose, copyright, and stability information:

```haskell
{- |
Module      : SayableAge.Formatter
Description : Human-friendly age formatting
Copyright   : (c) 2024 Author Name
License     : MIT
Maintainer  : author@example.com
Stability   : stable
-}
module SayableAge.Formatter
    ( formatAgePure
    , formatStagePure
    ) where
```

---

## 5. Function Design

### Type Signatures

Every top-level function must have an explicit type signature. Functions in `where` blocks should also have signatures when their types are not obvious.

```haskell
-- good: explicit signature
resolveUnit :: Int -> UnitForms -> Locale -> String -> String
resolveUnit count uf loc half = ...

-- good: where binding with signature for clarity
parseDate :: String -> Maybe (Int, Int, Int)
parseDate s = ...
  where
    yStr :: String
    yStr = take 4 s
```

### Point-Free Style

Point-free (tacit) style is idiomatic when it improves readability. Stop when it hurts clarity.

```haskell
-- good: point-free is clearer
sortByName = sortBy (comparing name)
isEven = (== 0) . (`mod` 2)

-- good: explicit parameter is clearer here
formatAll loc = map (formatAge loc)

-- bad: point-free is cryptic
f = (.) (.) (.)  -- what does this do?
```

**Rule of thumb:** If you need more than two composed functions, or if you need `flip`, `uncurry`, or combinators like `(.) . (.)`, write the arguments explicitly.

### Eta Reduction

Eta-reduce when the result reads naturally. Do not eta-reduce when it obscures what the function does.

```haskell
-- good: eta-reduced
stageKey = \case ...
formatAll = map . format

-- bad: forced eta reduction hurts readability
processInput = either handleError id . parseInput . preprocessConfig
-- better with explicit argument:
processInput input = either handleError id (parseInput (preprocessConfig input))
```

### Function Composition and Application

Use `.` for composing pure functions and `$` to eliminate trailing parentheses. Do not chain `$` -- use `.` for intermediate steps.

```haskell
-- good
result = process . transform . parse $ input

-- bad: chained $
result = process $ transform $ parse $ input

-- acceptable: single $
putStrLn $ show result
```

### Sections

Operator sections are idiomatic for partial application of binary operators:

```haskell
map (+1) xs          -- add 1 to each element
filter (>0) xs       -- keep positive elements
map (++ "!") words   -- append to each string
```

Avoid sections when they are confusing, especially with subtraction (which is also unary negation):

```haskell
map (subtract 1) xs  -- good: clear
map (+ (-1)) xs      -- acceptable but unusual
map (-1+) xs         -- bad: confusing
```

---

## 6. Error Handling

### `Maybe`

Use `Maybe` for computations that can fail in exactly one way (absence of a value). This is the simplest and most common error-handling type.

```haskell
parseDate :: String -> Maybe (Int, Int, Int)
parseDate s
    | length s < 10 = Nothing
    | otherwise     = Just (y, m, d)
  where ...
```

Prefer pattern matching or `maybe`/`fromMaybe` over `isJust`/`fromJust`:

```haskell
-- good: pattern match
case parseDate input of
    Nothing        -> handleError
    Just (y, m, d) -> process y m d

-- good: maybe combinator
maybe defaultValue process (parseDate input)

-- bad: isJust + fromJust
if isJust result then fromJust result else defaultValue
```

### `Either`

Use `Either` when failures carry information. By convention, `Left` is the error case and `Right` is the success case.

```haskell
data ParseError
    = InvalidFormat String
    | DateOutOfRange Int Int Int

parseDate :: String -> Either ParseError (Int, Int, Int)
parseDate s
    | length s < 10 = Left (InvalidFormat s)
    | otherwise     = Right (y, m, d)
```

### Monadic Error Handling with `do` Notation

Both `Maybe` and `Either` are monads, so `do` notation works naturally for chaining fallible computations:

```haskell
computeAge :: String -> String -> Maybe (Int, Int)
computeAge dob asOf = do
    (dy, dm, dd) <- parseDate dob
    (ry, rm, rd) <- parseDate asOf
    let diffDays = daysBetween (dy, dm, dd) (ry, rm, rd)
    if diffDays < 0
        then Nothing
        else Just (months, diffDays)
```

### `ExceptT` and `MonadError`

For applications with complex error handling across IO and pure code, use `ExceptT` from `transformers` or the `MonadError` class from `mtl`:

```haskell
import Control.Monad.Except

data AppError = NotFound | ParseFailed String

loadAndParse :: FilePath -> ExceptT AppError IO Result
loadAndParse path = do
    contents <- liftIO (readFile path) `catchError` \_ -> throwError NotFound
    case parse contents of
        Left msg -> throwError (ParseFailed msg)
        Right r  -> return r
```

### Exceptions

Reserve exceptions (`throw`, `throwIO`, `catch`) for truly exceptional conditions in `IO` code. Never use exceptions for expected control flow. Pure code should use `Maybe` or `Either`.

```haskell
-- good: exception for genuinely unexpected IO failure
writeOutput :: FilePath -> String -> IO ()
writeOutput path content = writeFile path content
    `catch` \(e :: IOException) -> do
        hPutStrLn stderr ("Failed to write: " ++ show e)
        exitFailure
```

### Error Handling Hierarchy

From simplest to most complex, prefer in this order:

1. **Total functions** -- restructure to eliminate the error case entirely
2. **`Maybe`** -- single failure mode, no error information needed
3. **`Either e`** -- failure with structured error information
4. **`ExceptT e m`** -- errors combined with other effects
5. **Exceptions** -- last resort, IO-only, for truly exceptional conditions

---

## 7. Laziness and Strictness

### Default: Lazy

Haskell is lazy by default. Values are not computed until demanded. This enables elegant patterns (infinite data structures, compositional pipelines) but can cause space leaks when unevaluated thunks accumulate.

### Space Leaks

A space leak occurs when a computation holds onto data longer than necessary because lazy thunks have not been forced. The classic example:

```haskell
-- space leak: foldl builds up a chain of thunks
badSum :: [Int] -> Int
badSum = foldl (+) 0
-- foldl (+) 0 [1,2,3] = ((0+1)+2)+3
-- The nested additions are NOT evaluated until the end

-- good: foldl' forces the accumulator at each step
goodSum :: [Int] -> Int
goodSum = foldl' (+) 0
```

**Rule:** Use `foldl'` (strict left fold from `Data.List`) instead of `foldl` in virtually all cases.

### Strict Fields with Bang Patterns

Mark data type fields as strict when the data is always fully evaluated. This prevents thunks from hiding inside data structures.

```haskell
{-# LANGUAGE StrictData #-}  -- makes all fields strict by default

-- or mark individual fields
data Stats = Stats
    { statsCount :: !Int
    , statsTotal :: !Double
    }
```

The `StrictData` extension makes all fields in a module strict by default, which is appropriate for most application code. Use `~` (tilde) to explicitly mark a field as lazy when needed.

### `BangPatterns`

Force evaluation of function arguments with bang patterns:

```haskell
{-# LANGUAGE BangPatterns #-}

mean :: [Double] -> Double
mean xs = go 0 0 xs
  where
    go !total !count [] = total / fromIntegral count
    go !total !count (x:rest) = go (total + x) (count + 1) rest
```

### `seq` and `deepseq`

- `seq a b` evaluates `a` to weak head normal form (WHNF -- outermost constructor) then returns `b`.
- `deepseq a b` (from the `deepseq` package) fully evaluates `a` to normal form.

```haskell
import Control.DeepSeq (force, NFData)

-- force full evaluation before returning
processStrict :: NFData a => a -> a
processStrict x = force x
```

### When to Add Strictness

- **Accumulators** in recursive functions: always strict
- **Record fields** that are always fully evaluated: strict
- **Numeric counters and totals**: strict
- **Lazy data structures** that are consumed incrementally (streams, lists used once): keep lazy
- **Configuration and environment data** loaded once: strict

### The `Strict` and `StrictData` Extensions

- `StrictData` -- makes all data type fields strict in the module. Recommended for most application code.
- `Strict` -- makes all bindings and patterns strict. More aggressive; use judiciously.

---

## 8. Common Idioms

### Pattern Matching

Pattern matching is the primary way to deconstruct data in Haskell. Prefer it over accessor functions and boolean checks.

```haskell
-- good: pattern match
case result of
    Nothing     -> defaultValue
    Just value  -> process value

-- bad: accessor functions
if isJust result
    then process (fromJust result)
    else defaultValue
```

Use `LambdaCase` to match on the last argument without naming it:

```haskell
{-# LANGUAGE LambdaCase #-}

stageKey :: Int -> String
stageKey = \case
    m | m < 2   -> "newborn"
      | m < 12  -> "infant"
      | m < 36  -> "toddler"
      | m < 156 -> "child"
      | m < 216 -> "teenager"
      | otherwise -> "adult"
```

### Guards

Use guards for multi-way conditionals. They are clearer than nested `if-then-else`.

```haskell
-- good: guards
classify :: Int -> String
classify n
    | n < 0     = "negative"
    | n == 0    = "zero"
    | n < 100   = "small"
    | otherwise = "large"

-- bad: nested if-then-else
classify n =
    if n < 0 then "negative"
    else if n == 0 then "zero"
    else if n < 100 then "small"
    else "large"
```

### Where Clauses

Use `where` to keep the main logic front and center, with supporting definitions below:

```haskell
daysBetween (y1, m1, d1) (y2, m2, d2) =
    toJDN y2 m2 d2 - toJDN y1 m1 d1
  where
    toJDN y m d =
        let a  = (14 - m) `div` 12
            yy = y + 4800 - a
            mm = m + 12 * a - 3
        in d + (153 * mm + 2) `div` 5 + 365 * yy
             + yy `div` 4 - yy `div` 100 + yy `div` 400 - 32045
```

### List Comprehensions vs Higher-Order Functions

Both are idiomatic. Use whichever is clearer for the specific case.

```haskell
-- higher-order functions: clearer for simple transformations
map toUpper s
filter (> 0) xs
concatMap expand items

-- list comprehension: clearer with multiple generators or conditions
[(x, y) | x <- xs, y <- ys, x /= y]
[x * 2 | x <- xs, even x, x > 10]
```

**Rule of thumb:** Use `map`, `filter`, and `concatMap` for single transformations. Use list comprehensions when you have multiple generators, complex predicates, or the intent reads more naturally.

### Deriving Best Practices

Derive all instances you can. The most commonly derived classes:

- **`Eq`** -- almost always derived. Needed for comparisons and as a prerequisite for `Ord`.
- **`Ord`** -- derive when there is a natural ordering. Uses constructor declaration order.
- **`Show`** -- derive for debugging and REPL use. Override with a custom instance for user-facing output.
- **`Read`** -- derive sparingly. Prefer proper parsing (aeson, attoparsec, megaparsec).
- **`Enum`** and **`Bounded`** -- derive for simple enumerations.
- **`Generic`** -- derive when you need generic programming (aeson, binary, etc.).

```haskell
data Compactness = Normal | Short | Compact
    deriving (Eq, Ord, Show, Enum, Bounded)
```

### The `$` Operator

Use `$` to eliminate a trailing closing parenthesis. Do not use it when parentheses are clearer.

```haskell
-- good: $ eliminates parentheses
putStrLn $ show (length xs)
return $ formatAgePure loc compactness dob asOf

-- unnecessary: no nesting to eliminate
f $ x    -- just write: f x
```

### Record Updates

Use record update syntax for modifying one or two fields of a record:

```haskell
updatedLocale = locale { localeCode = "en-US", localeHalf = "1/2" }
```

For complex updates with many fields, consider lenses (the `lens` or `optics` library) or define focused update functions.

---

## 9. Text and Strings

### `String` vs `Text` vs `ByteString`

Haskell has three main string-like types with very different performance characteristics:

| Type | Representation | Use Case |
|------|---------------|----------|
| `String` (`[Char]`) | Linked list of characters | Small strings, simple programs, prototyping |
| `Data.Text` | Packed UTF-8 array | Production text processing |
| `Data.ByteString` | Packed byte array | Binary data, raw I/O, network protocols |

**For production code, prefer `Text` over `String`.** `String` is a linked list (`[Char]`), which means every character is a heap-allocated cons cell. `Text` is a packed array, offering far better time and space performance.

```haskell
-- good: Text for production
import qualified Data.Text as T
import qualified Data.Text.IO as TIO

processFile :: FilePath -> IO T.Text
processFile path = do
    contents <- TIO.readFile path
    return (T.toUpper contents)

-- acceptable: String for simple, non-performance-critical code
formatAge :: String -> String
formatAge input = ...
```

### `OverloadedStrings`

Enable `OverloadedStrings` to write string literals that work with `Text`, `ByteString`, and other `IsString` types:

```haskell
{-# LANGUAGE OverloadedStrings #-}

import Data.Text (Text)

greeting :: Text
greeting = "Hello, world!"  -- no explicit pack needed
```

### Conversion Functions

```haskell
import qualified Data.Text as T

-- String <-> Text
T.pack   :: String -> Text
T.unpack :: Text -> String

-- Text <-> ByteString (encoding-aware)
import qualified Data.Text.Encoding as TE
TE.encodeUtf8 :: Text -> ByteString
TE.decodeUtf8 :: ByteString -> Text        -- can throw on invalid UTF-8
TE.decodeUtf8' :: ByteString -> Either UnicodeException Text  -- safe
```

### Strict vs Lazy Variants

Both `Text` and `ByteString` have strict and lazy variants:

- **`Data.Text`** / **`Data.ByteString`** -- strict, fully evaluated in memory. Use for most purposes.
- **`Data.Text.Lazy`** / **`Data.ByteString.Lazy`** -- chunked, evaluated on demand. Use for streaming or very large data.

Import conventions:

```haskell
import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as BSL
```

### Builder Pattern

For building large text values incrementally, use the `Builder` type to avoid quadratic concatenation:

```haskell
import qualified Data.Text.Lazy.Builder as B

buildReport :: [Item] -> Text
buildReport items = TL.toStrict . B.toLazyText $
    mconcat [B.fromText (formatItem item) <> B.singleton '\n' | item <- items]
```

---

## 10. Things to Avoid

### Partial Functions

Partial functions crash at runtime on certain inputs. Avoid these and use total alternatives:

| Partial (avoid) | Total alternative |
|-----------------|-------------------|
| `head xs` | Pattern match: `case xs of (x:_) -> ...; [] -> ...` |
| `tail xs` | Pattern match: `case xs of (_:rest) -> ...; [] -> ...` |
| `init xs` | `Data.List.unsnoc` or explicit recursion |
| `last xs` | `Data.List.unsnoc` or explicit recursion |
| `xs !! n` | `drop n xs` then pattern match, or use `Data.Vector` |
| `fromJust mx` | Pattern match or `maybe`/`fromMaybe` |
| `read s` | `readMaybe` from `Text.Read` |
| `minimum xs` / `maximum xs` | Check non-emptiness first, or use `NonEmpty` |
| `toEnum n` | Bounds check first, or use `toEnumMay` from `safe` |
| `error msg` | `Maybe`, `Either`, or explicit error handling |

```haskell
-- bad
firstElement xs = head xs

-- good
firstElement [] = Nothing
firstElement (x:_) = Just x

-- bad
unsafeParse s = read s :: Int

-- good
safeParse :: String -> Maybe Int
safeParse = readMaybe
```

### `String` for Performance-Sensitive Code

As discussed in section 9, `String` is a linked list. For any code that processes text at scale, use `Text`.

### Lazy I/O

Lazy I/O (`hGetContents`, `readFile` from `Prelude`) ties resource lifetimes to garbage collection, making it impossible to predict when file handles close. This causes subtle bugs:

```haskell
-- bad: lazy IO
import Prelude (readFile, writeFile)

transform :: FilePath -> IO ()
transform path = do
    contents <- readFile path    -- file handle stays open
    writeFile path (process contents)  -- may fail: handle still open!

-- good: strict IO
import qualified Data.Text.IO as TIO

transform :: FilePath -> IO ()
transform path = do
    contents <- TIO.readFile path  -- strict: reads everything, closes handle
    TIO.writeFile path (process contents)
```

For streaming, use a proper streaming library (`conduit`, `streaming`, `pipes`) instead of lazy I/O.

### Orphan Instances

An orphan instance defines a type class instance in a module that owns neither the class nor the type. Orphan instances are problematic because:

- Instances are imported implicitly and cannot be hidden
- Two orphan instances for the same class/type pair cause irrecoverable conflicts
- They reduce library composability

```haskell
-- bad: orphan instance (neither Show nor Int is defined here)
instance Show Int where ...

-- good: use a newtype wrapper instead
newtype Age = Age Int
    deriving (Show)
```

**Rule:** Define instances in the module that defines either the class or the type. If you need different behavior, wrap the type in a `newtype`.

### Overly Complex Point-Free

If point-free style requires `flip`, multiple `(.)` compositions, or combinators to contort the argument order, write the arguments explicitly.

```haskell
-- bad: unreadable point-free
processAll = map . (. transform) . flip formatWith

-- good: clear with explicit arguments
processAll opts items = map (\item -> formatWith opts (transform item)) items
```

### Incomplete Pattern Matches

GHC warns about non-exhaustive patterns with `-Wall`. Always handle all cases, or document unreachable cases with `error` including the module and function name:

```haskell
-- good: all cases handled
lookupUnitForm cat forms =
    case lookup cat forms of
        Just s  -> s
        Nothing -> case lookup Other forms of
            Just s  -> s
            Nothing -> ""

-- if a case is truly unreachable, document it
handleDirection North = ...
handleDirection South = ...
handleDirection East  = ...
handleDirection West  = ...
```

### Unnecessary Language Extensions

Start with Haskell 2010. Add extensions only when they provide clear value. Each extension is a point of complexity and potential non-portability. See section 11 for a recommended extension policy.

---

## 11. Tooling

### GHC Warning Flags

Compile with comprehensive warnings. A recommended baseline:

```
-Wall
-Wcompat
-Widentities
-Wincomplete-record-updates
-Wincomplete-uni-patterns
-Wmissing-export-lists
-Wmissing-home-modules
-Wpartial-fields
-Wredundant-constraints
-Wunused-packages
```

In CI, add `-Werror` to treat all warnings as errors.

In your `.cabal` file:

```cabal
ghc-options:
  -Wall -Wcompat -Widentities -Wincomplete-record-updates
  -Wincomplete-uni-patterns -Wmissing-export-lists
  -Wpartial-fields -Wredundant-constraints
```

### HLint

[HLint](https://github.com/ndmitchell/hlint) suggests idiomatic improvements to Haskell code. It detects redundant brackets, suggests alternative functions, identifies code simplifications, and enforces consistent style.

Run it on your entire project:

```bash
hlint .
hlint . --report  # generates an HTML report
```

Configure via `.hlint.yaml`:

```yaml
# Ignore specific hints globally
- ignore: { name: "Eta reduce" }

# Ignore within specific modules
- ignore: { name: "Use newtype instead of data", within: [SayableAge.Types] }

# Add custom restrictions
- functions:
  - { name: "Data.List.head", within: [], message: "Use pattern matching" }
  - { name: "fromJust", within: [], message: "Use maybe or pattern matching" }
```

Suppress hints inline when justified:

```haskell
{-# ANN module "HLint: ignore Use camelCase" #-}
{- HLINT ignore "Eta reduce" -}
```

HLint severity levels:
- **Error** -- parse errors
- **Warning** -- always-desirable improvements (e.g., `concatMap` over `concat . map`)
- **Suggestion** -- subjective recommendations that may not always apply

### Ormolu / Fourmolu

Choose one formatter and enforce it in CI.

**[Ormolu](https://github.com/tweag/ormolu):**
- Zero configuration
- 2-space indentation
- Opinionated: one format for any given input
- `ormolu --check .` in CI to verify formatting

**[Fourmolu](https://github.com/fourmolu/fourmolu):**
- Configurable via `fourmolu.yaml`
- 4-space indentation by default
- All of Ormolu's design principles (idempotent, GHC parser, minimal diffs) with flexibility
- `fourmolu --check .` in CI

Example `fourmolu.yaml`:

```yaml
indentation: 4
comma-style: leading
record-brace-space: false
indent-wheres: false
respectful: true
haddock-style: multi-line
newlines-between-decls: 1
```

Both formatters support disabling formatting for specific regions:

```haskell
{- ORMOLU_DISABLE -}
-- or
{- FOURMOLU_DISABLE -}
manuallyFormattedCode = ...
{- ORMOLU_ENABLE -}
-- or
{- FOURMOLU_ENABLE -}
```

### stylish-haskell

[stylish-haskell](https://github.com/haskell/stylish-haskell) focuses on import sorting and alignment rather than full formatting. It is commonly used alongside (or instead of) a full formatter for import organization. Configure via `.stylish-haskell.yaml`.

### Weeder

[Weeder](https://github.com/ocharles/weeder) performs whole-program dead code analysis. Unlike GHC's per-module warnings, Weeder finds functions that are exported but never used by any other module in the project.

Setup:
1. Enable HIE file generation: add `-fwrite-ide-info` to GHC options
2. Configure `weeder.toml` with root entry points
3. Run `weeder` after building

```toml
roots = ["^Main.main$", "^SayableAge\\..*"]
type-class-roots = true
unused-types = false
```

### GHC Extensions Policy

Extensions range from universally accepted to experimental. A tiered approach:

**Tier 1: Safe defaults** -- enable freely, widely accepted:
- `OverloadedStrings` -- string literals for `Text`, `ByteString`, etc.
- `ScopedTypeVariables` -- bring type variables into scope with `forall`
- `TypeApplications` -- specify type arguments explicitly
- `DerivingStrategies` -- explicit stock/newtype/anyclass derivation
- `DeriveGeneric` -- derive `Generic` instances
- `GeneralizedNewtypeDeriving` -- derive instances for newtypes
- `LambdaCase` -- `\case` for pattern matching
- `TupleSections` -- `(,x)` as a function
- `BangPatterns` -- strictness annotations on patterns
- `StrictData` -- strict fields by default (application code)
- `NumericUnderscores` -- `1_000_000` for readability

**Tier 2: Use when needed** -- add per-module with `LANGUAGE` pragma:
- `GADTs` -- generalized algebraic data types
- `TypeFamilies` -- type-level functions
- `DataKinds` -- promote data constructors to types
- `RankNTypes` -- higher-rank polymorphism
- `ExistentialQuantification` -- existential types
- `MultiParamTypeClasses` -- classes with multiple parameters
- `FunctionalDependencies` -- dependencies between class parameters
- `FlexibleContexts` / `FlexibleInstances` -- relaxed context/instance rules
- `ConstraintKinds` -- constraints as first-class types
- `RecordWildCards` -- `MyRecord{..}` to bind all fields

**Tier 3: Use sparingly** -- powerful but increase complexity:
- `TemplateHaskell` -- compile-time code generation
- `UndecidableInstances` -- can cause the type checker to loop
- `IncoherentInstances` -- almost never justified
- `OverlappingInstances` -- prefer explicit specialization

**Placement:** Put `LANGUAGE` pragmas at the top of the file, one per line, sorted alphabetically:

```haskell
{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module MyModule where
```

---

## 12. References

### Style Guides

- [Kowainik Haskell Style Guide](https://kowainik.github.io/posts/2019-02-06-style-guide) -- comprehensive, opinionated style guide with detailed formatting rules, naming conventions, and extension recommendations
- [Haskell Wiki: Programming Guidelines](https://wiki.haskell.org/Programming_guidelines) -- community-maintained guidelines covering documentation, naming, formatting, and code organization
- [Haskell Wiki: Programming Tips](https://wiki.haskell.org/Haskell_programming_tips) -- practical tips for writing concise, efficient, idiomatic Haskell
- [Haskell Wiki: Avoiding Partial Functions](https://wiki.haskell.org/Avoiding_partial_functions) -- detailed guidance on replacing unsafe functions with total alternatives
- [Haskell Wiki: Orphan Instances](https://wiki.haskell.org/Orphan_instance) -- explanation of why orphan instances are problematic and how to avoid them

### Type Design

- [Parse, Don't Validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/) (Alexis King) -- influential blog post on encoding invariants in the type system

### Tools

- [HLint](https://github.com/ndmitchell/hlint) -- Haskell linter that suggests idiomatic improvements
- [Ormolu](https://github.com/tweag/ormolu) -- opinionated, zero-configuration Haskell formatter
- [Fourmolu](https://github.com/fourmolu/fourmolu) -- configurable fork of Ormolu
- [stylish-haskell](https://github.com/haskell/stylish-haskell) -- import sorter and aligner
- [Weeder](https://github.com/ocharles/weeder) -- whole-program dead code analysis

### GHC Documentation

- [GHC User's Guide: Language Extensions](https://ghc.gitlab.haskell.org/ghc/doc/users_guide/exts.html) -- official documentation for all GHC extensions
- [GHC User's Guide: Warnings](https://ghc.gitlab.haskell.org/ghc/doc/users_guide/using-warnings.html) -- comprehensive list of GHC warning flags

### Libraries

- [Data.Text (text package)](https://hackage.haskell.org/package/text) -- efficient packed Unicode text
- [safe package](https://hackage.haskell.org/package/safe) -- safe versions of partial Prelude functions
- [deepseq package](https://hackage.haskell.org/package/deepseq) -- full evaluation to normal form
