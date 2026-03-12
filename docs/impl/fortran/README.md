# Fortran Style Guide

A comprehensive reference for idiomatic modern Fortran coding style and best practices. Intended for code auditing Fortran implementations.

## Sources

This guide synthesizes conventions from the following authoritative references:

- [Fortran Best Practices (fortran-lang.org)](https://fortran-lang.org/learn/best_practices/) -- community-maintained best practices mini-book
- [Fortran Best Practices (fortran90.org)](https://www.fortran90.org/src/best-practices.html) -- original best practices guide by Ondrej Certik et al.
- [Modern Fortran Explained](https://global.oup.com/academic/product/modern-fortran-explained-9780198876571) (Metcalf, Reid, Cohen) -- the definitive Fortran language reference
- [ISO/IEC 1539-1:2023](https://www.iso.org/standard/82170.html) -- Fortran 2023 standard (informally "Fortran 2023")
- [GNU Fortran Manual](https://gcc.gnu.org/onlinedocs/gfortran/) -- gfortran compiler documentation
- [Fortran Wiki Style Guide](http://fortranwiki.org/fortran/show/Style+guide)
- [fpm (Fortran Package Manager)](https://fpm.fortran-lang.org/) -- modern Fortran build tool

---

## 1. Naming Conventions

### Case Rules

| Element | Convention | Example |
|---|---|---|
| Keywords and intrinsics | lowercase | `do`, `end if`, `integer`, `intent`, `implicit none` |
| Module names | lowercase, underscores | `sayableage_types`, `iso_fortran_env` |
| Derived type names | lowercase, underscores | `pt_locale`, `pt_unit_forms` |
| Subroutine/function names | lowercase, underscores | `format_age`, `parse_date`, `is_leap_year` |
| Variables | lowercase, underscores | `diff_days`, `month_count` |
| Kind/precision parameters | lowercase | `dp`, `sp`, `qp`, `i32`, `i64` |
| Domain constants and enumerators | UPPER_CASE with prefix | `PT_ZERO`, `PT_ONE`, `PT_MAX_STR_LEN` |

Fortran is case-insensitive, so `MyModule` and `mymodule` refer to the same entity. Use a single consistent casing throughout the codebase to avoid confusion.

### Naming Principles

- **Use lowercase for all Fortran constructs** (`do`, `subroutine`, `module`, `integer`, `real`, `character`, `end`). This is the dominant modern convention.
- **Short names are fine for mathematical variables** (`x`, `n`, `jd`, `a`, `y`, `m`) when their meaning is clear from context. Fortran's heritage in scientific computing makes this idiomatic.
- **Use underscores to separate words** for longer names: `days_in_month`, `parse_date`, `format_age`. Avoid camelCase.
- **Avoid ambiguous abbreviations.** `spline_interp` is fine; `splineint` is ambiguous (integer or interpolation?). When in doubt, spell it out.
- **Prefix related constants** with a common tag to create a namespace-like grouping: `PT_ZERO`, `PT_ONE`, `PT_OTHER` for plural categories.
- **Module names should be unique** across the program. Prefix with the library or project name to avoid collisions in dependent projects: `sayableage`, `sayableage_types`, `sayableage_locales`.

### Result Variables

The `result` clause gives the return value a name different from the function:

```fortran
pure function days_in_month(year, month) result(days)
  integer, intent(in) :: year, month
  integer :: days
  ! ...
end function days_in_month
```

Use `result` when it improves clarity -- for instance, when the function name is long, when the natural name for the return value differs from the function name, or when the function name reads awkwardly as a variable (e.g., `is_valid`). For short, well-named functions, using the function name as the result variable is equally valid.

---

## 2. Code Formatting

### Free-Form Source

**Always use free-form source** (the default for `.f90`, `.f95`, `.f03`, `.f08`, `.f18` extensions). Never write new code in fixed-form (`.f`, `.for`, `.ftn`). Fixed-form's 72-column limit, column-6 continuation markers, and column-1 comment markers are relics of punched cards.

### Indentation

- Use **2 spaces** per indentation level. This is the project convention. (The broader Fortran ecosystem varies between 2 and 4 spaces; consistency within a project matters more than the specific choice.)
- Indent the body of `module`, `subroutine`, `function`, `if`, `do`, `select case`, `type`, `interface`, and `associate` blocks.
- The `contains` keyword in a module sits at the same level as `implicit none`, not indented further.
- The body of `contains` (the procedures) is indented one level from the module.

```fortran
module example
  implicit none
  private

  integer, parameter, public :: MAX_LEN = 256

contains

  pure function double(n) result(res)
    integer, intent(in) :: n
    integer :: res
    res = n * 2
  end function double

end module example
```

### Line Length

- Keep lines to **132 characters or fewer** (the Fortran free-form standard limit). Many projects target 80 or 100 characters for readability.
- Use the ampersand (`&`) for continuation lines. Place the `&` at the end of the line to be continued. Optionally place a second `&` at the start of the continuation line (required inside character literals):

```fortran
result = very_long_variable_name &
       + another_long_variable_name &
       + final_term
```

When breaking a string literal across lines:

```fortran
message = "This is a very long &
          &string that continues here"
```

### Blank Lines

- One blank line between procedures within a `contains` block.
- One blank line after the `implicit none` / `private` / `public` declarations in a module.
- No blank line between a procedure signature and its declarations.

### End Statements

Always name the construct in `end` statements for readability:

```fortran
end module sayableage       ! not just "end module"
end function parse_date     ! not just "end function"
end subroutine process      ! not just "end subroutine"
end type pt_locale          ! not just "end type"
```

---

## 3. Modern Fortran Features

### Standard Level

Target **Fortran 2008** as the baseline standard. It is widely supported by all major compilers (gfortran, ifort/ifx, NAG, flang) and provides the essential modern features. Fortran 2018 and 2023 features can be used where compiler support is confirmed.

### Modules

Modules are the fundamental unit of code organization in modern Fortran. They provide:

- Namespace control via `public`/`private`
- Automatic explicit interfaces for all contained procedures
- Support for derived types, parameters, and abstract interfaces
- Compile-time argument checking (type, rank, intent)

Every procedure should live in a module. Free-standing `external` procedures lack interface checking and should be avoided.

### Derived Types

Use derived types to group related data:

```fortran
type :: pt_stage_label
  character(len=PT_MAX_STR_LEN) :: label = ''
  character(len=PT_MAX_STR_LEN) :: f_label = ''
end type pt_stage_label
```

Key practices:
- Provide default initialization for all components to avoid undefined state.
- Use `%` to access components: `stage%label`.
- Use type-bound procedures when operations are closely tied to the type.
- Use the `extends` keyword for type inheritance when polymorphism is needed.

### Intent Attributes

**Always specify `intent` for all dummy arguments.** This is both self-documenting and enables the compiler to catch errors:

```fortran
subroutine parse_date(s, year, month, day, ok)
  character(len=*), intent(in)  :: s       ! read-only
  integer,          intent(out) :: year     ! write-only (undefined on entry)
  integer,          intent(out) :: month
  integer,          intent(out) :: day
  logical,          intent(out) :: ok
```

| Intent | Meaning | Compiler guarantee |
|---|---|---|
| `intent(in)` | Read-only; must not be modified | Assignment to it is a compile error |
| `intent(out)` | Write-only; undefined on entry, must be defined before return | Compiler warns if not set |
| `intent(inout)` | Read-write; defined on entry, may be modified | No restrictions |

**Warning: `intent(out)` and derived types.** When a derived type argument has `intent(out)`, all components become undefined on entry -- including components with default initialization in the type definition. This means default values are not preserved. Either use `intent(inout)` when you need to preserve defaults, or explicitly set every component in the procedure:

```fortran
type :: config
  integer :: mode = 0
  logical :: verbose = .false.
end type config

! WRONG: c%verbose is UNDEFINED after this call, not .false.
subroutine partial_init(c)
  type(config), intent(out) :: c
  c%mode = 1
  ! c%verbose is undefined here -- the default .false. does not apply
end subroutine partial_init

! CORRECT: either set all components...
subroutine full_init(c)
  type(config), intent(out) :: c
  c%mode = 1
  c%verbose = .false.
end subroutine full_init

! ...or use intent(inout) to preserve defaults
subroutine update_mode(c)
  type(config), intent(inout) :: c
  c%mode = 1
end subroutine update_mode
```

### Pure and Elemental

- Mark functions and subroutines as **`pure`** when they have no side effects (no I/O, no modification of module variables, no stop/error stop). Pure procedures can be called in `do concurrent`, `forall`, and array-valued expressions.
- Mark procedures as **`elemental`** when they operate on scalar arguments but should also accept arrays. `elemental` implies `pure` -- all `pure` restrictions apply. The compiler automatically applies the procedure element-wise:

```fortran
real(dp) elemental function nroot(n, x) result(y)
  integer, intent(in) :: n
  real(dp), intent(in) :: x
  y = x**(1.0_dp / n)
end function nroot
```

Calling `nroot(2, array)` applies the function to every element of `array`.

Since Fortran 2008, **`impure elemental`** allows elemental procedures with side effects (e.g., I/O or modifying module state). Use it when you need element-wise application but cannot satisfy `pure` constraints. Note that `impure elemental` procedures cannot be used in `do concurrent` or `forall`.

### Allocatable Arrays

Prefer **allocatable arrays** over pointers for dynamic memory:

```fortran
integer, allocatable :: indices(:)
allocate(indices(n), source=0)
! ...
! No explicit deallocate needed: automatic on scope exit
```

Key practices:
- Use `allocate(..., source=value)` to initialize on allocation.
- Use `intent(out)` on allocatable dummy arguments for automatic deallocation on entry.
- Check `allocated(arr)` before accessing if the array might not be allocated.
- Use `move_alloc` for efficient ownership transfer without copying.
- Allocatables are automatically deallocated when they go out of scope -- no manual `deallocate` needed in most cases.

---

## 4. Module Design

### Module Template

```fortran
module sayableage
  use sayableage_types, only: pt_locale, pt_unit_forms, PT_MAX_STR_LEN, &
                               PT_OTHER, PT_SHORT, PT_COMPACT
  implicit none
  private

  character(len=*), parameter, public :: VERSION = "0.5.0"

  public :: format_age, format_stage

contains

  pure function is_leap_year(year) result(leap)
    integer, intent(in) :: year
    logical :: leap
    leap = (mod(year, 4) == 0 .and. &
            (mod(year, 100) /= 0 .or. mod(year, 400) == 0))
  end function is_leap_year

  ! ... more procedures ...

end module sayableage
```

### `implicit none`

**Always use `implicit none`** at the module level. It applies to all contained procedures -- there is no need to repeat it in each subroutine or function within the module.

For standalone programs, place `implicit none` immediately after the `program` statement.

Never rely on Fortran's default implicit typing rules (variables starting with I-N are integer, all others are real). This is the single most common source of bugs in legacy Fortran.

### `use` with `only`

**Prefer explicit imports** with the `only` clause:

```fortran
use sayableage_types, only: pt_locale, PT_MAX_STR_LEN
use iso_fortran_env, only: dp => real64
```

Bare `use module_name` (without `only`) imports everything from the module, which:
- Makes dependencies opaque (which symbols come from where?)
- Risks name collisions
- Prevents the reader from quickly understanding the module's interface

`only` is most important when importing from large or widely-shared modules. For small, tightly-coupled companion modules where the consumer uses most or all of the module's public interface (e.g., a types module dedicated to a single formatter module), a bare `use` is acceptable -- the coupling is inherent in the design, and maintaining a long `only` list adds noise without improving clarity.

Place `use` statements at the module level (before `implicit none`), not inside individual procedures, unless a procedure has a unique dependency not shared by the rest of the module.

### `private` / `public`

- Set the default visibility to **`private`** with a bare `private` statement.
- Explicitly list all public symbols with `public` statements.
- This forces you to be intentional about the module's public API and prevents accidental exposure of internal procedures.

```fortran
module example
  implicit none
  private

  public :: public_sub, public_type    ! explicitly exported
  public :: PUBLIC_CONSTANT

contains
  ! public_sub is accessible from outside
  ! helper_sub is private (module-internal only)
end module example
```

### Module Variables

Module-level variables are effectively global state. Restrict their use to:
- `parameter` constants
- `protected` variables (read-only from outside the module)
- Enumerator-like integer parameters

Avoid mutable module-level variables -- they create hidden coupling and make procedures harder to test and reason about.

### One Module Per File

Place each module in its own source file. Name the file to match the module: `sayableage_types.f90` for `module sayableage_types`. This makes navigation straightforward in any project.

---

## 5. Type System

### Kind Parameters

**Never use `real*8`, `integer*4`, or similar nonstandard syntax.** Use kind parameters:

```fortran
use iso_fortran_env, only: dp => real64, sp => real32, i32 => int32, i64 => int64

real(dp) :: x
integer(i64) :: big_count
```

Or define kind parameters centrally using `selected_real_kind` and `selected_int_kind`:

```fortran
module precision
  implicit none
  integer, parameter :: sp = selected_real_kind(6, 37)     ! ~float
  integer, parameter :: dp = selected_real_kind(15, 307)   ! ~double
  integer, parameter :: qp = selected_real_kind(33, 4931)  ! ~quad
end module precision
```

**Always suffix floating-point literals** with the kind parameter:

```fortran
real(dp) :: pi = 3.14159265358979323846_dp
real(dp) :: half = 0.5_dp
real(dp) :: big = 1.34e8_dp
```

Without the suffix, `3.14159265358979323846` is a default (single-precision) constant, silently losing precision when assigned to a `real(dp)` variable. The `d0` suffix (e.g., `1.0d0`) produces a double-precision literal and does not lose precision, but it is hardcoded to double precision. The `_dp` form is preferred because it is parametric: if you change what `dp` maps to, all literals follow automatically.

### Derived Types

Derived types are Fortran's equivalent of structs/records. Use them to group related data and attach behavior:

```fortran
type :: pt_unit_forms
  logical :: has_simple = .false.
  character(len=PT_MAX_STR_LEN) :: simple = ''
  logical :: has_form(6) = .false.
  character(len=PT_MAX_STR_LEN) :: forms(6) = ''
end type pt_unit_forms
```

#### Type-Bound Procedures

Attach procedures to types for object-oriented patterns:

```fortran
type :: counter
  integer :: value = 0
contains
  procedure :: increment
  procedure :: reset
end type counter

subroutine increment(self)
  class(counter), intent(inout) :: self
  self%value = self%value + 1
end subroutine increment
```

Use `class(counter)` (not `type(counter)`) for the passed-object dummy argument to enable polymorphism. Use `type(counter)` only when polymorphism is not needed.

#### Constructors

Fortran provides a default structure constructor using the type name:

```fortran
type(pt_stage_label) :: stage
stage = pt_stage_label(label='Newborn', f_label='Newborn')
```

For more complex initialization, define a module function that returns the type:

```fortran
function make_locale(code, plural_fn) result(loc)
  character(len=*), intent(in) :: code
  procedure(pt_plural_fn) :: plural_fn
  type(pt_locale) :: loc
  loc%code = code
  loc%plural => plural_fn
end function make_locale
```

### Abstract Interfaces

Use abstract interfaces to define callback signatures:

```fortran
abstract interface
  function pt_plural_fn(n) result(cat)
    integer, intent(in) :: n
    integer :: cat
  end function pt_plural_fn
end interface
```

Procedure pointers and dummy procedure arguments can then be declared with this interface:

```fortran
type :: pt_locale
  procedure(pt_plural_fn), pointer, nopass :: plural => null()
end type pt_locale
```

### Parameterized Derived Types (Caution)

Fortran 2003 introduced parameterized derived types (PDTs) with `kind` and `len` parameters. In theory they allow types whose layout depends on compile-time or runtime parameters:

```fortran
type :: fixed_string(max_len)
  integer, len :: max_len
  character(len=max_len) :: value = ''
  integer :: actual_len = 0
end type fixed_string

type(fixed_string(256)) :: name
```

**Avoid PDTs in production code.** Compiler support remains incomplete and unreliable across all major compilers as of 2026. gfortran has known internal compiler error (ICE) bugs with PDTs. Intel ifx has partial support with restrictions. Even NAG, which has the most complete implementation, has edge cases. Using PDTs risks compiler crashes and portability failures. Prefer allocatable components or explicit kind parameters as practical alternatives.

---

## 6. Error Handling

### `iostat` and `iomsg`

Always use `iostat` (and optionally `iomsg`) for I/O operations to handle errors gracefully instead of crashing:

```fortran
integer :: io_unit, stat
character(len=512) :: msg

open(newunit=io_unit, file="data.txt", status="old", action="read", &
     iostat=stat, iomsg=msg)
if (stat /= 0) then
  print *, "Error opening file: ", trim(msg)
  return
end if

read(io_unit, *, iostat=stat) value
if (stat /= 0) then
  close(io_unit)
  return
end if

close(io_unit)
```

### `stat` for Allocations

Check allocation status for operations that might fail:

```fortran
integer :: stat
character(len=256) :: errmsg

allocate(large_array(n), stat=stat, errmsg=errmsg)
if (stat /= 0) then
  print *, "Allocation failed: ", trim(errmsg)
  error stop 1
end if
```

### `error stop`

Use `error stop` (not `stop`) for abnormal termination. `error stop` sets a nonzero exit code and can include a message:

```fortran
if (n < 0) error stop "Negative array size"
if (stat /= 0) error stop 1
```

Plain `stop` is for normal program termination. `error stop` signals an error to the calling environment. Available since Fortran 2008.

### Return Codes via Arguments

For library code, avoid `stop` and `error stop` entirely. Report errors through output arguments and let the caller decide how to handle them:

```fortran
subroutine parse_date(s, year, month, day, ok)
  character(len=*), intent(in)  :: s
  integer,          intent(out) :: year, month, day
  logical,          intent(out) :: ok

  ok = .false.
  ! ... validate and parse ...
  ok = .true.
end subroutine parse_date
```

### `newunit` for File I/O

Always use `newunit=` in `open` statements instead of hardcoded unit numbers. Hardcoded units (e.g., `unit=10`) risk collisions in larger programs:

```fortran
integer :: io
open(newunit=io, file="output.txt", status="replace", action="write")
write(io, '(A)') "Hello"
close(io)
```

`newunit` is available since Fortran 2008.

---

## 7. String Handling

### Fixed-Length Character Variables

Fortran strings are fixed-length. They are padded with trailing blanks to fill the declared length:

```fortran
character(len=20) :: name
name = "Alice"   ! name is now "Alice               " (15 trailing blanks)
```

Use `trim()` to remove trailing blanks when concatenating or printing:

```fortran
print *, trim(name)                       ! prints "Alice"
full = trim(first_name) // " " // trim(last_name)
```

### String Comparison and Trailing Blanks

Fortran's `==` operator on character strings pads the shorter operand with blanks before comparing. This means:

```fortran
"Alice" == "Alice   "    ! .true. -- Fortran pads before comparing
"abc"   == "abc     "    ! .true.
```

This is the opposite of most other languages. `trim()` is unnecessary for equality comparisons alone (the padding makes them equivalent), but it is essential for concatenation, where trailing blanks produce unwanted whitespace.

### Assumed-Length Arguments

Use `character(len=*)` for dummy arguments that accept strings of any length:

```fortran
subroutine greet(name)
  character(len=*), intent(in) :: name
  print *, "Hello, ", trim(name)
end subroutine greet
```

### Key String Intrinsics

| Function | Purpose | Example |
|---|---|---|
| `trim(s)` | Remove trailing blanks | `trim("Alice   ")` -> `"Alice"` |
| `adjustl(s)` | Left-justify (move leading blanks to end) | `adjustl("  Bob")` -> `"Bob  "` |
| `adjustr(s)` | Right-justify (move trailing blanks to start) | `adjustr("Bob  ")` -> `"  Bob"` |
| `len(s)` | Declared length | `len(name)` -> `20` |
| `len_trim(s)` | Length excluding trailing blanks | `len_trim("Alice   ")` -> `5` |
| `index(s, sub)` | Position of first occurrence of `sub` | `index("hello", "ll")` -> `3` |
| `scan(s, set)` | Position of first character from `set` | `scan("hello", "aeiou")` -> `2` |
| `verify(s, set)` | Position of first character NOT in `set` | `verify("12x4", "0123456789")` -> `3` |
| `repeat(s, n)` | Repeat string `n` times | `repeat("-", 40)` -> forty dashes |
| `ichar(c)` | Character to integer code | `ichar('A')` -> `65` |
| `char(n)` | Integer code to character | `char(65)` -> `'A'` |

### String Concatenation

Use the `//` operator:

```fortran
result = trim(part1) // delimiter // trim(part2)
```

For building strings from integers, use internal writes:

```fortran
function int_to_str(n) result(s)
  integer, intent(in) :: n
  character(len=12) :: s
  write(s, '(I0)') n    ! I0 format: no leading blanks
end function int_to_str
```

### Substring Access

Use the colon notation for substrings:

```fortran
character(len=10) :: date_str
date_str = "2024-03-15"
year_part = date_str(1:4)    ! "2024"
month_part = date_str(6:7)   ! "03"
day_part = date_str(9:10)    ! "15"
```

---

## 8. Array Operations

### Assumed-Shape Arrays (Preferred)

Pass arrays using assumed-shape declarations (`:` for each dimension). The shape information is passed automatically:

```fortran
subroutine process(data)
  real(dp), intent(inout) :: data(:)
  integer :: i, n
  n = size(data)
  do i = 1, n
    data(i) = data(i) * 2.0_dp
  end do
end subroutine process
```

This provides:
- Automatic shape/size passing
- Compile-time rank checking
- Optional runtime bounds checking (with `-fcheck=bounds`)

### Whole-Array Operations

Fortran supports element-wise operations on entire arrays without explicit loops:

```fortran
real(dp) :: a(100), b(100), c(100)

c = a + b              ! element-wise addition
c = a * b              ! element-wise multiplication
c = sqrt(a)            ! element-wise square root
c = a + 1.0_dp         ! scalar broadcast

! Logical operations
logical :: mask(100)
mask = a > 0.0_dp      ! element-wise comparison
```

### `where` Construct

Apply operations conditionally across arrays:

```fortran
where (a > 0.0_dp)
  b = sqrt(a)
elsewhere
  b = 0.0_dp
end where
```

### Array Intrinsics

| Function | Purpose |
|---|---|
| `size(a)` | Total number of elements |
| `size(a, dim)` | Size along dimension `dim` |
| `shape(a)` | Array of dimension sizes |
| `lbound(a)`, `ubound(a)` | Lower/upper bounds |
| `sum(a)`, `product(a)` | Reduction operations |
| `maxval(a)`, `minval(a)` | Extrema |
| `maxloc(a)`, `minloc(a)` | Location of extrema |
| `any(mask)`, `all(mask)` | Logical reductions |
| `count(mask)` | Number of true elements |
| `pack(a, mask)` | Extract elements where mask is true |
| `merge(tsource, fsource, mask)` | Element-wise conditional |
| `matmul(a, b)` | Matrix multiplication |
| `dot_product(a, b)` | Dot product |
| `transpose(a)` | Matrix transpose |
| `reshape(source, shape)` | Reshape an array |

### Array Constructors

```fortran
integer :: fibonacci(8)
fibonacci = [1, 1, 2, 3, 5, 8, 13, 21]

! Implied do loop
real(dp) :: squares(10)
squares = [(real(i**2, dp), i = 1, 10)]
```

### Column-Major Order

Fortran stores multidimensional arrays in **column-major order**: the leftmost index varies fastest in memory. This is the opposite of C/C++ (row-major).

For optimal cache performance, iterate with the **innermost loop on the leftmost index**:

```fortran
! Fast: contiguous memory access
do j = 1, ncols
  do i = 1, nrows
    a(i, j) = a(i, j) + 1.0_dp
  end do
end do

! Slow: strided memory access (cache-unfriendly)
do i = 1, nrows
  do j = 1, ncols
    a(i, j) = a(i, j) + 1.0_dp
  end do
end do
```

Similarly, slice along the leftmost dimension for contiguous access: `a(:, j)` is contiguous; `a(i, :)` is strided.

---

## 9. Common Idioms and Patterns

### `do concurrent`

Use `do concurrent` for loops with no inter-iteration dependencies. This informs the compiler that parallelization and vectorization are safe:

```fortran
do concurrent (i = 1:n)
  result(i) = sin(real(i, dp) * pi / 4.0_dp)
end do
```

The body of `do concurrent` must satisfy constraints similar to a `pure` procedure: no I/O, no `exit`/`cycle`/`return`/`stop`/`error stop` that would leave the construct, no inter-iteration data dependencies, and all called procedures must be `pure`. The full set of restrictions is specified in the standard (section 11.1.7.5 in Fortran 2018). Compilers vary in how strictly they enforce these constraints -- when in doubt, consult your compiler's documentation.

`do concurrent` is a hint, not a guarantee. The compiler decides whether to parallelize. Use appropriate compiler flags (e.g., `-ftree-parallelize-loops=N` for gfortran) to enable parallel execution.

### `associate` Construct

Use `associate` to create temporary named aliases for deeply nested access paths, improving readability:

```fortran
associate(loc => locale%stages, lbl => stage%label)
  if (months < 2) then
    res = loc%newborn%label
  else if (months < 12) then
    res = loc%infant%label
  end if
end associate
```

**Semantics to be aware of:** When the selector is a variable or component reference (like `locale%stages`), the associate name is an alias -- modifications through it modify the original. When the selector is an expression (like `a + b`), the associate name refers to a read-only temporary. This distinction matters when you expect modifications to persist beyond the `associate` block.

Prefer `associate` for read-only aliasing of deeply nested component paths, where the reference-vs-temporary distinction does not affect behavior. Available since Fortran 2003.

### `block` Construct

Use `block` to introduce local scope within a procedure, allowing declarations where they would otherwise be illegal. This is useful for declaring locals inside `select case` arms, or for isolating allocatable temporaries in a specific branch:

```fortran
select case (mode)
  case (1)
    block
      real(dp), allocatable :: work(:)
      allocate(work(n))
      ! ... use work only in this case ...
    end block   ! work is automatically deallocated
  case (2)
    ! no work array needed here
end select
```

Available since Fortran 2008. Do not use `block` when a simple variable declaration at procedure scope suffices -- the syntactic overhead is not justified for routine temporaries.

### `select case`

Prefer `select case` over chains of `if`/`else if` for dispatching on discrete values:

```fortran
select case (month)
  case (1, 3, 5, 7, 8, 10, 12)
    days = 31
  case (4, 6, 9, 11)
    days = 30
  case (2)
    days = merge(29, 28, is_leap_year(year))
  case default
    days = 0
end select
```

### Internal Procedures

Subroutines and functions defined after `contains` inside a procedure have access to the host's variables by host association. They can be useful for small helpers that do not warrant a separate module procedure:

```fortran
subroutine outer(x, n)
  real(dp), intent(inout) :: x(n)
  integer, intent(in) :: n

  call normalize()
  call scale(2.0_dp)

contains

  subroutine normalize()
    real(dp) :: mx
    mx = maxval(x)    ! x comes from host association
    if (mx > 0.0_dp) x = x / mx
  end subroutine normalize

  subroutine scale(factor)
    real(dp), intent(in) :: factor
    x = x * factor    ! x comes from host association
  end subroutine scale

end subroutine outer
```

**Caveats:**
- Internal procedures silently depend on (and can modify) all host variables. Accidentally referencing a host variable instead of declaring a local is a common source of bugs.
- They cannot be passed as actual arguments to procedure dummy arguments.
- They cannot be unit-tested independently.

Keep internal procedures small (under ~10 lines) and prefer read-only access to host variables. For anything more substantial, extract to a module procedure with explicit arguments.

### Logical Operators

Use the modern operator forms, not the legacy dotted forms:

| Modern | Legacy (equivalent) | Meaning |
|---|---|---|
| `==` | `.eq.` | Equal |
| `/=` | `.ne.` | Not equal |
| `<` | `.lt.` | Less than |
| `<=` | `.le.` | Less than or equal |
| `>` | `.gt.` | Greater than |
| `>=` | `.ge.` | Greater than or equal |
| `.and.` | -- | Logical and |
| `.or.` | -- | Logical or |
| `.not.` | -- | Logical not |

The `==`, `/=`, `<`, `<=`, `>`, `>=` forms are available since Fortran 90 and are universally preferred. The logical connectives `.and.`, `.or.`, `.not.` have no symbolic equivalents.

---

## 10. Things to Avoid

### Dangerous Constructs

These features are genuine correctness risks. Their presence in new code should be treated as a bug.

#### `COMMON` Blocks

`COMMON` blocks are the pre-module mechanism for sharing data between program units. They provide no type checking, no name scoping, and rely on storage sequence association. **Use modules instead.**

```fortran
! BAD: COMMON block
common /shared/ x, y, n

! GOOD: module variable
module shared_data
  implicit none
  real(dp) :: x, y
  integer :: n
end module shared_data
```

#### `EQUIVALENCE`

`EQUIVALENCE` lets two variables share the same memory location. It is type-unsafe, optimizer-hostile, and a frequent source of aliasing bugs. **Use `transfer()` or type punning through `iso_c_binding` if you truly need reinterpretation.**

#### Implicit Typing

Never rely on the default implicit typing rules. Always use `implicit none` in every module and program unit. Without it, a typo like `totla` instead of `total` silently creates a new variable with a default type.

#### `GOTO`

Avoid `GOTO` in all new code. Every `GOTO` pattern has a structured replacement:

| `GOTO` pattern | Replacement |
|---|---|
| Forward jump to clean up | `block`/`exit` or early `return` |
| Loop exit | `exit` |
| Loop cycle | `cycle` |
| Computed GOTO | `select case` |
| Arithmetic IF | `if`/`else if`/`else` |

#### Assumed-Size Arrays

Assumed-size arrays (`dimension(*)`) provide no compile-time or runtime bounds checking. Use assumed-shape arrays (`dimension(:)`) instead:

```fortran
! BAD: assumed-size -- no bounds information
subroutine old_style(a, n)
  real(dp) :: a(*)
  integer :: n

! GOOD: assumed-shape -- bounds known, checkable
subroutine modern_style(a)
  real(dp), intent(inout) :: a(:)
  integer :: n
  n = size(a)
```

### Obsolescent and Deprecated Features

These features are not inherently dangerous but are stylistically outdated. Prefer their modern replacements in all new code.

#### `FORALL`

`FORALL` was intended for parallel array assignment but has been largely superseded by `do concurrent`. `FORALL` has confusing semantics (it is a statement, not a loop) and offers no performance benefit over array operations or `do concurrent`. It is declared obsolescent in Fortran 2018.

#### `double precision`

Do not use the `double precision` type specifier. It is a fixed concept (usually 64-bit) that cannot be parameterized. Use `real(dp)` with an explicit kind parameter:

```fortran
! BAD
double precision :: x

! GOOD
use iso_fortran_env, only: dp => real64
real(dp) :: x
```

#### External Procedures

Do not use `external` declarations. Place all procedures in modules to get automatic explicit interfaces and argument checking:

```fortran
! BAD: no interface checking
external :: my_function

! GOOD: full interface checking
use my_module, only: my_function
```

#### `include` Statements

Do not use `include` for code sharing. Use modules instead. `include` provides textual inclusion with no scoping, no interface generation, and no dependency tracking.

#### Fixed-Form Source

Never write new code in fixed-form. If maintaining legacy fixed-form code, convert it to free-form before making significant changes. Most editors can automate this conversion.

#### Mutable Module Variables

Avoid mutable (non-parameter) variables at module scope. They are effectively global state, creating hidden dependencies between procedures. Pass data through arguments instead.

---

## 11. Tooling

### Compiler Flags

#### gfortran (GNU Fortran)

**Development flags** (recommended for all builds during development):

```
gfortran -Wall -Wextra -Wpedantic -Werror \
         -std=f2008 -ffree-form -fimplicit-none \
         -fcheck=all -fbacktrace
```

| Flag | Purpose |
|---|---|
| `-Wall` | Enable common warnings: aliasing, ampersand, conversion, surprising constructs, unused variables, undefined do loops, integer division, and more |
| `-Wextra` | Additional warnings: unused parameters, do-subscript bounds |
| `-Wpedantic` | Warn on non-standard extensions |
| `-Werror` | Treat all warnings as errors |
| `-std=f2008` | Enforce Fortran 2008 standard conformance (also: `f2018`, `f2023`) |
| `-ffree-form` | Force free-form source layout |
| `-fimplicit-none` | Require explicit type declarations globally |
| `-fcheck=all` | Enable all runtime checks (bounds, pointer, memory, do-variable, recursion) |
| `-fcheck=bounds` | Runtime array bounds checking only (subset of `all`) |
| `-fbacktrace` | Print backtrace on runtime error |
| `-ffpe-trap=invalid,zero,overflow` | Trap floating-point exceptions |

**Release flags**:

```
gfortran -O2 -std=f2008 -ffree-form -DNDEBUG
```

#### Intel Fortran (ifx / ifort)

```
ifx -warn all -check all -standard-semantics -traceback
```

#### CMake Integration

```cmake
if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
    target_compile_options(mylib PRIVATE
        -Wall -Wextra -Wpedantic -Werror
        -ffree-form -std=f2008
        -fimplicit-none
    )
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
    target_compile_options(mylib PRIVATE
        -warn all -check all
    )
endif()
```

### Build Systems

#### fpm (Fortran Package Manager)

[fpm](https://fpm.fortran-lang.org/) is the modern, community-standard build tool for Fortran. It handles dependency management, building, testing, and installation.

Project structure:

```
my_project/
  fpm.toml          # Package manifest
  src/              # Library sources
  app/              # Application sources
  test/             # Test sources
```

`fpm.toml` example:

```toml
name = "sayableage"
version = "0.5.0"
license = "MIT"

[build]
auto-executables = true
auto-tests = true
```

Key commands:

```bash
fpm build            # Build the project
fpm test             # Run tests
fpm run              # Run the default executable
fpm install          # Install to ~/.local/bin
```

#### CMake

CMake is widely used for Fortran projects, especially those with C/C++ interoperability.

Since CMake 3.20, Fortran module dependencies are automatically scanned when using the Ninja or Makefile generators. For older CMake versions, source files must be listed so that modules are compiled before the units that `use` them.

Always set a module output directory to keep `.mod` files in a predictable location:

```cmake
cmake_minimum_required(VERSION 3.20)
project(myproject LANGUAGES Fortran)

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules)

add_library(mylib STATIC src/types.f90 src/core.f90)
target_include_directories(mylib PUBLIC ${CMAKE_Fortran_MODULE_DIRECTORY})

add_executable(tests test/test_main.f90)
target_link_libraries(tests PRIVATE mylib)

enable_testing()
add_test(NAME unit_tests COMMAND tests)
```

### Preprocessor (fypp)

[fypp](https://fypp.readthedocs.io/) is a Python-powered Fortran preprocessor supporting:
- Macro definitions and expansions
- Conditional compilation
- Loop-based code generation (generic programming)
- Include directives with variable substitution

Use fypp when you need generic programming patterns that Fortran's built-in facilities cannot express. Files conventionally use the `.fypp` extension.

### Linting and Static Analysis

- **gfortran `-Wall -Wextra -Wpedantic`**: The primary static analysis tool for most Fortran projects.
- **NAG Fortran compiler**: Known for the strictest standard conformance checking; useful as a secondary check even if gfortran is the primary compiler.
- **Intel Fortran `-warn all -check all`**: Comprehensive warnings and runtime checks.
- **`-fimplicit-none`**: Enforces `implicit none` globally, even in files that forget it.

---

## Quick Reference Checklist

For auditing a Fortran implementation, verify:

- [ ] Free-form source (`.f90` extension, no fixed-form)
- [ ] `implicit none` in every module and program unit
- [ ] `use` statements have `only` clause for large/shared modules (bare `use` acceptable for tightly-coupled companion modules)
- [ ] Module default visibility is `private` with explicit `public` exports
- [ ] All dummy arguments have `intent` attributes
- [ ] `intent(out)` procedures with derived types set all components (defaults are not preserved)
- [ ] Functions that can be `pure` are marked `pure`
- [ ] Kind parameters used for all numeric types (`real(dp)`, not `double precision` or `real*8`)
- [ ] Floating-point literals carry kind suffix (`1.0_dp`; `1.0d0` is acceptable but non-parametric; bare `1.0` is wrong)
- [ ] Assumed-shape arrays (`(:)`) used, not assumed-size (`(*)`)
- [ ] `newunit=` used in `open` statements, not hardcoded unit numbers
- [ ] `error stop` used for abnormal termination, not `stop`
- [ ] `iostat` used for I/O error handling
- [ ] `stat` used for allocation error handling where appropriate
- [ ] Allocatable arrays used, not pointers, for dynamic memory
- [ ] No `COMMON` blocks, `EQUIVALENCE`, `GOTO`, or `FORALL`
- [ ] No implicit typing relied upon
- [ ] No `external` declarations (procedures are in modules)
- [ ] `end` statements name their construct (`end module m`, not `end module`)
- [ ] Lowercase used for all keywords and identifiers (UPPER_CASE for domain constants/enumerators)
- [ ] Consistent indentation (2 spaces in this project)
- [ ] Compiled with `-Wall -Wextra -Wpedantic -Werror` (zero warnings)
- [ ] No mutable module-level variables (constants and parameters only)
- [ ] No parameterized derived types (compiler support unreliable)
- [ ] Internal procedures are small and document host variable access
