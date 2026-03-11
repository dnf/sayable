# OCaml Style Guide

A comprehensive reference for idiomatic OCaml coding style and best practices. Intended for code auditing OCaml implementations.

## Sources

This guide synthesizes conventions from the following authoritative references:

- [OCaml Programming Guidelines](https://ocaml.org/docs/guidelines) (ocaml.org)
- [Real World OCaml, 2nd Edition](https://dev.realworldocaml.org/) (Minsky, Madhavapeddy, Hickey)
- [OCaml Manual](https://v2.ocaml.org/api/) (INRIA)
- [Jane Street style conventions](https://opensource.janestreet.com/) (via Base/Core libraries)
- [OCamlformat documentation](https://github.com/ocaml-ppx/ocamlformat)

---

## 1. Naming Conventions

### Casing Rules

| Element | Convention | Example |
|---|---|---|
| Modules | UpperCamelCase | `StringMap`, `AgeLocale`, `Formatter` |
| Module types (signatures) | UpperCamelCase or UPPER_SNAKE | `Comparable`, `S`, `MAP` |
| Functors | UpperCamelCase, often `Make` | `Map.Make`, `Set.Make`, `Hashtbl.Make` |
| Types | lowercase_with_underscores | `plural_category`, `unit_forms`, `age_locale` |
| Type variables | `'a`, `'b`, `'key`, `'value` | `'a list`, `('key, 'value) hashtbl` |
| Variant constructors | UpperCamelCase | `Some`, `None`, `Zero`, `One`, `Other` |
| Polymorphic variant tags | Backtick + UpperCamelCase | `` `Int ``, `` `Float ``, `` `Error `` |
| Record fields | lowercase_with_underscores | `first_name`, `plural_rule`, `just_born` |
| Values and functions | lowercase_with_underscores | `format_age`, `string_of_int`, `is_leap_year` |
| Constants | lowercase_with_underscores | `max_months`, `default_locale` |
| Exception names | UpperCamelCase | `Not_found`, `Invalid_argument`, `Parse_error` |

### Naming Principles

- **Use underscores to separate words**, not camelCase: `int_of_string`, not `intOfString`. This is the universal OCaml convention.
- **Capitalize only constructors and module names.** Everything else is lowercase.
- **Avoid abbreviations** for global identifiers. Write `format_age`, not `fmt_age`. Local variables can be brief: `s` for a string, `n` for an integer, `l` or `xs` for a list.
- **Avoid confusing single characters.** Do not use `l` (lowercase L) as a variable name -- it is visually indistinct from `1`.
- **Name the primary type `t`** in a module. Functions that operate on it take `t` as the first argument. This is the universal OCaml/Jane Street convention:

```ocaml
module Locale : sig
  type t
  val code : t -> string
  val create : string -> t option
end
```

- **Suffix exception-raising variants with `_exn`:**

```ocaml
val find : 'a list -> f:('a -> bool) -> 'a option
val find_exn : 'a list -> f:('a -> bool) -> 'a
```

- **Use `of` for conversion functions** from one type to another: `string_of_int`, `float_of_string`. The newer Base convention reverses this: `Int.of_string`, `Float.to_string`.
- **Use consistent names for similar parameters** across functions:

```ocaml
let format_age locale compactness dob as_of = ...
let format_stage locale dob as_of gender = ...
```

---

## 2. Code Formatting

### ocamlformat

Use [ocamlformat](https://github.com/ocaml-ppx/ocamlformat) for automated formatting. Create a `.ocamlformat` file in the project root:

```
profile = default
version = 0.28.1
```

Available profiles:

| Profile | Description |
|---|---|
| `default` | The standard ocamlformat profile; suitable for most projects |
| `janestreet` | Jane Street conventions; wider lines, more compact |
| `ocamlformat` | The ocamlformat team's own preferences |

Pin the version in `.ocamlformat` to ensure consistent formatting across environments. Run formatting via `dune fmt` for project-wide application.

### Indentation

- Use **2 spaces** for indentation. This is the OCaml community standard.
- **Never use tab characters.** Spaces only.
- Maximum line width: **80 columns** (default profile) or **90-100** (janestreet profile).

### Let Bindings

Align `let ... in` chains vertically. Each binding starts at the same indentation level:

```ocaml
let x = compute_something () in
let y = transform x in
let z = finalize y in
combine x y z
```

For `let ... and` (mutual recursion), align the `and` with `let`:

```ocaml
let rec is_even n =
  if n = 0 then true else is_odd (n - 1)
and is_odd n =
  if n = 0 then false else is_even (n - 1)
```

### Match Expressions

All clauses start with `|`, including the first. Indent the body when it overflows:

```ocaml
match expr with
| Pattern1 -> short_result
| Pattern2 ->
  longer_expression_that
    does_not_fit_on_one_line
| Pattern3 (x, y) ->
  let intermediate = compute x in
  combine intermediate y
```

For nested match expressions, use `begin ... end` to delimit:

```ocaml
match outer with
| A ->
  begin match inner with
  | X -> handle_x
  | Y -> handle_y
  end
| B -> handle_b
```

### If-Then-Else

Short expressions can be one line. Longer ones break after `then` and `else`:

```ocaml
(* Short *)
if condition then value_a else value_b

(* Multi-line *)
if condition then
  longer_expression_here
else
  alternative_expression

(* Chained conditions *)
if cond1 then e1
else if cond2 then e2
else if cond3 then e3
else e4
```

### Function Definitions

```ocaml
(* Short function *)
let square x = x * x

(* Longer function with type annotation *)
let format_age (locale : locale) (compactness : compactness) (dob : string)
    (as_of : string) : string option =
  ...

(* Function using pattern matching directly *)
let rec length = function
  | [] -> 0
  | _ :: tl -> 1 + length tl
```

### Operators and Spacing

- Surround binary operators with spaces: `x + 1`, `a && b`, `x :: xs`.
- No space after `!` (dereference): `!x`.
- No space around `.` (field access): `record.field`.
- Space after `;` in lists and records: `[1; 2; 3]`, `{ a = 1; b = 2 }`.
- Space inside parenthesized tuples: `(x, y, z)`.

When operators span lines, start the continuation line with the operator:

```ocaml
long_expression
+ another_expression
+ final_expression
```

### Parentheses

Follow standard mathematical precedence. Do not add redundant parentheses for well-known precedences:

```ocaml
(* Clear without extra parens *)
1 + 2 * x
f x + g y
a < b && c > d

(* Use parens when precedence is genuinely unclear *)
x land (y lor z)
```

Use `begin ... end` rather than parentheses for delimiting multi-expression blocks, especially within match arms and if/then/else:

```ocaml
if condition then begin
  side_effect ();
  compute_result ()
end else begin
  other_effect ();
  other_result ()
end
```

---

## 3. Type System

### Variant Types

Use variant types (sum types) to model data with distinct cases. Prefer explicit constructors over encoding with booleans or integers:

```ocaml
(* Good: explicit sum type *)
type compactness = Normal | Short | Compact

(* Bad: encoding with integers *)
let normal = 0
let short = 1
let compact = 2
```

Variants enable exhaustive pattern matching and compiler-checked refactoring.

### Records

Use records for conjunctions of named fields. Prefer immutable records by default:

```ocaml
type locale = {
  code : string;
  plural : int -> plural_category;
  day : unit_forms;
  week : unit_forms;
  month : unit_forms;
  year : unit_forms;
  half : string;
  delimiter : string;
  just_born : string;
}
```

Use functional update syntax for creating modified copies:

```ocaml
let updated = { original with half = "1/2"; delimiter = " " }
```

Mark fields `mutable` only when mutation is genuinely needed:

```ocaml
type counter = {
  mutable count : int;
  name : string;
}
```

Enable warning 9 (`#warnings "+9"`) to catch incomplete record patterns. When intentionally ignoring fields, use the underscore wildcard:

```ocaml
let get_code { code; _ } = code
```

When multiple record types share field names, place them in separate modules:

```ocaml
module Person = struct
  type t = { name : string; age : int }
end

module Company = struct
  type t = { name : string; founded : int }
end
```

### Polymorphic Variants

Polymorphic variants use backtick-prefixed tags and do not require prior type declaration:

```ocaml
let classify x =
  if x > 0 then `Positive
  else if x < 0 then `Negative
  else `Zero
```

Type annotations for polymorphic variants use bracket notation:

| Syntax | Meaning |
|---|---|
| `[> \`A \| \`B ]` | At least these tags (open, can accept more) |
| `[< \`A \| \`B ]` | At most these tags (closed, subset) |
| `[ \`A \| \`B ]` | Exactly these tags |

**When to use polymorphic variants vs. regular variants:**

| Use regular variants when... | Use polymorphic variants when... |
|---|---|
| The set of cases is fixed and well-known | Tags are shared across multiple related types |
| Exhaustiveness checking is critical | Lightweight ad-hoc unions improve conciseness |
| Refactoring safety matters most | Extensibility across module boundaries is needed |

**Downsides of polymorphic variants:** more complex typing rules, typos in tags compile without error (unlike regular variants), and slightly higher runtime overhead.

### Phantom Types

Phantom types are type parameters that appear in the type definition but not in the data representation. They enforce invariants at the type level:

```ocaml
type readonly
type readwrite

type 'a file_handle = { fd : Unix.file_descr }

val open_readonly : string -> readonly file_handle
val open_readwrite : string -> readwrite file_handle
val write : readwrite file_handle -> string -> unit  (* only accepts readwrite *)
val read : _ file_handle -> string                   (* accepts any mode *)
```

Phantom types are fragile without GADTs because the compiler cannot enforce that constructors produce specific phantom parameters. Use GADTs when the invariant is safety-critical.

### GADTs (Generalized Algebraic Data Types)

GADTs allow each constructor to constrain its result type. Use them when they provide a "big qualitative improvement" to the design:

```ocaml
type _ expr =
  | Int : int -> int expr
  | Bool : bool -> bool expr
  | Plus : int expr * int expr -> int expr
  | If : bool expr * 'a expr * 'a expr -> 'a expr
```

Evaluation functions require locally abstract type annotations:

```ocaml
let rec eval : type a. a expr -> a = function
  | Int n -> n
  | Bool b -> b
  | Plus (x, y) -> eval x + eval y
  | If (c, t, e) -> if eval c then eval t else eval e
```

**When to use GADTs:**
- Typed expression languages or DSLs
- Functions whose return type depends on the constructor
- Existential types (heterogeneous collections)
- State machine narrowing at the type level

**When to avoid GADTs:**
- Small, simple programs where the added complexity is not justified
- When or-patterns are needed (GADTs do not work well with them)
- When `[@@deriving sexp]` or similar ppx derivations are required

### Modules as Types

Encapsulate types and their operations in modules. Use abstract types to enforce invariants:

```ocaml
(* In .mli *)
module Locale : sig
  type t  (* abstract -- callers cannot construct directly *)
  val of_code : string -> t option
  val code : t -> string
  val format : t -> int -> string
end
```

Abstract types prevent callers from bypassing validation logic. Expose concrete types only when pattern matching provides significant value and invariants are naturally enforced by the data structure.

---

## 4. Module Design

### Signature Files (.mli)

Write `.mli` files to define module interfaces. They serve as both documentation and access control:

```ocaml
(* formatter.mli *)

val version : string
(** The library version. *)

val format_age : Types.locale -> Types.compactness -> string -> string option -> string option
(** [format_age locale compactness dob as_of] formats a human-readable age string.
    Returns [None] if the date of birth is invalid. *)

val format_stage : Types.locale -> string -> string option -> Types.gender option -> string option
(** [format_stage locale dob as_of gender] returns the life stage label. *)
```

**Best practices for .mli files:**
- Write the `.mli` before the `.ml` to clarify design intent.
- Place documentation comments (`(** ... *)`) in the `.mli`, not the `.ml`.
- Expose only what callers need. Hide internal helpers.
- All declarations in the `.mli` must have matching definitions in the `.ml`.
- Type definition order (constructors, record fields) must match between `.mli` and `.ml`.

### Functors

Functors are functions from modules to modules. Use them for:

1. **Dependency injection** -- swap implementations for testing or configuration.
2. **Autoextension** -- derive operations (comparison, hashing, iteration) from a minimal interface.
3. **Module instantiation with state** -- create independent instances with separate mutable state.

```ocaml
module type COMPARABLE = sig
  type t
  val compare : t -> t -> int
end

module Make_set (Elt : COMPARABLE) : sig
  type t
  val empty : t
  val add : Elt.t -> t -> t
  val mem : Elt.t -> t -> bool
end
```

Use destructive substitution (`:=`) to remove redundant intermediate type names from the output signature:

```ocaml
module Make (Arg : COMPARABLE) : (S with type elt := Arg.t) = struct
  ...
end
```

Use sharing constraints (`=`) when the type name needs to remain visible:

```ocaml
module Make (Arg : COMPARABLE) : (S with type elt = Arg.t) = struct
  ...
end
```

**When to avoid functors:** "For small and simple programs, heavy use of functors is probably a mistake." Use them when the abstraction genuinely earns its weight.

### First-Class Modules

First-class modules are ordinary values that contain modules. They bridge the module and value worlds:

```ocaml
(* Pack a module into a value *)
let locale_module = (module English : LOCALE)

(* Unpack back to a module *)
let (module L) = locale_module in
L.format_age dob as_of
```

**Use first-class modules when:**
- Handler selection depends on runtime values.
- Multiple interchangeable implementations must be stored in a collection.
- Runtime module loading/unloading is needed.

**Prefer closures when:** the abstraction is simple and does not require bundling multiple functions or types.

### Open and Include

**Avoid unqualified `open`** at the top of files. It pollutes the namespace and obscures the origin of identifiers. Use qualified access instead:

```ocaml
(* Avoid *)
open List
let n = length my_list

(* Prefer *)
let n = List.length my_list
```

**Local opens** are acceptable for narrowing scope:

```ocaml
let result =
  let open Float in
  (of_int x /. of_int y) *. 100.0

(* Or the inline syntax *)
let result = Float.(of_int x /. of_int y *. 100.0)
```

**`include`** adds identifiers to the current module (unlike `open`, which only changes lookup). Use it for extending module interfaces:

```ocaml
module Extended_list = struct
  include List
  let hd_opt = function
    | [] -> None
    | x :: _ -> Some x
end
```

### Cyclic Dependencies

OCaml disallows cyclic module dependencies by default. Structure your modules into a DAG (directed acyclic graph). If mutual dependencies are genuinely needed, use `recursive module` syntax, but this is rarely necessary and usually signals a design problem.

---

## 5. Pattern Matching

### Exhaustive Matching

Always write exhaustive matches. The compiler warns about missing cases -- treat these warnings as errors. Prefer listing all constructors explicitly over using a catch-all `_`:

```ocaml
(* Good: compiler will warn if a new constructor is added *)
let to_string = function
  | Zero -> "zero"
  | One -> "one"
  | Two -> "two"
  | Few -> "few"
  | Many -> "many"
  | Other -> "other"

(* Bad: catch-all suppresses future warnings *)
let to_string = function
  | Zero -> "zero"
  | _ -> "non-zero"
```

The only exception: when the catch-all is genuinely the correct semantics for any future additions.

### Or-Patterns

Combine cases that share the same handler:

```ocaml
let is_weekend = function
  | Saturday | Sunday -> true
  | Monday | Tuesday | Wednesday | Thursday | Friday -> false
```

### Guard Clauses

Use `when` guards for conditions that cannot be expressed by patterns alone:

```ocaml
let classify_temp temp = match temp with
  | t when t < 0 -> "freezing"
  | t when t < 20 -> "cold"
  | t when t < 30 -> "warm"
  | _ -> "hot"
```

**Caution:** Guards compromise exhaustiveness checking. The compiler cannot verify that guards cover all cases. Use them sparingly.

### As-Patterns

Bind a name to a matched value or subpattern to avoid unnecessary reconstruction:

```ocaml
let rec remove_sequential_duplicates = function
  | [] | [_] as l -> l  (* return the original list, no allocation *)
  | first :: (second :: _ as tl) ->
    if first = second then remove_sequential_duplicates tl
    else first :: remove_sequential_duplicates tl
```

### Destructuring in Let Bindings

Use destructuring `let` only for exhaustive patterns (tuples, single-constructor types):

```ocaml
(* Good: tuple is always exhaustive *)
let (x, y) = point

(* Good: record is always exhaustive *)
let { code; plural; _ } = locale

(* Bad: list pattern is not exhaustive -- use match instead *)
let [a; b; c] = some_list  (* compiler warning *)
```

### Nested Pattern Matching

For complex data, match deeply in a single pattern rather than nesting match expressions:

```ocaml
(* Prefer: single deep match *)
let handle = function
  | Some (Ok value) -> use value
  | Some (Error msg) -> report msg
  | None -> default_value

(* Avoid: nested matches *)
let handle opt =
  match opt with
  | Some result ->
    (match result with
     | Ok value -> use value
     | Error msg -> report msg)
  | None -> default_value
```

### Pattern Matching on Strings

Use match on strings rather than chains of `if ... else if`:

```ocaml
(* Good *)
let stage_key months =
  match classify_months months with
  | "newborn" -> stages.newborn
  | "infant" -> stages.infant
  | "toddler" -> stages.toddler
  | _ -> stages.adult

(* Better: use a variant type instead of strings *)
type stage = Newborn | Infant | Toddler | Child | Teenager | Adult
```

---

## 6. Error Handling

### Three Mechanisms

OCaml provides three approaches to error handling, each with different trade-offs:

| Mechanism | Signal | Error detail | Caller must handle? |
|---|---|---|---|
| `option` | Something may be absent | No | Yes (pattern match) |
| `result` | Operation may fail | Yes (`Error` payload) | Yes (pattern match) |
| Exceptions | Something went wrong | Yes (exception value) | No (can propagate silently) |

### Option

Use `option` when a value may be absent and the reason is obvious from context:

```ocaml
let parse_date s : (int * int * int) option =
  if String.length s < 10 then None
  else (* ... *)
    Some (year, month, day)

(* Caller must handle both cases *)
match parse_date input with
| Some (y, m, d) -> process y m d
| None -> handle_missing ()
```

### Result

Use `result` when callers need to know why something failed:

```ocaml
type format_error =
  | Invalid_date of string
  | Future_birth of string
  | Age_too_large of int

val format_age : locale -> string -> string -> (string, format_error) result
```

Chain `result` computations with `Result.bind` or monadic let syntax:

```ocaml
let ( let* ) = Result.bind

let process input =
  let* date = parse_date input in
  let* age = compute_age date in
  Ok (format age)
```

### Exceptions

Use exceptions for truly exceptional conditions that are rare and often unrecoverable at the call site:

```ocaml
(* Standard library exceptions *)
raise Not_found
raise (Invalid_argument "index out of bounds")
raise (Failure "unexpected state")

(* Custom exceptions *)
exception Parse_error of string * int  (* message, position *)

(* Handling *)
try
  risky_operation ()
with
| Not_found -> fallback_value
| Parse_error (msg, pos) -> report_error msg pos
```

### When to Use Which

| Situation | Use |
|---|---|
| Value may be absent, reason is obvious | `option` |
| Operation may fail, caller needs error details | `result` |
| Failure is rare, often unrecoverable | Exception |
| Returning from a deeply nested computation | Exception (then catch at boundary) |
| Public API boundary | `option` or `result` (never expose exceptions) |

### Exception Best Practices

- **Never use `try ... with _ -> ...`** (catch-all) except in top-level handlers. Name the exception and handle it specifically or re-raise after cleanup:

```ocaml
try
  process ic oc;
  close_in ic;
  close_out oc
with exn ->
  close_in ic;
  close_out oc;
  raise exn
```

- **Suffix exception-raising functions with `_exn`** to signal their behavior in the name.
- **Prefer narrow exception handlers.** Catch only the exceptions you expect.
- **Reuse standard exceptions** (`Not_found`, `Invalid_argument`, `Failure`) when they fit semantically. Define custom exceptions for domain-specific failures.
- **Use `Exn.protect` or `Fun.protect`** for guaranteed cleanup:

```ocaml
Fun.protect ~finally:(fun () -> close_in ic)
  (fun () -> process ic)
```

---

## 7. Functional Patterns

### Pipe Operator

The pipe operator `|>` passes the result of the left expression as the last argument to the right function. Use it to write left-to-right transformation pipelines:

```ocaml
let result =
  input
  |> parse_date
  |> Option.map compute_months
  |> Option.map format_output
```

Pipes improve readability when chaining 2-5 transformations. For longer chains, consider breaking into intermediate `let` bindings.

### List, Array, and Seq Modules

Prefer library iterators over manual recursion:

```ocaml
(* Use List.map, not manual recursion *)
let squares = List.map (fun x -> x * x) numbers

(* Use List.filter *)
let positives = List.filter (fun x -> x > 0) numbers

(* Use List.iter for side effects *)
List.iter print_endline names

(* Use List.find_opt, not manual search *)
let result = List.find_opt (fun x -> x > 10) numbers
```

### Fold

`List.fold_left` is the workhorse for accumulating a result across a collection:

```ocaml
(* Sum *)
let sum = List.fold_left ( + ) 0 numbers

(* Build a string *)
let csv = List.fold_left
  (fun acc s -> if acc = "" then s else acc ^ "," ^ s)
  "" items

(* Build a map *)
let index = List.fold_left
  (fun acc (k, v) -> StringMap.add k v acc)
  StringMap.empty pairs
```

**Direction:** Use `fold_left` by default (tail-recursive, processes left-to-right). Use `fold_right` only when building right-associative structures (like lists) where the order matters.

### Partial Application

OCaml functions are curried by default. Provide some arguments to create specialized functions:

```ocaml
let add x y = x + y
let add_five = add 5         (* partially applied *)
let result = add_five 3      (* 8 *)

(* Useful with higher-order functions *)
let double_all = List.map (( * ) 2)
```

### Function Composition

While OCaml does not have a built-in composition operator, you can define one or use pipe chains:

```ocaml
(* Pipe chain (preferred -- reads left to right) *)
let result = x |> f |> g |> h

(* Composition (less common in OCaml) *)
let compose f g x = f (g x)
```

### Higher-Order Function Idioms

```ocaml
(* filter_map: transform and filter simultaneously *)
let valid_ages =
  List.filter_map (fun s ->
    match parse_age s with
    | Some age when age >= 0 -> Some age
    | _ -> None
  ) inputs

(* partition: split into two lists *)
let (adults, minors) = List.partition (fun p -> p.age >= 18) people

(* for_all / exists *)
let all_valid = List.for_all is_valid inputs
let has_errors = List.exists is_error results
```

---

## 8. Imperative Features

### When to Use Mutation

OCaml defaults to immutability, which is "generally easier to reason about, less error prone and more composable." Use mutation when:

- **Interacting with the outside world** (I/O, system calls, FFI).
- **Performance requires it** (some algorithms are only efficient with mutable state).
- **Local, contained mutation** simplifies an otherwise convoluted functional solution.

### Refs

Refs are single-cell mutable containers:

```ocaml
let counter = ref 0          (* create *)
let current = !counter       (* read with ! *)
counter := !counter + 1      (* write with := *)
```

**Prefer functional style when possible.** This imperative loop:

```ocaml
(* Avoid *)
let sum l =
  let acc = ref 0 in
  List.iter (fun x -> acc := !acc + x) l;
  !acc
```

is better written as:

```ocaml
(* Prefer *)
let sum l = List.fold_left ( + ) 0 l
```

### Mutable Record Fields

Use sparingly, for fields that genuinely need in-place update:

```ocaml
type buffer = {
  data : bytes;
  mutable pos : int;
}

let write buf c =
  Bytes.set buf.data buf.pos c;
  buf.pos <- buf.pos + 1
```

### Arrays

Arrays provide constant-time indexed access:

```ocaml
let arr = [| 1; 2; 3; 4; 5 |]
let third = arr.(2)            (* read *)
arr.(2) <- 99                   (* write *)
```

Use arrays when random access is needed. Use lists when sequential processing is the primary pattern.

### Loops

**For loops** iterate over an inclusive range:

```ocaml
for i = 0 to Array.length arr - 1 do
  Printf.printf "%d\n" arr.(i)
done
```

**While loops** are rarely needed. The official guidelines warn: "A while loop is usually wrong, unless its loop invariant has been explicitly written." Prefer recursion:

```ocaml
(* Acceptable: imperative string search *)
let string_contains ~needle haystack =
  let nlen = String.length needle in
  let hlen = String.length haystack in
  let found = ref false in
  let i = ref 0 in
  while !i <= hlen - nlen && not !found do
    if String.sub haystack !i nlen = needle then found := true
    else i := !i + 1
  done;
  !found

(* Better when feasible: recursive *)
let rec find_index lst target = match lst with
  | [] -> None
  | x :: _ when x = target -> Some 0
  | _ :: rest -> Option.map (( + ) 1) (find_index rest target)
```

### Sequencing

Use `;` to sequence expressions that return `unit`. Use `let _ = ...` or `ignore` when discarding a non-unit result:

```ocaml
(* Sequencing unit expressions *)
print_string "hello";
print_newline ()

(* Discarding a result *)
ignore (List.map f l);  (* but prefer List.iter when you don't need the result *)
```

### Defer Side Effects

Perform all side-effecting operations at the end of a function to minimize the window for exception-related state corruption:

```ocaml
(* Good: pure computation first, side effects last *)
let process input =
  let result = expensive_pure_computation input in
  let formatted = format_output result in
  write_to_file formatted;
  log_completion ()
```

---

## 9. Common Idioms

### Monadic Binding (let* and let+)

OCaml 4.08+ provides binding operators for monadic chaining. Define `let*` for `bind` and `let+` for `map`:

```ocaml
(* For Option *)
let ( let* ) = Option.bind
let ( let+ ) x f = Option.map f x

let compute_age dob as_of =
  let* (dy, dm, dd) = parse_date dob in
  let* (ry, rm, rd) = parse_date as_of in
  let diff = days_between (dy, dm, dd) (ry, rm, rd) in
  if diff < 0 then None
  else Some (compute_months dy dm dd ry rm rd, diff)

(* For Result *)
let ( let* ) = Result.bind

let process input =
  let* date = parse_date input in
  let* age = validate_age date in
  Ok (format age)
```

### Labeled Arguments

Labeled arguments make function signatures self-documenting and allow flexible argument ordering:

```ocaml
let replace ~needle ~replacement haystack =
  (* ... *)

(* Callers can provide arguments in any order *)
replace ~needle:"old" ~replacement:"new" text
replace text ~replacement:"new" ~needle:"old"
```

**Label punning** drops the label when the variable name matches:

```ocaml
let needle = "old" in
let replacement = "new" in
replace ~needle ~replacement text
```

Use labeled arguments when:
- A function takes multiple arguments of the same type (e.g., two strings).
- Argument meaning is not obvious from position.
- You want to enable partial application in flexible orders.

### Optional Arguments

Optional arguments use `?` and default to `None` unless a default is specified:

```ocaml
let format_age ?(compactness = Normal) locale dob =
  (* compactness defaults to Normal *)
  ...

(* Caller can omit it *)
format_age locale dob

(* Or provide it *)
format_age ~compactness:Short locale dob
```

**Forwarding optional arguments** preserves the optionality:

```ocaml
let wrapper ?compactness locale dob =
  format_age ?compactness locale dob
```

**Place optional arguments before mandatory ones.** An optional argument followed by a non-labeled mandatory argument is erased when the mandatory argument is applied. An optional argument at the end of the parameter list is never erased.

### Unit Patterns

Use `()` to match the unit value explicitly, signaling that the function is called for its side effects:

```ocaml
let initialize () =
  setup_logging ();
  load_config ()
```

### Printf-Style Formatting

Use `Printf.sprintf` for formatted string construction:

```ocaml
let show_date y m d =
  Printf.sprintf "%04d-%02d-%02d" y m d
```

### Lazy Evaluation

Use `lazy` for deferred computation that should execute at most once:

```ocaml
let expensive = lazy (compute_heavy_thing ())
let result = Lazy.force expensive  (* computed once, cached *)
```

---

## 10. Things to Avoid

### Obj.magic

`Obj.magic` bypasses the type system entirely. Never use it in application code. It is reserved for the compiler and runtime internals.

### Exceptions for Control Flow

Do not use exceptions as a general-purpose control flow mechanism. They are for genuinely exceptional situations:

```ocaml
(* Bad: exception as early return *)
exception Found of int
let find_first_positive l =
  try List.iter (fun x -> if x > 0 then raise (Found x)) l; None
  with Found x -> Some x

(* Good: use Option *)
let find_first_positive = List.find_opt (fun x -> x > 0)
```

### Stringly-Typed Code

Do not use strings where a variant or other structured type is appropriate:

```ocaml
(* Bad: stringly-typed *)
let format tier =
  if tier = "day" then format_days ()
  else if tier = "week" then format_weeks ()
  else failwith "unknown tier"

(* Good: variant type *)
type tier = Day | Week | Month | Year

let format = function
  | Day -> format_days ()
  | Week -> format_weeks ()
  | Month -> format_months ()
  | Year -> format_years ()
```

### Excessive Open

Opening many modules pollutes the namespace and makes it unclear where identifiers come from. Prefer qualified access (`Module.function`) or local opens.

### List.hd and List.tl

These functions raise exceptions on empty lists. Always pattern-match lists instead:

```ocaml
(* Bad *)
let first = List.hd my_list

(* Good *)
let first = match my_list with
  | x :: _ -> Some x
  | [] -> None
```

### Catch-All Patterns

Avoid `| _ -> ...` in match expressions when specific constructor patterns would provide better safety. Catch-all patterns suppress exhaustiveness warnings when new constructors are added.

### Non-Exhaustive Patterns

Never ignore the compiler's exhaustiveness warnings. Complete every match expression with all constructors listed explicitly, or document why a catch-all is semantically correct.

### Unnecessary Imperative Style

Do not rewrite natural functional patterns in imperative style:

```ocaml
(* Bad: imperative list length *)
let list_length l =
  let l = ref l in
  let res = ref 0 in
  while !l <> [] do
    incr res;
    l := List.tl !l
  done;
  !res

(* Good: functional *)
let rec list_length = function
  | [] -> 0
  | _ :: l -> 1 + list_length l
```

### Ignoring Compiler Warnings

Treat all compiler warnings seriously. They catch incomplete patterns, unused variables, deprecated features, and potential bugs. Compile with `-w +a` or at least `-w @1..70` in production code.

### Mutable Where Immutable Suffices

Do not reach for `ref` or mutable fields when a `let` binding or functional update achieves the same result with less complexity.

---

## 11. Tooling

### ocamlformat

Automated code formatter. Pin the version in `.ocamlformat`:

```
profile = default
version = 0.28.1
```

Run with `dune fmt` or `ocamlformat --inplace file.ml`. Integrate into CI to enforce consistent formatting.

### Dune

The standard OCaml build system. Project structure:

```
dune-project          # Project-level settings (lang dune 3.x, opam generation)
lib/
  dune                # (library (name my_lib) (libraries ...))
  types.ml
  formatter.ml
  formatter.mli
test/
  dune                # (test (name test_main) (libraries my_lib alcotest))
  test_main.ml
```

Key `dune` stanzas:

```lisp
; Library
(library
 (name sayable_age)
 (public_name sayable-age)
 (libraries unix))

; Executable
(executable
 (name main)
 (libraries sayable_age))

; Test
(test
 (name test_formatter)
 (libraries sayable_age alcotest))
```

Use `dune build` to compile, `dune test` to run tests, `dune clean` to remove build artifacts.

### OCaml LSP / Merlin

OCaml LSP (`ocaml-lsp-server`) provides IDE integration: type-on-hover, go-to-definition, completion, error reporting. It uses Merlin under the hood.

Install via opam:

```bash
opam install ocaml-lsp-server
```

Merlin configuration is automatically derived from the dune build system -- no manual `.merlin` files needed when using dune.

### opam

OCaml's package manager. Key operations:

```bash
opam switch create . 5.2.0    # Create a local switch with OCaml 5.2.0
opam install alcotest          # Install a test framework
opam pin add . --no-action     # Pin local package for development
```

Use `.opam` files for package metadata:

```
opam-version: "2.0"
name: "sayable-age"
version: "0.5.0"
depends: [
  "ocaml" {>= "4.14"}
  "dune" {>= "3.0" & build}
  "alcotest" {with-test}
]
```

### ppx (Preprocessing Extensions)

PPX provides compile-time code generation via syntax extensions:

| ppx | Purpose |
|---|---|
| `ppx_deriving` | Derive `show`, `eq`, `ord`, `make` from type definitions |
| `ppx_sexp_conv` | Derive s-expression serialization (Jane Street) |
| `ppx_inline_test` | Inline test definitions |
| `ppx_expect` | Expect-test framework |
| `ppx_let` | Monadic let syntax (`let%bind`, `let%map`) |

Use ppx judiciously. Each ppx adds a compilation dependency and can make error messages harder to understand.

### odoc

OCaml's documentation generator. Write documentation in `.mli` files using `(** ... *)` comments:

```ocaml
(** [format_age locale compactness dob as_of] formats a human-readable
    age string from a date of birth.

    @param locale The locale configuration for formatting.
    @param compactness The level of output detail.
    @param dob Date of birth as an ISO 8601 string (YYYY-MM-DD).
    @param as_of Reference date as an ISO 8601 string, or [None] for today.
    @return [Some formatted_age] on success, [None] on invalid input. *)
val format_age : locale -> compactness -> string -> string option -> string option
```

Generate docs with `dune build @doc`.

### Testing Frameworks

| Framework | Style |
|---|---|
| Alcotest | Structured test suites with colored output |
| OUnit2 | xUnit-style test framework |
| ppx_inline_test | Inline tests next to code |
| ppx_expect | Expect tests (snapshot testing) |

For zero-dependency projects, the stdlib `assert` and manual test runners work well.

---

## Quick Reference Checklist

For auditing an OCaml implementation, verify:

- [ ] Names use `snake_case` for values/types, `UpperCamelCase` for modules/constructors
- [ ] Primary type is named `t` in its module
- [ ] `.mli` files exist for public module interfaces
- [ ] No unnecessary `open` at file scope (qualified access preferred)
- [ ] Pattern matches are exhaustive -- no suppressed warnings
- [ ] No catch-all `_` where explicit constructors would be safer
- [ ] `option` or `result` used at API boundaries (not bare exceptions)
- [ ] Exception-raising functions suffixed with `_exn`
- [ ] No `Obj.magic` usage
- [ ] No `List.hd` or `List.tl` (pattern match instead)
- [ ] Mutable state used only when genuinely needed
- [ ] `while` loops justified (recursive functions preferred)
- [ ] Compiler warnings treated as errors (`-w +a` or equivalent)
- [ ] `ocamlformat` version pinned and formatting consistent
- [ ] Dune build files present and correctly structured
- [ ] Documentation comments in `.mli` files using `(** ... *)` syntax
- [ ] Zero runtime dependencies (no external opam packages in production)
- [ ] Labeled arguments used for functions with multiple same-type parameters
- [ ] Optional arguments placed before mandatory ones
- [ ] `Fun.protect` or equivalent used for resource cleanup
