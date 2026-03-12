# Haskell Style Guide

An actionable guide to Haskell coding style for the sayable-age library. Intended for code auditing and as a reference for contributors. Focuses on patterns actually used in this codebase, with pointers to broader Haskell conventions where relevant.

## Table of Contents

1. [Project Context](#1-project-context)
2. [Naming Conventions](#2-naming-conventions)
3. [Code Formatting](#3-code-formatting)
4. [Type System](#4-type-system)
5. [Module Design](#5-module-design)
6. [Function Design](#6-function-design)
7. [Error Handling](#7-error-handling)
8. [Laziness and Strictness](#8-laziness-and-strictness)
9. [Strings](#9-strings)
10. [Common Idioms](#10-common-idioms)
11. [Things to Avoid](#11-things-to-avoid)
12. [Generated Code](#12-generated-code)
13. [Tooling](#13-tooling)
14. [References](#14-references)

---

## 1. Project Context

This library has a zero runtime dependency constraint. The only allowed dependency is `base`. This rules out `text`, `bytestring`, `containers`, `deepseq`, `transformers`, `mtl`, and all other packages. All guidance in this document respects this constraint.

The codebase consists of five hand-written source files and 110+ generated locale modules. Generated code has relaxed style expectations -- see [Section 12](#12-generated-code).

---

## 2. Naming Conventions

### Modules

Use `UpperCamelCase` with hierarchical dot-separated namespaces. Module names should reflect their contents and position in the hierarchy.

```haskell
module SayableAge.Formatter       -- good
module SayableAge.Types           -- good
module SayableAge.Internal        -- good: signals private internals
module SayableAge.Locales.En      -- good: hierarchical locale
```

### Types, Type Classes, and Constructors

Use `UpperCamelCase` for all type-level names: data types, newtypes, type aliases, type classes, and data constructors.

For abbreviations, prefer mixed case (`TomlException`) over all-caps (`TOMLException`) for consistency within this project. Note that GHC's own `base` library uses all-caps in some places (`IORef`, `IOException`), so both conventions exist in the ecosystem. The important thing is consistency within the codebase.

```haskell
data PluralCategory = Zero | One | Two | Few | Many | Other  -- good
data UnitForms = Simple String | Pluralized [(PluralCategory, String)]  -- good
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
```

Kind variables use `k` by convention.

### Record Fields

Prefix record fields with a short form of the type name to avoid name clashes (Haskell has a flat namespace for record fields within a module).

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

Avoid creating new operators unless the domain strongly warrants them (e.g., mathematical DSLs). If you do create operators, provide named function aliases.

---

## 3. Code Formatting

### Formatter

Use [Fourmolu](https://github.com/fourmolu/fourmolu) with a checked-in `fourmolu.yaml`. Fourmolu is a configurable fork of Ormolu -- idempotent, uses GHC's own parser, and produces minimal diffs. Enforce formatting in CI with `fourmolu --check .`.

Recommended `fourmolu.yaml`:

```yaml
indentation: 4
comma-style: leading
record-brace-space: false
indent-wheres: false
respectful: true
haddock-style: multi-line
newlines-between-decls: 1
```

To disable formatting for a specific region (e.g., manually aligned tables):

```haskell
{- FOURMOLU_DISABLE -}
manuallyFormattedCode = ...
{- FOURMOLU_ENABLE -}
```

### Indentation

Use spaces, never tabs. Use 4-space indentation consistently.

The critical rule: **indentation of a line must not depend on the length of any identifier in a preceding line.** This prevents cascading reformats when renaming.

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

Keep lines under 90 characters. Long locale data lines are an expected exception. Break long type signatures and function applications across lines.

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
- **`let`** -- preferred in `do` blocks and when bindings need to refer to each other in order.

Prefer not to mix `let` and `where` in the same definition. When you must (e.g., a `do` block that also has pure helpers), keep the division clear: `let` for bindings that depend on `do`-block variables, `where` for pure helpers that do not.

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

## 4. Type System

### Algebraic Data Types

Use ADTs to make illegal states unrepresentable. This is the single most important Haskell design principle.

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
type LocaleMap = [(String, Locale)]  -- acceptable: specialization
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

## 5. Module Design

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

Organize imports in consistent groups, separated by blank lines. The ordering for this project:

1. Standard library / `base` imports
2. Project-internal imports

Within each group, sort alphabetically.

```haskell
import Data.Char (isDigit)
import Data.List (intercalate, isPrefixOf)

import SayableAge.Internal (computeAge, today)
import SayableAge.Types
```

### Qualified Imports

Use `import qualified` for modules whose names would clash with Prelude or with each other:

```haskell
import qualified SayableAge.Locales.En as En
import qualified SayableAge.Locales.Es as Es
```

### Explicit Import Lists vs Qualified

Use either explicit import lists or qualified imports for all non-Prelude modules. This makes dependencies obvious and prevents breakage when upstream modules add new exports.

```haskell
-- good: explicit list
import Data.Char (isDigit, isAlpha, toLower)

-- good: qualified
import qualified SayableAge.Locales.En as En

-- bad: unqualified blanket import (except for re-export modules)
import SayableAge.Types  -- acceptable only when re-exporting
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

Use an `Internal` module to separate private implementation details from public API. Name it `YourModule.Internal`. The public module re-exports only what users need. List internal modules under `other-modules` in the `.cabal` file, not `exposed-modules`.

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

Include a Haddock module header with purpose and stability information:

```haskell
{- |
Module      : SayableAge.Formatter
Description : Human-friendly age formatting
Stability   : stable
-}
module SayableAge.Formatter
    ( formatAgePure
    , formatStagePure
    ) where
```

---

## 6. Function Design

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

Use `.` for composing pure functions and `$` to eliminate trailing parentheses.

```haskell
-- good: composition chain with final application
result = process . transform . parse $ input

-- also fine: $ chaining when it reads clearly
putStrLn $ show $ length xs

-- good: single $ to eliminate parentheses
putStrLn $ show result

-- unnecessary: no nesting to eliminate
f $ x    -- just write: f x
```

The key principle: do not mix `.` and `$` in ways that require the reader to mentally track operator precedence.

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

## 7. Error Handling

### `Maybe`

Use `Maybe` for computations that can fail in exactly one way (absence of a value). This is the primary error-handling type in this codebase.

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

Both `Maybe` and `Either` are monads, so `do` notation works naturally for chaining fallible computations. This is heavily used in the codebase:

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

### Exceptions

Reserve exceptions (`throw`, `throwIO`, `catch`) for truly exceptional conditions in `IO` code. Never use exceptions for expected control flow. Pure code should use `Maybe` or `Either`.

### Error Handling Hierarchy

From simplest to most complex, prefer in this order:

1. **Total functions** -- restructure to eliminate the error case entirely
2. **`Maybe`** -- single failure mode, no error information needed
3. **`Either e`** -- failure with structured error information
4. **Exceptions** -- last resort, IO-only, for truly exceptional conditions

Note: `ExceptT` and `MonadError` (from the `transformers` and `mtl` packages) are common in larger Haskell applications but are not available in this codebase due to the zero-dependency constraint.

---

## 8. Laziness and Strictness

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

Mark data type fields as strict with `!` when the data is always fully evaluated. This prevents thunks from hiding inside data structures.

```haskell
data Stats = Stats
    { statsCount :: !Int
    , statsTotal :: !Double
    }
```

Prefer explicit `!` annotations on individual fields over the `StrictData` extension. Explicit bangs are self-documenting -- a reader can see at the definition site that a field is strict. `StrictData` silently changes the semantics of every type in the module, which can cause surprises with recursive data structures or intentionally lazy fields.

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

### `seq`

`seq a b` evaluates `a` to weak head normal form (WHNF -- outermost constructor) then returns `b`. Use `seq` when you need to force evaluation but bang patterns are not syntactically available.

### When to Add Strictness

- **Accumulators** in recursive functions: always strict
- **Record fields** that are always fully evaluated: strict (use `!`)
- **Numeric counters and totals**: strict
- **Lazy data structures** consumed incrementally (streams, lists used once): keep lazy
- **Configuration and environment data** loaded once: strict

---

## 9. Strings

### Why This Codebase Uses `String`

Haskell has three main string-like types:

| Type | Representation | Use Case |
|------|---------------|----------|
| `String` (`[Char]`) | Linked list of characters | Small strings, zero-dependency libraries |
| `Data.Text` | Packed Unicode array | Production text processing |
| `Data.ByteString` | Packed byte array | Binary data, raw I/O, network protocols |

In general Haskell code, `Text` is preferred for performance. However, `Data.Text` is in the `text` package, not `base`. This library uses `String` throughout because of the zero-dependency constraint. This is a deliberate design choice, not an oversight.

Auditors should not flag `String` usage as a style violation in this codebase. The strings involved (locale names, formatted ages, date strings) are short and performance is not a concern.

### String Operations

With `String` being `[Char]`, standard list functions work directly:

```haskell
import Data.Char (isDigit)
import Data.List (isPrefixOf)

-- substring check
isInfixOf' :: String -> String -> Bool
isInfixOf' needle haystack = ...

-- string replacement
replace :: String -> String -> String -> String
replace needle replacement haystack = ...
```

When building strings by concatenation, `++` is acceptable for short strings. For building large strings from many pieces, consider using `showString` and function composition to avoid quadratic behavior:

```haskell
-- acceptable for short strings
result = prefix ++ middle ++ suffix

-- for many concatenations, builder pattern with ShowS
buildLarge :: [String] -> String
buildLarge xs = foldr (\s acc -> showString s . showChar '\n' . acc) id xs ""
```

---

## 10. Common Idioms

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
- **`Read`** -- derive sparingly. Prefer proper parsing.
- **`Enum`** and **`Bounded`** -- derive for simple enumerations.

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

---

## 11. Things to Avoid

### Partial Functions

Partial functions crash at runtime on certain inputs. Avoid these and use total alternatives:

| Partial (avoid) | Total alternative |
|-----------------|-------------------|
| `head xs` | Pattern match: `case xs of (x:_) -> ...; [] -> ...` |
| `tail xs` | Pattern match: `case xs of (_:rest) -> ...; [] -> ...` |
| `init xs` | Explicit pattern matching or recursion |
| `last xs` | Explicit pattern matching or recursion |
| `xs !! n` | `drop n xs` then pattern match, or use indexing with bounds check |
| `fromJust mx` | Pattern match or `maybe`/`fromMaybe` |
| `read s` | `readMaybe` from `Text.Read`, or validate input first (see below) |
| `error msg` | `Maybe`, `Either`, or explicit error handling |

**Exception: `read` after validation.** The codebase uses `read` in `parseDate` after confirming all characters are digits with `isDigit`. This is an acceptable pattern -- when you have validated the input structurally, `read` is effectively total. Document the validation invariant with a comment when using this pattern:

```haskell
parseDate s
    | not (all isDigit yStr) = Nothing  -- validation
    | ...
    | otherwise = Just (y, m, d)
  where
    yStr = take 4 s
    y = read yStr :: Int  -- safe: validated as all-digits above
```

### Lazy I/O

Lazy I/O (`hGetContents`, `readFile` from `Prelude`) ties resource lifetimes to garbage collection, making it impossible to predict when file handles close. Avoid in production code.

```haskell
-- bad: lazy IO
transform :: FilePath -> IO ()
transform path = do
    contents <- readFile path    -- file handle stays open
    writeFile path (process contents)  -- may fail: handle still open!
```

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

GHC warns about non-exhaustive patterns with `-Wall`. Always handle all cases:

```haskell
-- good: all cases handled
lookupUnitForm cat forms =
    case lookup cat forms of
        Just s  -> s
        Nothing -> case lookup Other forms of
            Just s  -> s
            Nothing -> ""
```

### Unnecessary Language Extensions

Start with Haskell 2010. Add extensions only when they provide clear value. See [Section 13](#13-tooling) for the extension policy.

---

## 12. Generated Code

110+ locale modules in `SayableAge.Locales.*` are generated by `codegen/targets/haskell/emitter.py`. These modules carry a `DO NOT EDIT` banner and follow their own conventions:

- **Do not hand-edit generated modules.** Edit the generator or locale JSON instead.
- **Long lines are expected.** Locale data (pluralized forms, stage labels) often produces lines well over 90 characters. This is acceptable.
- **Relaxed linting.** Generated modules may trigger HLint suggestions. Suppress these at the module level if needed rather than complicating the generator.
- **Consistent structure.** All generated locale modules export a single `locale :: Locale` value and follow identical internal structure.
- **The barrel module** (`SayableAge.Locales`) is also generated and re-exports `getLocale :: String -> Maybe Locale`.

When auditing, focus review effort on the five hand-written source files, not the generated locale modules.

---

## 13. Tooling

### GHC Warning Flags

Compile with comprehensive warnings. The project baseline (from `sayable-age.cabal`):

```
-Wall
-Wcompat
-Werror
```

A fuller set for catching more issues:

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
```

In CI, `-Werror` is already enabled to treat all warnings as errors.

### HLint

[HLint](https://github.com/ndmitchell/hlint) suggests idiomatic improvements to Haskell code. Run it on the project:

```bash
hlint age/impl/haskell/src
```

Configure via `.hlint.yaml`:

```yaml
# Ignore specific hints globally
- ignore: { name: "Eta reduce" }

# Ignore within specific modules
- ignore: { name: "Use newtype instead of data", within: [SayableAge.Types] }

# Restrict partial functions
- functions:
  - { name: "Data.List.head", within: [], message: "Use pattern matching" }
  - { name: "fromJust", within: [], message: "Use maybe or pattern matching" }
```

Suppress hints inline when justified:

```haskell
{-# ANN module "HLint: ignore Use camelCase" #-}
```

### GHC Extensions Policy

Extensions range from universally accepted to experimental. A tiered approach:

**Tier 1: Safe defaults** -- enable freely, widely accepted:
- `OverloadedStrings` -- string literals for `IsString` types
- `ScopedTypeVariables` -- bring type variables into scope with `forall`
- `TypeApplications` -- specify type arguments explicitly
- `DerivingStrategies` -- explicit stock/newtype/anyclass derivation
- `DeriveGeneric` -- derive `Generic` instances
- `GeneralizedNewtypeDeriving` -- derive instances for newtypes
- `LambdaCase` -- `\case` for pattern matching
- `TupleSections` -- `(,x)` as a function
- `BangPatterns` -- strictness annotations on patterns
- `NumericUnderscores` -- `1_000_000` for readability

**Tier 2: Use when needed** -- add per-module with `LANGUAGE` pragma:
- `StrictData` -- strict fields by default (consider explicit `!` instead)
- `GADTs` -- generalized algebraic data types
- `TypeFamilies` -- type-level functions
- `DataKinds` -- promote data constructors to types
- `RankNTypes` -- higher-rank polymorphism
- `ExistentialQuantification` -- existential types
- `MultiParamTypeClasses` -- classes with multiple parameters
- `FunctionalDependencies` -- dependencies between class parameters
- `FlexibleContexts` / `FlexibleInstances` -- relaxed context/instance rules
- `ConstraintKinds` -- constraints as first-class types
- `NamedFieldPuns` -- bind record fields by name without repeating

**Tier 3: Use sparingly** -- powerful but increase complexity:
- `TemplateHaskell` -- compile-time code generation
- `UndecidableInstances` -- can cause the type checker to loop
- `IncoherentInstances` -- almost never justified
- `OverlappingInstances` -- prefer explicit specialization
- `RecordWildCards` -- implicit bindings make code harder to review

**Placement:** Put `LANGUAGE` pragmas at the top of the file, one per line, sorted alphabetically:

```haskell
{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module MyModule where
```

### FFI Conventions

The codebase uses the Foreign Function Interface to call `time()` for getting the current date. Follow these conventions:

- Use `unsafe` for short, non-blocking C calls that do not call back into Haskell (`foreign import ccall unsafe`). The `time()` call is a correct use of `unsafe`.
- Use `safe` (the default) for C calls that may block, call back into Haskell, or take a long time.
- Import `Foreign.C.Types` for C-compatible types (`CTime`, `CInt`, etc.).
- Keep FFI calls isolated in the `Internal` module, not in public-facing modules.

```haskell
import Foreign.C.Types (CTime(..))
import Foreign.Ptr (Ptr, nullPtr)

foreign import ccall unsafe "time" c_time :: Ptr CTime -> IO CTime
```

---

## 14. References

### Style Guides

- [Kowainik Haskell Style Guide](https://kowainik.github.io/posts/2019-02-06-style-guide) -- comprehensive, opinionated style guide with detailed formatting rules, naming conventions, and extension recommendations
- [Haskell Wiki: Programming Guidelines](https://wiki.haskell.org/Programming_guidelines) -- community-maintained guidelines covering documentation, naming, formatting, and code organization
- [Haskell Wiki: Avoiding Partial Functions](https://wiki.haskell.org/Avoiding_partial_functions) -- detailed guidance on replacing unsafe functions with total alternatives

### Type Design

- [Parse, Don't Validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/) (Alexis King) -- influential blog post on encoding invariants in the type system

### Tools

- [HLint](https://github.com/ndmitchell/hlint) -- Haskell linter that suggests idiomatic improvements
- [Fourmolu](https://github.com/fourmolu/fourmolu) -- configurable Haskell formatter (recommended for this project)
- [Ormolu](https://github.com/tweag/ormolu) -- opinionated, zero-configuration Haskell formatter

### GHC Documentation

- [GHC User's Guide: Language Extensions](https://ghc.gitlab.haskell.org/ghc/doc/users_guide/exts.html) -- official documentation for all GHC extensions
- [GHC User's Guide: Warnings](https://ghc.gitlab.haskell.org/ghc/doc/users_guide/using-warnings.html) -- comprehensive list of GHC warning flags
- [GHC User's Guide: FFI](https://ghc.gitlab.haskell.org/ghc/doc/users_guide/exts/ffi.html) -- foreign function interface documentation

### Libraries

- [safe package](https://hackage.haskell.org/package/safe) -- safe versions of partial Prelude functions (reference only; not used due to zero-dependency constraint)
