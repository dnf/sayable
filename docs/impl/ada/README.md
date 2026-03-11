# Ada Style Guide

A practical reference for auditing Ada code quality in this project. Based on the
Ada Quality and Style Guide, the GNAT Coding Style guide, and community
conventions.

---

## Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Code Formatting](#2-code-formatting)
3. [Type System Best Practices](#3-type-system-best-practices)
4. [Package Design](#4-package-design)
5. [Error Handling](#5-error-handling)
6. [Concurrency](#6-concurrency)
7. [Memory Management](#7-memory-management)
8. [Common Idioms and Patterns](#8-common-idioms-and-patterns)
9. [Things to Avoid](#9-things-to-avoid)
10. [Tooling](#10-tooling)

---

## 1. Naming Conventions

Ada is case-insensitive but conventions matter for readability. All identifiers
use `Mixed_Case_With_Underscores`. Underscores separate words; no camelCase, no
ALL_CAPS (except short acronyms in identifiers like `ALI_File`).

### 1.1 Packages

Use noun phrases that describe the abstraction at a higher level than the
subprograms inside:

```ada
package Packet_Telemetry is ...
package Text_Utilities is ...
package Sayableage_Types is ...
```

Prefix abstract packages with `Abstract_`. Suffix mixin packages with `_Mixin`.

### 1.2 Types and Subtypes

Use singular, general nouns. A type name should describe one of its values. Do
not suffix with `_Type` -- that adds no information:

```ada
--  Good
type Day_Of_Month is range 1 .. 31;
type Plural_Category is (Zero, One, Two, Few, Many, Other);
type Compactness is (Normal, Short, Compact);

--  Bad
type Day_Of_Month_Type is range 1 .. 31;  --  redundant suffix
type Days is range 1 .. 31;               --  plural for a scalar
```

For visible subtypes that refine a base type, consider descriptive suffixes like
`_Range`, `_Capacity`, or `_Map`:

```ada
subtype Column_Range is Positive range 1 .. 132;
```

### 1.3 Variables and Objects

Use singular, specific nouns that describe the object's value during execution:

```ada
Today         : Date;
Retirement_Date : Date;
Input_Line    : Buffer;
```

For boolean objects, use predicate clauses or adjectives:

```ada
User_Is_Available : Boolean;
List_Is_Empty     : Boolean;
Valid             : Boolean;
```

Record components use singular, general nouns -- the enclosing record name
provides context:

```ada
type Parse_Result is record
   Year  : Integer := 0;
   Month : Integer := 0;
   Day   : Integer := 0;
   OK    : Boolean := False;
end record;
--  Accessed as: Result.Year, Result.OK
```

### 1.4 Constants and Named Numbers

Use named constants instead of magic literals. Show relationships between
related constants using static expressions:

```ada
Max_Age_Months : constant := 6000;
Bytes_Per_Page : constant := 4096;
Buffer_Size    : constant := Pages_Per_Buffer * Bytes_Per_Page;
```

### 1.5 Subprograms

**Procedures and entries**: use action verbs.

```ada
procedure Get_Next_Token (Source : in out Lexer);
procedure Parse_Date (S : String; Result : out Parse_Result);
```

**Boolean functions**: use predicate clauses (prefer `Is_` prefix).

```ada
function Is_Leap_Year (Year : Integer) return Boolean;
function Is_Empty (Container : List) return Boolean;
function Has_Short (Loc : Locale) return Boolean;
```

**Non-boolean functions**: use nouns describing the return value.

```ada
function Days_In_Month (Year : Integer; Month : Integer) return Integer;
function Julian_Day (Year, Month, Day : Integer) return Integer;
function Length (S : String) return Integer;
```

### 1.6 Parameters

Parameter names should be descriptive enough to understand without reading the
body. Formal parameter names appear in client documentation (the spec), so
invest in clarity:

```ada
function Format_Age
  (Loc   : Locale;
   Comp  : Compactness;
   DOB   : String;
   As_Of : String) return String;
```

### 1.7 Exceptions

Name exceptions after the problem they represent:

```ada
Invalid_Name    : exception;
Stack_Overflow  : exception;
Parse_Error     : exception;
Storage_Error   : exception;  --  predefined
```

### 1.8 Identifiers to Avoid

Per the GNAT Coding Style guide:

- Do not use `I` as a loop variable (too easily confused with `1`). Use `J` or
  a descriptive name.
- Do not use `O` as a variable name (confused with `0`).
- Do not declare local entities that shadow global ones.

---

## 2. Code Formatting

### 2.1 Indentation

- **3 spaces** per nesting level for control structures (`if`, `loop`, `case`,
  `begin`/`end`).
- **2 spaces** for continuation lines (a line that continues a statement or
  declaration from the previous line).
- **Spaces only** -- never use tab characters.

The distinction between 3 (nesting) and 2 (continuation) is important: it
visually separates control flow from wrapped expressions.

```ada
--  3-space nesting
if Diff_Days < 0 then
   return "";                          --  3 spaces in
end if;

--  2-space continuation
N_Str := To_Unbounded_String
  (Replace_First (Half, "{n}", Base_N));   --  2 spaces for continuation
```

### 2.2 Line Length

Lines must not exceed **79 characters** (not counting the line separator).
Lines must not have trailing blanks.

### 2.3 Spacing Around Operators

Every binary operator must be surrounded by spaces:

```ada
--  Good
Diff_Days := Julian_Day (Ref_P.Year, Ref_P.Month, Ref_P.Day)
  - Julian_Day (DOB_P.Year, DOB_P.Month, DOB_P.Day);

Months := (Ref_P.Year - DOB_P.Year) * 12
  + (Ref_P.Month - DOB_P.Month);

--  Bad
Months:=(Ref_P.Year-DOB_P.Year)*12;
```

Exception: the exponentiation operator (`**`) may omit surrounding spaces when
it improves readability (e.g., `2**16`).

### 2.4 Colon Alignment

In declarations, colons must be surrounded by spaces. Within a group of related
declarations, align the colons:

```ada
DOB_P, Ref_P : Parse_Result;
Diff_Days    : Integer;
Months       : Integer;
Last_Day     : Integer;
```

### 2.5 Reserved Words

All reserved words must be lowercase:

```ada
if, then, else, elsif, end, loop, for, while, return,
procedure, function, package, is, begin, with, use, type,
subtype, record, null, and, or, not, in, out, access, ...
```

Exception: `Access`, `Delta`, and `Digits` are capitalized when used as
attribute designators.

### 2.6 Comments

A comment starts with `--` followed by **two spaces**:

```ada
--  This is a correct comment
--  Every sentence starts with upper case

-- Wrong: only one space after --
```

One space after `--` is acceptable only for end-of-line comments after code:

```ada
Months := Months - 1;  -- adjust for partial month
```

Additional comment rules:

- Every sentence starts with an upper-case letter.
- Short single-line comments are not ended with a period.
- Multi-line comments use normal punctuation.
- Do not put two spaces after periods in comments.
- Mark dubious or incomplete comments with `???`.
- Comments on bodies should emphasize *why*, not *what* -- the spec documents
  the what.

### 2.7 Blank Lines

- An `if` block is preceded and followed by a blank line, except at the start
  or end of a `sequence_of_statements`.
- Use blank lines to separate logical groups of statements.
- Do not use multiple consecutive blank lines.

### 2.8 One Statement Per Line

One statement or label per line. Do not put statements on the same line as
`then`, `else`, or `loop`:

```ada
--  Good
if Diff_Days = 0 then
   return To_String (JB_Str);
end if;

--  Bad
if Diff_Days = 0 then return To_String (JB_Str); end if;
```

### 2.9 Context Clauses

List each `with` and `use` clause on its own line for easier maintenance and
clearer dependency tracking:

```ada
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;
```

### 2.10 Subprogram Layout

When a subprogram declaration fits on one line, keep it on one line:

```ada
function Is_Leap_Year (Year : Integer) return Boolean;
```

When it does not fit, place one parameter per line with colons aligned. Indent
the parameter list by 2 spaces from the subprogram keyword:

```ada
procedure Set_Heading
  (Source : String;
   Count  : Natural;
   Pad    : Character := Space;
   Fill   : Boolean   := True);
```

For functions, the `return` keyword can go on the same line as the last
parameter or on a new line aligned with the parameters:

```ada
function Head
  (Source : String;
   Count  : Natural;
   Pad    : Character := Space)
   return String;
```

### 2.11 If Statement Layout

Align `elsif`, `else`, and `end if` with the opening `if`. When a condition is
too long, split *before* `and` or `or` and indent the continuation:

```ada
if DOB'Length = 0 then
   return "";
elsif Comp = Short
  and then Loc.Has_Short
then
   Ovr := Loc.Short_Override;
end if;
```

Use short-circuit forms (`and then`, `or else`) except when both operands are
simple boolean variables or constants.

### 2.12 Case Statement Layout

```ada
case Comp is
   when Normal =>
      null;
   when Short =>
      Apply_Short_Override;
   when Compact =>
      Apply_Compact_Override;
end case;
```

### 2.13 Loop Statement Layout

Keep `for`/`while` and `loop` on the same line when possible:

```ada
for I in 0 .. 3 loop
   if not Is_Digit (S (S'First + I)) then
      return R;
   end if;
end loop;
```

When the condition is long, split it and align `loop` with `while`/`for`:

```ada
while Long_Condition
  and then Another_Condition
loop
   Process;
end loop;
```

### 2.14 Numeric Literals

Use underscores for readability in large numeric literals:

```ada
Max_Age_Months : constant := 6_000;
Buffer_Size    : constant := 16#8000_0000#;
Pi             : constant := 3.14159_26535_89793;
```

### 2.15 Subprogram Body Headers

Each subprogram body should be preceded by a box comment:

```ada
-------------------
-- Is_Leap_Year --
-------------------

function Is_Leap_Year (Year : Integer) return Boolean is
begin
   ...
end Is_Leap_Year;
```

Sort subprogram bodies alphabetically within a package body.

---

## 3. Type System Best Practices

Ada's type system is one of its greatest strengths. Use it aggressively.

### 3.1 Prefer Strong Typing

Create distinct types rather than reusing `Integer` or `String` everywhere.
Distinct types catch category errors at compile time with no runtime cost:

```ada
type Meters is new Float;
type Seconds is new Float;

--  Compiler error: cannot mix Meters and Seconds
Distance : Meters  := 100.0;
Duration : Seconds := 9.58;
Speed    : Float   := Float (Distance) / Float (Duration);  --  explicit
```

### 3.2 Use Subtypes for Constraints

Define the base type with the largest useful range. Use subtypes to constrain:

```ada
type Month_Number is range 0 .. 13;  --  sentinel-friendly
subtype Valid_Month is Month_Number range 1 .. 12;
```

Subtypes are assignment-compatible with their base type (no conversion needed)
but still get range checks at runtime:

```ada
M : Valid_Month := 13;  --  raises Constraint_Error at runtime
```

### 3.3 Derived Types for Domain Modeling

Derived types create new, incompatible types that inherit operations:

```ada
type Telephone_Directory is new Table;
type Department_Inventory is new Table;
--  Cannot accidentally pass a directory where inventory is expected
```

### 3.4 Enumeration Types

Use enumeration types instead of integer codes or string constants:

```ada
type Plural_Category is (Zero, One, Two, Few, Many, Other);
type Compactness is (Normal, Short, Compact);
```

Enumeration types are iterable, comparable, and have attributes like `'Image`
and `'Value` for string conversion.

### 3.5 Record Types

Use records to group related data. Initialize all components with defaults:

```ada
type Unit_Forms is record
   Has_Simple : Boolean := False;
   Simple     : Unbounded_String := Null_Unbounded_String;
   Has_Form   : Plural_Flags := (others => False);
   Forms      : Plural_Strings := (others => Null_Unbounded_String);
end record;
```

### 3.6 Array Types

Always name your array types. Anonymous array types prevent passing arrays as
subprogram parameters and complicate refactoring:

```ada
--  Good: named array type
type Plural_Flags is array (Plural_Category) of Boolean;
type Plural_Strings is array (Plural_Category) of Unbounded_String;

--  Bad: anonymous array type
Has_Form : array (Plural_Category) of Boolean;  --  cannot pass to subprograms
```

Use enumeration types or named ranges as index types rather than plain
`Integer`.

### 3.7 Private Types

When designing a public API, prefer private types. The hierarchy of preference:

1. **Limited private** -- most restrictive; no assignment or equality
2. **Private** -- assignment and equality are available; implementation hidden
3. **Nonprivate** -- implementation exposed

Export only the operations clients need. Restricting the type pushes errors to
compile time:

```ada
package Stack is
   type Instance is private;
   procedure Push (S : in out Instance; Item : Integer);
   function Pop (S : in out Instance) return Integer;
   function Is_Empty (S : Instance) return Boolean;
private
   type Instance is record
      Data : ...;
      Top  : Natural := 0;
   end record;
end Stack;
```

### 3.8 Access Type Discipline

Prefer `not null` access subtypes when a null value is never valid:

```ada
type Plural_Fn is not null access function (N : Natural) return Plural_Category;
```

This catches null dereferences at the point of assignment rather than at the
point of use.

---

## 4. Package Design

### 4.1 Spec vs. Body

The package **specification** (`.ads`) is the contract with clients. The
package **body** (`.adb`) is the implementation. Design the spec first -- it is
documentation:

- Put only what clients need in the visible part of the spec.
- Put helper types and internal constants in the private part.
- Put all subprogram bodies, internal variables, and helper subprograms in the
  body.

```ada
--  sayableage.ads (spec)
package Sayableage is
   Version : constant String := "0.5.0";
   function Format_Age (...) return String;
end Sayableage;

--  sayableage.adb (body)
package body Sayableage is
   --  Internal helpers: Parse_Date, Julian_Day, etc.
   function Format_Age (...) return String is
   begin
      ...
   end Format_Age;
end Sayableage;
```

### 4.2 Information Hiding

Objects that must persist between calls should be declared in the package body,
not the spec. Objects in the spec can be modified by any unit with visibility:

```ada
--  Bad: mutable state in spec
package Counters is
   Count : Integer := 0;
end Counters;

--  Good: hidden state with accessor
package Counters is
   function Get return Integer;
   procedure Increment;
end Counters;
```

### 4.3 Child Packages

Use child packages to decompose large subsystems without exposing internals.
The private part of a child spec and the child body can see the parent's
private part:

```ada
--  Parent
package Sayableage_Locales is
   type Locale_Code is (En, Fr, De, ...);
end Sayableage_Locales;

--  Child
package Sayableage_Locales.En is
   function Get return Locale;
end Sayableage_Locales.En;
```

Use **private child packages** for internal implementation details that should
not be visible outside the subsystem.

### 4.4 Minimize Context Clauses

Minimize `with` clauses on specifications. Move clauses to the body when
possible -- this reduces recompilation cascades and makes dependency graphs
clearer:

```ada
--  Spec: only what clients need
with Sayableage_Types; use Sayableage_Types;
package Sayableage is ...

--  Body: implementation dependencies
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;
package body Sayableage is ...
```

### 4.5 Use Clauses

Minimize `use` clauses. They obscure the origin of names and make maintenance
harder. Prefer qualified names or package renames:

```ada
--  Preferred: qualified names
Result := Ada.Strings.Fixed.Index (Tmpl, Marker);

--  Acceptable: renames for long package names
package ASF renames Ada.Strings.Fixed;
Result := ASF.Index (Tmpl, Marker);

--  Acceptable: use type for operators
use type Ada.Strings.Unbounded.Unbounded_String;

--  Use with caution: full use clauses
use Ada.Strings.Unbounded;  --  many names injected
```

When `use` clauses are necessary (e.g., for `Unbounded_String` operations that
appear frequently), localize them to the smallest scope possible -- the body
rather than the spec, or a block rather than the entire body.

---

## 5. Error Handling

### 5.1 Exceptions

Ada uses exceptions for error handling. The terminology is *raising* (not
throwing) and *handling* (not catching):

```ada
--  Declaring
Parse_Error : exception;

--  Raising
raise Parse_Error with "invalid date format";

--  Handling
begin
   Result := Parse_Date (Input);
exception
   when Parse_Error =>
      Put_Line ("Bad input");
   when others =>
      Put_Line ("Unexpected error");
      raise;  --  re-raise
end;
```

### 5.2 Exception Best Practices

- Name exceptions after the problem (`Invalid_Format`, not `Error_1`).
- Attach a message string with `raise X with "details"`.
- Handle exceptions at the level that can meaningfully respond. Do not catch
  exceptions just to log and re-raise at every level.
- Use `when others =>` sparingly and always re-raise unless you have a specific
  recovery strategy.
- Prefer returning a discriminated result (a record with a success flag) over
  raising exceptions for expected conditions like parse failures:

```ada
type Parse_Result is record
   Year  : Integer := 0;
   Month : Integer := 0;
   Day   : Integer := 0;
   OK    : Boolean := False;
end record;

function Parse_Date (S : String) return Parse_Result;
--  Returns a result with OK = False rather than raising
```

### 5.3 Preconditions and Postconditions (Ada 2012)

Use contract aspects to document and enforce subprogram requirements. These are
checked at runtime when compiled with `-gnata`:

```ada
function Square (A : Integer) return Integer
  with Pre  => A in -46340 .. 46340,
       Post => Square'Result = A * A;

procedure Push (S : in out Stack; Item : Integer)
  with Pre  => not Is_Full (S),
       Post => not Is_Empty (S) and then Top (S) = Item;
```

Key contract features:

- **`'Result`**: refers to the function return value in postconditions.
- **`'Old`**: refers to a parameter's value at subprogram entry.
- **Quantified expressions**: `for all I in A'Range => A(I) > 0`.
- **Assertion_Policy**: controls whether checks are enabled.

### 5.4 Subtype Predicates

Use predicates when range constraints are insufficient:

```ada
--  Static predicate: non-contiguous sets
subtype Work_Day is Day_Of_Week
  with Static_Predicate => Work_Day in Mon | Tue | Wed | Thu | Fri;

--  Dynamic predicate: complex invariants
type Date_Range is record
   Start_Date : Date;
   End_Date   : Date;
end record
  with Dynamic_Predicate => Date_Range.Start_Date <= Date_Range.End_Date;
```

### 5.5 Type Invariants

Use type invariants on private types to enforce consistency across all
operations. The invariant is checked on exit from any public operation that
modifies the type:

```ada
package Courses is
   type Course is private
     with Type_Invariant => Check (Course);
   function Check (C : Course) return Boolean;
private
   type Course is record
      Start_Date : Time;
      End_Date   : Time;
   end record;
   function Check (C : Course) return Boolean is
     (C.Start_Date <= C.End_Date);
end Courses;
```

---

## 6. Concurrency

Ada has first-class concurrency support. While the sayable-age library does not
use tasking (it is a pure computation library), these guidelines apply to Ada
code in general.

### 6.1 When to Use Tasks vs. Protected Objects

- **Tasks**: model independent threads of control. Use when you have genuinely
  concurrent activities.
- **Protected objects**: guard shared data. Use when your primary goal is mutual
  exclusion or synchronization, not independent computation.

### 6.2 Protected Objects

Protected objects provide mutual exclusion without explicit locking:

```ada
protected Counter is
   procedure Increment;
   function Get return Integer;
   entry Wait_Until_Nonzero (Value : out Integer);
private
   Count : Integer := 0;
end Counter;

protected body Counter is
   procedure Increment is
   begin
      Count := Count + 1;
   end Increment;

   function Get return Integer is
   begin
      return Count;
   end Get;

   entry Wait_Until_Nonzero (Value : out Integer)
     when Count > 0
   is
   begin
      Value := Count;
   end Wait_Until_Nonzero;
end Counter;
```

Guidelines:

- Keep protected operations short -- they block other callers.
- Entry barriers should depend only on the protected object's own state, not
  global variables.
- Encapsulate protected objects in the private part or body of a package.

### 6.3 Task Design

```ada
task type Worker is
   entry Start (ID : Positive);
end Worker;

task body Worker is
   My_ID : Positive;
begin
   accept Start (ID : Positive) do
      My_ID := ID;
   end Start;
   --  Do work after rendezvous
end Worker;
```

Guidelines:

- Provide a clean shutdown mechanism (the `terminate` alternative in a
  `select` or an explicit `Stop` entry).
- Use `delay until` instead of `delay` for periodic tasks to avoid accumulated
  drift.
- Do not access shared variables directly -- use protected objects.

---

## 7. Memory Management

### 7.1 Prefer Stack Allocation

Ada encourages value semantics and stack allocation. Use dynamic allocation only
when the lifetime or size of an object is truly dynamic:

```ada
--  Preferred: stack allocation
declare
   Buffer : String (1 .. 1024);
begin
   ...
end;

--  Dynamic: only when necessary
type String_Access is access String;
Ptr : String_Access := new String'("hello");
```

### 7.2 Access Types

Ada has two kinds of access types:

- **Pool-specific** (`access T`): can only point to heap-allocated objects.
- **General** (`access all T`): can also point to aliased stack objects.

Use pool-specific access types by default. Use `not null` access subtypes when
null is never valid:

```ada
type Node_Access is access Node;
type Node_Ref is not null access all Node;
```

### 7.3 Unchecked_Deallocation

Always explicitly deallocate when you are done with a dynamically allocated
object. This documents intent and prevents leaks:

```ada
with Ada.Unchecked_Deallocation;

procedure Free is new Ada.Unchecked_Deallocation
  (Object => Node, Name => Node_Access);

Ptr : Node_Access := new Node;
...
Free (Ptr);  --  sets Ptr to null
```

Dangers to avoid:

- **Dangling references**: deallocating while other pointers still reference
  the object.
- **Dropped pointers**: losing all references to an allocated object (memory
  leak).

### 7.4 Controlled Types (RAII)

Use controlled types from `Ada.Finalization` to tie resource management to
object lifetime. This is Ada's equivalent of RAII:

```ada
with Ada.Finalization;

package Managed_Resource is
   type Resource is new Ada.Finalization.Limited_Controlled with private;
private
   type Resource is new Ada.Finalization.Limited_Controlled with record
      Handle : Integer := -1;
   end record;

   overriding procedure Initialize (R : in out Resource);
   overriding procedure Finalize   (R : in out Resource);
end Managed_Resource;
```

- **`Initialize`**: called on object creation. Acquire resources here.
- **`Adjust`**: called after assignment (nonlimited only). Implement deep copy.
- **`Finalize`**: called on object destruction. Release resources here.

Use `Limited_Controlled` for resources that should not be copied (file handles,
locks, connections).

### 7.5 Storage_Error Handling

When using dynamic allocation, provide handlers for `Storage_Error`:

```ada
begin
   Ptr := new Large_Array;
exception
   when Storage_Error =>
      --  Handle out-of-memory gracefully
      raise;
end;
```

---

## 8. Common Idioms and Patterns

### 8.1 Aggregate Initialization

Always use aggregates to initialize records and arrays. Aggregates enforce full
coverage -- every component must be accounted for:

```ada
Empty_Unit : constant Unit_Forms :=
  (Has_Simple => False,
   Simple     => Null_Unbounded_String,
   Has_Form   => (others => False),
   Forms      => (others => Null_Unbounded_String));
```

### 8.2 Named Association in Aggregates

Prefer named association over positional for records and multi-element
aggregates. Named association is self-documenting and resilient to reordering:

```ada
--  Good: named
(Year => 2024, Month => 3, Day => 15, OK => True)

--  Fragile: positional
(2024, 3, 15, True)
```

### 8.3 Short-Circuit Evaluation

Use `and then` / `or else` instead of `and` / `or` for boolean expressions
where the right operand should not be evaluated if the left determines the
result:

```ada
if S'Length > 0 and then S (S'First) = '-' then ...
if Ptr /= null and then Ptr.Value > 0 then ...
```

Use plain `and`/`or` only when both operands are simple boolean variables or
constants with no side effects.

### 8.4 Qualified Expressions and Conversions

Use qualified expressions (`Type'(expr)`) to resolve ambiguity. Use type
conversions (`Type (expr)`) to convert between related types:

```ada
--  Qualified expression: disambiguates
Put (Character'('A'));

--  Type conversion: between numeric types
Float_Value := Float (Integer_Value);
```

### 8.5 Declare Blocks

Use declare blocks to limit the scope of temporary variables:

```ada
begin
   --  ... some code ...
   declare
      Temp : constant String := Compute_Something;
   begin
      Process (Temp);
   end;
   --  Temp is no longer visible here
end;
```

### 8.6 Expression Functions

For simple one-expression functions, use expression function syntax (Ada 2012):

```ada
function Is_Leap_Year (Year : Integer) return Boolean is
  (Year mod 4 = 0 and then (Year mod 100 /= 0 or else Year mod 400 = 0));
```

### 8.7 Renaming Declarations

Use renames to shorten verbose qualified names without introducing `use`:

```ada
package ASF renames Ada.Strings.Fixed;
Pos : constant Natural := ASF.Index (Source, Pattern);
```

### 8.8 String Handling

Ada strings are fixed-length. For variable-length strings, use
`Unbounded_String` from `Ada.Strings.Unbounded`:

```ada
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

Name : Unbounded_String := To_Unbounded_String ("hello");
Len  : Natural := Length (Name);
Raw  : String  := To_String (Name);
```

For string manipulation (trimming, searching, replacing), use
`Ada.Strings.Fixed`:

```ada
with Ada.Strings.Fixed;

Pos : Natural := Ada.Strings.Fixed.Index (Source, "target");
Trimmed : String := Ada.Strings.Fixed.Trim (Raw, Ada.Strings.Left);
```

### 8.9 Sentinel Values with Subtypes

Define a broader base type and use subtypes to carve out the valid range. The
broader type allows sentinel or boundary values in algorithms:

```ada
type Columns is range 0 .. Listing_Width + 1;
subtype Valid_Column is Columns range 1 .. Listing_Width;
--  0 and Listing_Width + 1 can serve as sentinels
```

### 8.10 Access-to-Subprogram Types

Use access-to-subprogram types for callbacks and strategy patterns:

```ada
type Plural_Fn is access function (N : Natural) return Plural_Category;

type Locale is record
   Plural : Plural_Fn := null;
   ...
end record;
```

---

## 9. Things to Avoid

### 9.1 Programming Ada Like Another Language

The most common anti-pattern. Programmers from C, Java, or Python often write
Ada as if it were their familiar language with different syntax. This subverts
Ada's strengths. Specific mistakes:

- Using `Integer` everywhere instead of domain-specific types.
- Ignoring the type system and relying on runtime checks.
- Using pointers (access types) when value semantics suffice.
- Writing `if X = True then` instead of `if X then`.

### 9.2 Overuse of Use Clauses

Indiscriminate `use` clauses obscure where names come from and can introduce
ambiguity as packages evolve. Use qualified names or renames instead.

### 9.3 Anonymous Types

Avoid anonymous array types in declarations. They cannot be used as parameter
types and block refactoring:

```ada
--  Bad
Buffer : array (1 .. 80) of Character;

--  Good
type Buffer_Type is array (1 .. 80) of Character;
Buffer : Buffer_Type;
```

### 9.4 Overuse of Unchecked Operations

`Unchecked_Deallocation`, `Unchecked_Conversion`, and `Unchecked_Access` bypass
Ada's safety guarantees. Use them only when necessary, document why, and
isolate them in the smallest possible scope:

```ada
--  Document the justification
pragma Warnings (Off, "possible aliasing problem");
--  ... unchecked operation ...
pragma Warnings (On, "possible aliasing problem");
```

### 9.5 Subunits

Avoid subunits (`separate`). With child packages available since Ada 95, there
is almost never a reason to use subunits. They create maintenance problems and
confuse dependency tracking.

### 9.6 Global Mutable State

Avoid mutable variables in package specifications. They can be modified by any
unit with visibility and cannot be protected or abstracted:

```ada
--  Bad: visible mutable state
package Global is
   Counter : Integer := 0;
end Global;

--  Good: encapsulated state
package Global is
   function Get_Counter return Integer;
   procedure Increment;
end Global;
```

### 9.7 Magic Numbers

Never use unexplained numeric literals in code. Use named constants:

```ada
--  Bad
if Months_Val < 156 then ...

--  Good
Months_Per_13_Years : constant := 156;
if Months_Val < Months_Per_13_Years then ...
```

### 9.8 Catching and Swallowing Exceptions

Do not catch exceptions without either handling them meaningfully or
re-raising:

```ada
--  Bad
begin
   Risky_Operation;
exception
   when others => null;  --  silently swallowed
end;
```

### 9.9 Multiple Variables Per Declaration

Do not declare multiple variables in a single declaration that spans multiple
lines. One declaration per line:

```ada
--  Good
Part1 : Unbounded_String;
Part2 : Unbounded_String;

--  Acceptable (same line)
DOB_P, Ref_P : Parse_Result;

--  Bad (multi-line multi-variable)
Part1,
Part2 : Unbounded_String;
```

### 9.10 Ignoring Compiler Warnings

Ada compilers produce highly specific warnings. Treat all warnings as errors
in CI (`-gnatwe`). When suppressing a warning, document the reason.

---

## 10. Tooling

### 10.1 GNAT Compiler Flags

#### Warning Flags

| Flag | Meaning |
|------|---------|
| `-gnatwa` | Enable all common warnings |
| `-gnatwe` | Treat warnings as errors |
| `-gnatwj` | Warn on obsolescent features |
| `-gnatw.o` | Warn on missing overriding indicators |

#### Style Checking Flags (`-gnaty`)

The `-gnaty` flag enables style checking. Use `-gnatyy` (or just `-gnaty`) for
the standard set. Individual flags:

| Flag | Check |
|------|-------|
| `a` | Attribute casing (mixed case required) |
| `b` | No trailing blanks |
| `c` | Comments: two spaces after `--` |
| `C` | Comments: one space after `--` (alternative to `c`) |
| `d` | No DOS line terminators |
| `D` | Identifiers in mixed case |
| `e` | End/exit labels required |
| `f` | No form feeds or vertical tabs |
| `h` | No horizontal tabs |
| `i` | If-then layout checked |
| `I` | Explicit `in` mode keyword not allowed |
| `k` | Keywords lowercase |
| `l` | Layout follows ARM recommendations |
| `m` | Maximum line length 79 characters |
| `M`*nnn* | Set maximum line length to *nnn* |
| `n` | Casing of Standard entities checked |
| `N` | Turn off all checks |
| `o` | Subprogram bodies alphabetically ordered |
| `O` | Overriding indicators required |
| `p` | Pragma names in mixed case |
| `r` | References match declaration casing |
| `s` | Separate specs required for subprograms |
| `S` | No statements after then/else on same line |
| `t` | Token spacing checked |
| `u` | No unnecessary blank lines |
| `x` | No extra parentheses (C-style `if (x)` flagged) |
| `y` | Enable all standard checks (= `-gnatyy`) |
| `z` | Extra parentheses for operator precedence flagged |
| `0`-`9` | Set indentation level (3 is default for `-gnatyy`) |

The default `-gnatyy` enables everything except `B`, `d`, `I`, `L`, `o`, `O`,
`S`, `u`, and `x`.

#### Contract Checking

| Flag | Meaning |
|------|---------|
| `-gnata` | Enable assertion/contract checking at runtime |

### 10.2 GNATformat

GNATformat is AdaCore's code formatter for Ada. It applies the GNAT Coding
Style automatically. Use it to enforce consistent formatting across a team.

### 10.3 GNATcheck

GNATcheck is a static analysis tool that checks compliance with coding
standards. It provides over 100 rules covering:

- Style conventions (casing, indentation)
- Feature restriction (goto, floating-point equality)
- Complexity metrics (nesting depth, cyclomatic complexity)
- Runtime semantics (tasking, dynamic memory)

### 10.4 GNATprove (SPARK)

For safety-critical code, GNATprove performs formal verification of SPARK
subsets of Ada. It can prove absence of runtime errors and verify functional
contracts.

### 10.5 Recommended Compiler Invocation

For development:

```bash
gnatmake -gnatwa -gnatyy -gnata program.adb
```

For CI (warnings as errors):

```bash
gnatmake -gnatwa -gnatwe -gnatyy -gnata program.adb
```

---

## References

- [Ada Quality and Style Guide](https://ada-lang.io/docs/style-guide/Ada_Style_Guide/) --
  Community-maintained style guide based on the Ada 95 Quality and Style manual,
  updated for Ada 2012.
- [GNAT Coding Style Guide](https://gcc.gnu.org/onlinedocs/gnat-style/) --
  Style conventions used for GNAT compiler development.
- [Ada Reference Manual](http://www.ada-auth.org/arm.html) -- The official
  language standard (ISO/IEC 8652).
- [Ada 95 Quality and Style: Guidelines for Professional Programmers](https://www.adaic.org/resources/add_content/docs/95style/95style.pdf)
  (PDF) -- The original comprehensive style guide.
- [learn.adacore.com](https://learn.adacore.com/) -- AdaCore's free learning
  platform with courses on Ada fundamentals, advanced topics, contracts, and
  concurrency.
- [Ada Style Guide (Wikibooks)](https://en.wikibooks.org/wiki/Ada_Style_Guide) --
  Community-maintained style guide on Wikibooks.
- [GNAT Style Checking Options](https://gcc.gnu.org/onlinedocs/gnat_ugn/Style-Checking.html)
  -- Complete reference for `-gnaty` sub-options in GNAT.
- [AdaCore Blog: Introduction to Contract-Based Programming](https://www.adacore.com/blog/the-case-for-contracts)
  -- Practical guide to using Ada 2012 contracts.
- [Ada Programming/Type System (Wikibooks)](https://en.wikibooks.org/wiki/Ada_Programming/Type_System)
  -- Community reference on Ada's type system.
