# Elm Style Guide

A comprehensive guide to idiomatic Elm coding style and best practices, for use in code auditing Elm implementations.

## Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Code Formatting](#2-code-formatting)
3. [Type System](#3-type-system)
4. [Module Design](#4-module-design)
5. [Function Design](#5-function-design)
6. [Data Modeling](#6-data-modeling)
7. [Pattern Matching](#7-pattern-matching)
8. [Error Handling](#8-error-handling)
9. [Common Idioms](#9-common-idioms)
10. [Things to Avoid](#10-things-to-avoid)
11. [Tooling](#11-tooling)

---

## 1. Naming Conventions

### Modules

Module names use `PascalCase` and must match the file path. Nested modules use dots:

```elm
module SayableAge exposing (..)            -- src/SayableAge.elm
module SayableAge.Formatter exposing (..)  -- src/SayableAge/Formatter.elm
module SayableAge.Locales.En exposing (..) -- src/SayableAge/Locales/En.elm
```

### Types and Type Aliases

Custom types and type aliases use `PascalCase`:

```elm
type PluralCategory
    = Zero
    | One
    | Two
    | Few
    | Many
    | Other

type alias Locale =
    { code : String
    , plural : Int -> PluralCategory
    }
```

### Constructors

Constructors (also called variants or tags) use `PascalCase`:

```elm
type Compactness
    = Normal
    | Short
    | Compact
```

### Functions and Values

Functions, values, and parameters use `camelCase`:

```elm
formatAge : Locale -> Compactness -> String -> String -> Maybe String
formatAge loc compactness dob asOf =
    ...

resolveStageLabel : StageLabel -> Maybe Gender -> String
resolveStageLabel label gender =
    ...
```

### Type Variables

Type variables use lowercase names. Single letters (`a`, `b`) are fine for generic functions; use descriptive names when they improve clarity:

```elm
-- Generic: single letters are fine
List.map : (a -> b) -> List a -> List b

-- Descriptive: clearer in context
Dict.get : comparable -> Dict comparable value -> Maybe value

-- Domain-specific: msg is conventional for messages
view : Model -> Html msg
```

Elm has four special constrained type variables with reserved meaning:
- `number` -- `Int` or `Float`
- `comparable` -- types that support `<`, `>`, `==` (Int, Float, Char, String, and tuples/lists of those)
- `appendable` -- types that support `++` (String, List)
- `compappend` -- both comparable and appendable

### Naming Principles

- **Readability over brevity.** It is much more important that code be readable than fast to type. Spell out names; do not abbreviate. `viewPromptAndPassagesAccordions` is better than `accdns`.
- **Prefix Maybe values with "maybe".** Use `maybeUserId : Maybe UserId`, not `userId_` or `mUserId`.
- **Single-letter names are acceptable** only in generic functions where the variable truly has no domain meaning (e.g., `a` in `List.map`), or in very short lambda expressions.

---

## 2. Code Formatting

### elm-format Is Canonical

All Elm code should be formatted by [elm-format](https://github.com/avh4/elm-format). It is a zero-configuration formatter (like `gofmt`) that enforces a single consistent style based on the [official Elm style guide](https://elm-lang.org/docs/style-guide). Run it on save; never argue about formatting.

### Indentation

elm-format uses **4-space indentation**. Tabs are never used.

```elm
formatAge : Locale -> Compactness -> String -> String -> Maybe String
formatAge loc compactness dob asOf =
    if String.isEmpty dob then
        Nothing

    else
        case computeAge dob asOf of
            Nothing ->
                Nothing

            Just ( months, diffDays ) ->
                Just (formatTier loc resolved months diffDays)
```

### Top-Level Declarations

- Always include a type annotation on every top-level declaration.
- Always bring the body of a declaration down one line from the `=` sign.
- Separate top-level declarations with **two blank lines**.

```elm
-- Good
resolveUnit : Int -> UnitForms -> Locale -> String -> String
resolveUnit count uf loc half =
    ...


stageLabel : Stages -> Int -> StageLabel
stageLabel stages months =
    ...
```

```elm
-- Bad: body on same line as =
homeDirectory : String
homeDirectory = "/root/files"

-- Bad: only one blank line between declarations
foo : Int
foo =
    1

bar : Int
bar =
    2
```

### Line Length

Keep lines under **80 characters**. Longer lines often indicate the code should be broken up. Locale data lines may exceed this, which is acceptable.

### Record Formatting

Use leading commas with the opening brace on the type alias line. Each field on its own line:

```elm
type alias Locale =
    { code : String
    , plural : Int -> PluralCategory
    , day : UnitForms
    , week : UnitForms
    , month : UnitForms
    , year : UnitForms
    , half : String
    , delimiter : String
    , justBorn : String
    , stages : Stages
    , short : Maybe CompactnessOverride
    , compact : Maybe CompactnessOverride
    }
```

This format produces clean diffs: adding or removing a field changes exactly one line.

### List Formatting

Use the same leading-comma style for multi-line lists:

```elm
imports =
    [ "SayableAge.Types"
    , "SayableAge.Formatter"
    , "SayableAge.Internal"
    ]
```

### Module Declaration and Imports

One blank line separates the module declaration from imports. Imports are separated from the first definition by two blank lines:

```elm
module SayableAge.Formatter exposing (formatAge, formatStage, version)

import SayableAge.Internal exposing (computeAge)
import SayableAge.Types
    exposing
        ( Compactness(..)
        , Gender
        , Locale
        , UnitForms(..)
        )


version : String
version =
    "0.5.0"
```

### Multi-Line Exposing

When the exposing list is long, break it across lines with leading commas:

```elm
module SayableAge.Types exposing
    ( Compactness(..)
    , CompactnessOverride
    , Gender(..)
    , Locale
    , PluralCategory(..)
    , StageLabel(..)
    , Stages
    , UnitForms(..)
    , lookupUnitForm
    , resolveStageLabel
    )
```

---

## 3. Type System

### Custom Types (Union Types)

Custom types are the primary tool for domain modeling. Each variant is listed on its own line with a leading `|` (except the first, which uses `=`):

```elm
type UnitForms
    = Simple String
    | Pluralized (List ( PluralCategory, String ))

type StageLabel
    = Neutral String
    | Gendered String String
```

### Type Aliases

Type aliases create an alternate name for an existing type. They are most commonly used for records:

```elm
type alias Stages =
    { newborn : StageLabel
    , infant : StageLabel
    , toddler : StageLabel
    , child : StageLabel
    , teenager : StageLabel
    , adult : StageLabel
    }
```

Record type aliases automatically generate a constructor function with fields in declaration order:

```elm
-- This type alias...
type alias Point =
    { x : Float
    , y : Float
    }

-- ...automatically creates this constructor:
-- Point : Float -> Float -> Point
-- So you can write:
origin = Point 0 0
```

### Opaque Types

Opaque types hide their constructors from other modules. Expose the type name but not its variants:

```elm
module Percent exposing (Percent, fromInt, toFloat)

type Percent
    = Percent Int

fromInt : Int -> Maybe Percent
fromInt n =
    if n >= 0 && n <= 100 then
        Just (Percent n)
    else
        Nothing

toFloat : Percent -> Float
toFloat (Percent n) =
    Basics.toFloat n / 100
```

Use opaque types to:
- Enforce invariants (the `Percent` above can never be negative or over 100)
- Hide implementation details so they can change without breaking callers
- Create distinct types from the same underlying representation (a `StudentId` and a `TeacherId` are both strings but should never be interchangeable)

### Phantom Types

Phantom types have a type variable that does not appear in any constructor. They let the compiler distinguish values at the type level without runtime cost:

```elm
type Unit a
    = Unit String

type Meters
    = Meters

type Seconds
    = Seconds

distance : Unit Meters
distance =
    Unit "5"

duration : Unit Seconds
duration =
    Unit "10"

-- The compiler will reject: combine distance duration
-- because Unit Meters /= Unit Seconds
```

Phantom types are an advanced technique. Use them when you need compile-time guarantees that two values of the same shape represent different quantities.

### Extensible Records

Extensible records use the `{ a | field : Type }` syntax to express "a record that has at least these fields":

```elm
getName : { a | name : String } -> String
getName record =
    record.name
```

The primary use of extensible records is to **narrow function arguments**. They allow a function to accept any record that has the required fields, rather than demanding a specific type alias:

```elm
viewUserName : { a | firstName : String, lastName : String } -> Html msg
viewUserName user =
    Html.text (user.firstName ++ " " ++ user.lastName)
```

Do **not** use extensible records for data modeling. Use concrete type aliases or custom types for your data structures.

---

## 4. Module Design

### Exposing Lists

Be explicit about what you expose. Avoid `exposing (..)` in module declarations for production code:

```elm
-- Good: explicit exports
module SayableAge exposing (formatAge, formatStage)

-- Acceptable for test modules
module FormatterTest exposing (suite)

-- Avoid in production modules
module SayableAge exposing (..)
```

When exposing a custom type, decide whether to expose constructors:
- `exposing (PluralCategory(..))` -- expose the type and all constructors (callers can pattern match)
- `exposing (PluralCategory)` -- expose only the type name (opaque type; callers cannot construct or destructure)

### Import Style

**Prefer qualified imports.** They make it clear where every function comes from:

```elm
-- Good: qualified
import SayableAge.Internal exposing (computeAge)
import SayableAge.Types
    exposing
        ( Compactness(..)
        , Locale
        , UnitForms(..)
        )

-- Good: qualified use without exposing
import Dict
-- usage: Dict.get, Dict.insert

-- Acceptable: alias long module names meaningfully
import Html.Attributes as Attr

-- Bad: cryptic alias
import Html.Attributes as HA

-- Bad: wildcard import hides origins
import Dict exposing (..)
```

**Never use `exposing (..)` on imports** unless the module is specifically designed for it (like `Html` and `Html.Attributes`, where function names are self-documenting and clashes are unlikely). Even then, limit it to one or two imports at most.

### Import Organization

Group imports in this order:
1. Non-exposing imports (qualified only)
2. Imports with explicit exposing lists
3. Wildcard imports (avoid these)

### Module Organization

Organize modules by domain concept, not by code shape. Do not split a feature into `Foo.Model`, `Foo.Msgs`, `Foo.Update`, `Foo.View`. Instead, keep related types, logic, and views together in one module, and split only when a module grows too large or when you need an opaque type boundary.

```elm
-- Good: one module per domain concept
SayableAge.Formatter   -- formatting logic
SayableAge.Types       -- shared types
SayableAge.Internal    -- internal helpers

-- Bad: split by code shape
SayableAge.Model
SayableAge.Update
SayableAge.View
SayableAge.Messages
```

### When to Create a New Module

Create a new module when you need to:
- Hide constructors behind an opaque type to enforce invariants
- Separate a genuinely independent concept that has its own types and logic
- Reduce the size of a module that has grown unwieldy

Do not create a module just to hold a single helper function or a type alias with no invariants.

### Ports

If your application uses ports, collect all port declarations in a single `port module` so the JavaScript interop surface is visible in one place:

```elm
port module Ports exposing (sendMessage, receiveMessage)

port sendMessage : String -> Cmd msg
port receiveMessage : (String -> msg) -> Sub msg
```

---

## 5. Function Design

### Pipeline Style

The pipeline operator `|>` is Elm's signature idiom. Use it to express a chain of transformations as a readable top-to-bottom flow:

```elm
-- Good: pipeline for multiple transformations
formatName name =
    name
        |> String.trim
        |> String.toLower
        |> String.split " "
        |> List.map capitalizeFirst
        |> String.join " "
```

Design functions so the primary data argument comes **last**, enabling natural piping:

```elm
-- Pipeable: data comes last
List.map : (a -> b) -> List a -> List b
List.filter : (a -> Bool) -> List a -> List a

-- Usage:
items
    |> List.filter isActive
    |> List.map .name
```

**Do not use a single-step pipeline.** If there is only one transformation, call the function directly:

```elm
-- Good
List.map toUpper names

-- Bad: unnecessary pipeline
names |> List.map toUpper
```

### Backward Application (`<|`)

Prefer parentheses over the backward application operator `<|` in most contexts:

```elm
-- Good
foo (bar (baz qux))

-- Bad
foo <| bar <| baz qux
```

The exception is test expressions, where `<|` reads naturally:

```elm
test "born today" <|
    \_ -> Expect.equal (Just "newborn") (fmt "2025-06-15" "2025-06-15")
```

### Composition Operators

Use `>>` (forward composition) and `<<` (backward composition) to build new functions from existing ones:

```elm
isEvenLength : String -> Bool
isEvenLength =
    String.length >> modBy 2 >> (==) 0
```

Avoid mixing directional operators. Use either the `|>` / `>>` pair or the `<|` / `<<` pair within a single expression, not both.

### Partial Application

All Elm functions are curried. Exploit partial application to create specialized versions:

```elm
-- Partial application creates a focused helper
fmt : String -> String -> Maybe String
fmt =
    formatAge en Normal

fmtShort : String -> String -> Maybe String
fmtShort =
    formatAge en Short
```

### Point-Free vs. Explicit

Point-free style (omitting named parameters) is appropriate when the resulting code is clear:

```elm
-- Good point-free: simple delegation
formatAge : Locale -> Compactness -> String -> String -> Maybe String
formatAge =
    SayableAge.Formatter.formatAge

-- Good point-free: simple composition
isPositive : Int -> Bool
isPositive =
    (<) 0
```

When point-free becomes hard to read, name the parameters:

```elm
-- Bad point-free: obscure
process = List.filter (not << String.isEmpty) >> List.map String.trim >> String.join ", "

-- Good explicit: clear
process items =
    items
        |> List.filter (not << String.isEmpty)
        |> List.map String.trim
        |> String.join ", "
```

### Anonymous Functions

Prefer `\_ ->` over `always` for discarding arguments:

```elm
-- Good
Maybe.map (\_ -> ()) value

-- Avoid
Maybe.map (always ()) value
```

### Function Length

Keep functions short and focused. Extract `let`-bound computations into top-level functions when they:
- Would benefit from a type annotation
- Are reusable
- Make the parent function hard to read

---

## 6. Data Modeling

### Making Impossible States Impossible

Design your types so that invalid states cannot be represented. This is the single most important data modeling principle in Elm.

```elm
-- Bad: these booleans allow contradictory states
type alias NetworkRequest =
    { loading : Bool
    , data : Maybe String
    , error : Maybe String
    }
-- Can have loading=True AND error=Just "..." -- impossible in reality

-- Good: only valid states are representable
type NetworkRequest
    = NotAsked
    | Loading
    | Success String
    | Failure String
```

### Custom Types Over Booleans

When a boolean distinguishes two domain concepts, use a custom type instead:

```elm
-- Bad: what does True mean? Caller must remember.
formatAge : Bool -> Int -> String

-- Good: self-documenting
type Compactness
    = Normal
    | Short
    | Compact

formatAge : Compactness -> Int -> String
```

### Custom Types Over Strings

Avoid "stringly typed" data. If a value comes from a known set, enumerate it:

```elm
-- Bad
type alias Gender =
    String  -- "M"? "m"? "male"? "Male"?

-- Good
type Gender
    = M
    | F
```

### Wrapper Types for Identifiers

Avoid using raw `String` or `Int` for identifiers. Wrap them in a custom type so the compiler catches mix-ups:

```elm
-- Bad: easy to swap studentId and teacherId
getGrades : String -> String -> List Grade

-- Good: compiler catches the swap
type StudentId = StudentId String
type TeacherId = TeacherId String

getGrades : StudentId -> TeacherId -> List Grade
```

### Co-locate Types and Their Operations

Place a type alias immediately before functions that construct, decode, or operate on it:

```elm
type alias User =
    { name : String
    , email : String
    }

userDecoder : Decoder User
userDecoder =
    succeed User
        |> required "name" string
        |> required "email" string
```

---

## 7. Pattern Matching

### Exhaustive Matching

Always match all constructors explicitly. Never use a wildcard `_` to catch "everything else" when you can enumerate the remaining cases. This ensures the compiler alerts you when a new variant is added:

```elm
-- Good: exhaustive
pluralCategoryToString : PluralCategory -> String
pluralCategoryToString cat =
    case cat of
        Zero ->
            "zero"

        One ->
            "one"

        Two ->
            "two"

        Few ->
            "few"

        Many ->
            "many"

        Other ->
            "other"

-- Bad: wildcard hides new variants
pluralCategoryToString : PluralCategory -> String
pluralCategoryToString cat =
    case cat of
        One ->
            "one"

        _ ->
            "other"
```

The exception is when matching on open types like `Int` or `String`, where exhaustive enumeration is impossible.

### Destructuring

Destructure in function arguments and `case` branches to avoid repeated field access:

```elm
-- Good: destructure in the case branch
resolveStageLabel : StageLabel -> Maybe Gender -> String
resolveStageLabel label gender =
    case label of
        Neutral s ->
            s

        Gendered m f ->
            case gender of
                Just F ->
                    f

                _ ->
                    m
```

Destructure records in function parameters when you use only a few fields:

```elm
-- Good for a few fields
viewName : { a | firstName : String, lastName : String } -> String
viewName { firstName, lastName } =
    firstName ++ " " ++ lastName
```

### Tuple Destructuring

Destructure tuples directly in `case` and `let`:

```elm
case computeAge dob asOf of
    Just ( months, diffDays ) ->
        ...

    Nothing ->
        ...
```

### Case Expression Formatting

Put each branch on its own line. Drop the body down one line from the `->`:

```elm
case compactness of
    Normal ->
        Nothing

    Short ->
        loc.short

    Compact ->
        loc.compact
```

---

## 8. Error Handling

### Elm Treats Errors as Data

Elm has no exceptions, no null, and no undefined. All potential failures are represented as values in the type system.

### Maybe

Use `Maybe` when a value may or may not exist and there is only one reason it might be absent:

```elm
formatAge : Locale -> Compactness -> String -> String -> Maybe String
formatAge loc compactness dob asOf =
    if String.isEmpty dob then
        Nothing
    else
        ...
```

**Avoid overusing Maybe.** When there are multiple reasons for absence, use a custom type or `Result` instead.

### Result

Use `Result` when failure carries meaningful information:

```elm
type alias Error =
    { code : Int
    , message : String
    }

parseDate : String -> Result Error Date
parseDate input =
    ...
```

### Chaining with andThen

Use `andThen` to sequence operations that can fail, avoiding nested `case` expressions:

```elm
-- Good: andThen chains
parseAndValidate : String -> Maybe ValidAge
parseAndValidate input =
    parseAge input
        |> Maybe.andThen validateRange
        |> Maybe.andThen normalizeAge

-- Equivalent but worse: nested cases
parseAndValidate : String -> Maybe ValidAge
parseAndValidate input =
    case parseAge input of
        Nothing ->
            Nothing

        Just age ->
            case validateRange age of
                Nothing ->
                    Nothing

                Just valid ->
                    normalizeAge valid
```

### Maybe.map and Maybe.withDefault

Use `Maybe.map` to transform a value inside a `Maybe` without unwrapping it. Use `Maybe.withDefault` to extract a value with a fallback:

```elm
day = Maybe.withDefault loc.day ovr.ovrDay

displayName =
    maybeNickname
        |> Maybe.map (\nick -> nick ++ " (" ++ fullName ++ ")")
        |> Maybe.withDefault fullName
```

### Never-Fail Patterns

When a function logically cannot fail but the type system requires handling the possibility, use a safe fallback:

```elm
lookupUnitForm : PluralCategory -> List ( PluralCategory, String ) -> String
lookupUnitForm cat forms =
    case findForm cat forms of
        Just s ->
            s

        Nothing ->
            case findForm Other forms of
                Just s ->
                    s

                Nothing ->
                    ""
```

---

## 9. Common Idioms

### Pipeline Operator (`|>`)

The pipeline is the most distinctive Elm idiom. Use it whenever you have two or more sequential transformations:

```elm
result =
    rawInput
        |> String.trim
        |> String.toLower
        |> validate
```

### Let Bindings

Use `let` to name intermediate values and improve readability:

```elm
formatTier : Locale -> Resolved -> Int -> Int -> String
formatTier loc r months diffDays =
    if months < 3 then
        let
            weeks =
                diffDays // 7

            days =
                modBy 7 diffDays

            wStr =
                resolveUnit weeks r.week loc ""
        in
        if days > 0 then
            wStr ++ r.delimiter ++ resolveUnit days r.day loc ""
        else
            wStr
    else
        ...
```

Keep `let` blocks focused. If a `let` block grows beyond 4-5 bindings, consider extracting some bindings into top-level helper functions.

### case-of vs. if-then-else

**Prefer `case-of`** for:
- Matching on custom types (mandatory)
- Matching on `Maybe` and `Result` values
- When you want the compiler to check exhaustiveness
- When branches may need reordering

```elm
case computeAge dob asOf of
    Nothing ->
        Nothing

    Just ( months, diffDays ) ->
        ...
```

**Use `if-then-else`** for:
- Simple boolean conditions
- Numeric comparisons and threshold checks
- When you have many sequential conditions and want to avoid deep indentation

```elm
stageLabel : Stages -> Int -> StageLabel
stageLabel stages months =
    if months < 2 then
        stages.newborn
    else if months < 12 then
        stages.infant
    else if months < 36 then
        stages.toddler
    else if months < 156 then
        stages.child
    else if months < 216 then
        stages.teenager
    else
        stages.adult
```

### Record Update Syntax

Use record update syntax to create a new record with some fields changed:

```elm
moveRight : Int -> Point -> Point
moveRight dx point =
    { point | x = point.x + dx }
```

### String Interpolation

Elm does not have string interpolation. Use `++` for concatenation and `String.replace` for templates:

```elm
-- Concatenation
greeting =
    "Hello, " ++ user.name ++ "!"

-- Template replacement
result =
    String.replace "{n}" (String.fromInt count) template
```

### Test Structure

Use `describe` to group tests and `test` for individual assertions. The `<|` operator is idiomatic here:

```elm
suite : Test
suite =
    describe "SayableAge"
        [ describe "Null / edge cases"
            [ test "null dateOfBirth" <|
                \_ -> Expect.equal Nothing (fmt "" "2025-06-15")
            , test "future DOB" <|
                \_ -> Expect.equal Nothing (fmt "2025-07-01" "2025-06-15")
            ]
        , describe "Days tier"
            [ test "born today" <|
                \_ -> Expect.equal (Just "newborn") (fmt "2025-06-15" "2025-06-15")
            ]
        ]
```

---

## 10. Things to Avoid

### Wildcard Imports

```elm
-- Avoid: hides where functions come from
import Dict exposing (..)
import List exposing (..)

-- Good: explicit
import Dict
import List
```

The only acceptable uses of `exposing (..)` on imports are for modules specifically designed for it, like `Html` or test helpers, and even then sparingly.

### Stringly Typed Data

Never use a `String` when a custom type is appropriate. Strings cannot be checked at compile time:

```elm
-- Bad
setColor : String -> Widget -> Widget
-- What if someone passes "grene"?

-- Good
type Color = Red | Green | Blue
setColor : Color -> Widget -> Widget
```

### Overly Nested Expressions

Deep nesting is a signal to refactor. Extract named functions or use `andThen`:

```elm
-- Bad: deeply nested
process input =
    case parse input of
        Ok data ->
            case validate data of
                Ok valid ->
                    case transform valid of
                        Ok result ->
                            Just result
                        Err _ ->
                            Nothing
                Err _ ->
                    Nothing
        Err _ ->
            Nothing

-- Good: use andThen
process input =
    parse input
        |> Result.andThen validate
        |> Result.andThen transform
        |> Result.toMaybe
```

### Premature Abstraction

Do not create abstractions (extra modules, generic types, helper libraries) until you have seen the same pattern at least twice in real code:

- Do not create a `Foo.Extra` module for a function used in one place.
- Do not make a type generic unless two callers actually need different type parameters.
- Do not extract a module just to hold a single type alias.

### Giant Let Expressions

Huge `let` blocks make functions hard to follow. If you have more than 5-6 bindings, extract some into top-level functions with type annotations:

```elm
-- Bad: giant let
view model =
    let
        headerHtml = ...
        sidebarHtml = ...
        contentHtml = ...
        footerHtml = ...
        modalHtml = ...
        tooltipHtml = ...
        notificationHtml = ...
    in
    ...

-- Good: extract to top-level functions
view model =
    Html.div []
        [ viewHeader model
        , viewSidebar model
        , viewContent model
        , viewFooter model
        ]
```

### Using `always` Instead of `\_ ->`

The anonymous function `\_ ->` is more recognizable and easier to refactor than `always`:

```elm
-- Prefer
Maybe.map (\_ -> ()) value

-- Avoid
Maybe.map (always ()) value
```

### Unnecessary Type Aliases for Function Arguments

In function signatures, inline record types can give better compiler error messages than type aliases:

```elm
-- Consider: inline record type for better errors
config : { width : Int, height : Int } -> Widget

-- vs. type alias (hides the structure in error messages)
type alias WidgetConfig = { width : Int, height : Int }
config : WidgetConfig -> Widget
```

This is a trade-off. Type aliases are better for reuse and documentation; inline records are better for one-off configuration arguments.

### Nested Records in Type Aliases

Avoid inline record types nested within other record type aliases. Define separate aliases for nested structures:

```elm
-- Bad: nested inline record
type alias Model =
    { user : { name : String, email : String }
    , settings : { theme : String, language : String }
    }

-- Good: separate aliases
type alias User =
    { name : String
    , email : String
    }

type alias Settings =
    { theme : String
    , language : String
    }

type alias Model =
    { user : User
    , settings : Settings
    }
```

---

## 11. Tooling

### elm-format

[elm-format](https://github.com/avh4/elm-format) is the standard, non-negotiable code formatter for Elm. It has no configuration options by design.

- **Run it on every save.** Configure your editor to format on save.
- **Never argue about formatting.** elm-format decides; the team follows.
- **Check in CI.** Run `elm-format --validate src/` to ensure all committed code is formatted.

### elm-review

[elm-review](https://github.com/jfmengels/elm-review) is a static analysis tool that reports patterns configured via rules written in Elm. Unlike traditional linters, it ships with no built-in rules -- you choose and install rule packages.

Key rule packages:

| Package | Purpose |
|---|---|
| [jfmengels/elm-review-unused](https://github.com/jfmengels/elm-review-unused) | Detect unused variables, types, constructors, exports, dependencies, parameters, and patterns |
| [jfmengels/elm-review-simplify](https://github.com/jfmengels/elm-review-simplify) | Simplify expressions (e.g., `List.map identity list` to `list`) |
| [jfmengels/elm-review-common](https://github.com/jfmengels/elm-review-common) | Common best-practice rules |
| [jfmengels/elm-review-cognitive-complexity](https://github.com/jfmengels/elm-review-cognitive-complexity) | Flag functions with high cognitive complexity |

Recommended starter rules:
- `NoUnused.Variables` -- reports unused top-level variables, imports, and imported values
- `NoUnused.CustomTypeConstructors` -- reports constructors that are defined but never used
- `NoUnused.Exports` -- reports exposed functions/types that no other module imports
- `NoUnused.Dependencies` -- reports dependencies listed in `elm.json` that are never imported
- `Simplify` -- auto-fixes expressions that can be reduced

elm-review rules should be discussed and agreed upon by the team. Because errors cannot be easily suppressed, rules must be high quality with few false positives.

### elm-test

[elm-test](https://github.com/elm-explorations/test) is the standard testing framework. Key conventions:

- Use `describe` to group related tests. Use `test` for individual test cases.
- Every test should have a unique, descriptive string label.
- Prefer fuzz tests over unit tests when a property should hold for arbitrary inputs.
- Test modules mirror source modules: `src/Foo.elm` is tested by `tests/FooTest.elm`.
- Test only the exposed API. Do not expose internal functions just to test them.
- Use `Expect.equal expected actual` (expected value first).

```elm
import Expect
import Test exposing (Test, describe, test)

suite : Test
suite =
    describe "String.reverse"
        [ test "reverses a known string" <|
            \_ -> Expect.equal "dcba" (String.reverse "abcd")
        , test "is its own inverse" <|
            \_ ->
                let
                    input = "hello"
                in
                Expect.equal input (String.reverse (String.reverse input))
        ]
```

### elm.json

`elm.json` is the project manifest. Key points:
- List only direct dependencies, not transitive ones (Elm manages those automatically).
- Keep `source-directories` minimal, typically just `["src"]`.
- The `elm-version` field constrains which compiler versions can build the project.

---

## Sources

- [Official Elm Style Guide](https://elm-lang.org/docs/style-guide)
- [elm-format](https://github.com/avh4/elm-format) -- the canonical Elm formatter
- [NoRedInk Elm Style Guide](https://github.com/NoRedInk/elm-style-guide) -- production conventions from the largest Elm codebase
- [ohanhi/elm-style-guide](https://github.com/ohanhi/elm-style-guide) -- community best practices
- [Elm Guide: Error Handling](https://guide.elm-lang.org/error_handling/)
- [Elm Guide: Types](https://guide.elm-lang.org/types/)
- [Elm Guide: Modules](https://guide.elm-lang.org/webapps/modules.html)
- [Elm Guide: Ports](https://guide.elm-lang.org/interop/ports.html)
- [Elm Type Glossary](https://gist.github.com/JoelQ/6b303d9ad450537163b6f8f6cf8a4ed8) -- definitions of opaque, phantom, and other type patterns
- [Elm Patterns: Opaque Types](https://sporto.github.io/elm-patterns/advanced/opaque-types.html)
- [Elm Patterns: Phantom Types](https://sporto.github.io/elm-patterns/advanced/phantom-types.html)
- [elm-review](https://github.com/jfmengels/elm-review) -- static analysis for Elm
- [elm-review-unused](https://github.com/jfmengels/elm-review-unused)
- [elm-review-simplify](https://github.com/jfmengels/elm-review-simplify)
- [elm-test](https://github.com/elm-explorations/test) -- the standard test framework
- [Making Impossible States Impossible](https://www.youtube.com/watch?v=IcgmSRJHu_8) -- Richard Feldman's influential Elm conf talk
- [Elm Function Operators Guide](https://harfangk.github.io/2018/01/27/elm-function-operators.html)
- [Elm Radio: Intro to Opaque Types](https://elm-radio.com/episode/intro-to-opaque-types/)
- [Elm Radio: elm-format](https://elm-radio.com/episode/elm-format/)
- [Elm Radio: elm-review Tips](https://elm-radio.com/episode/elm-review-tips/)
