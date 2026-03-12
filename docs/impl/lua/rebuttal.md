# Lua Style Guide -- Senior Engineering Review

Reviewer: Senior Staff Engineer
Date: 2026-03-11

## Overall Assessment

This is a well-structured and generally accurate Lua style guide. The
sources are authoritative, the examples are clear, and the coverage is
broad. However, several guidelines are either technically incorrect,
internally inconsistent, impractical for the project's actual needs, or
present subjective preferences as settled convention. This rebuttal
addresses each such issue in detail.

---

## 1. Indentation: The 4-space rule is presented with false confidence

### Quoted guideline

> Use **4 spaces** per indentation level. Never use tabs. (Note: the
> Olivine Labs guide recommends 2 spaces. Both are common in the Lua
> community. The important thing is consistency within a project. This
> project uses 4 spaces.)

### Problem

The parenthetical note contradicts the tone of the opening sentence. If
"the important thing is consistency within a project," then the guideline
should lead with that principle and state the project's chosen convention
as a project decision, not as a general Lua style rule. The way it is
currently written, a reader encounters an authoritative "use 4 spaces"
followed by an undermining footnote that says the community is actually
split.

More substantively, the actual Lua implementation in this project
(`age/impl/lua/sayableage.lua`) uses 4-space indentation, which is fine.
But the guide should acknowledge that 2-space indentation is at least as
common in the broader Lua ecosystem (the Lua reference implementation
itself, OpenResty projects, Neovim's Lua configuration, and the
lua-users wiki examples frequently use either convention). Presenting
4-space as *the* Lua convention is misleading.

### Recommendation

Lead with "consistency within a project matters more than any specific
width" and then state "this project uses 4 spaces" as a project-level
decision. Drop the imperative "use 4 spaces" framing, which reads as a
universal Lua community norm when it is not.

---

## 2. String quoting default is wrong for this project

### Quoted guideline

> Use double quotes for strings by default. Single quotes are also
> acceptable -- the important thing is consistency within a project. (The
> Olivine Labs guide recommends single quotes.)

### Problem

The guide recommends double quotes as the default, but the actual
codebase implementation (`sayableage.lua`) exclusively uses double
quotes, which does align. However, the guidance buries the real rule
("consistency within a project") under an arbitrary default. In the Lua
community there is no consensus. The Olivine Labs guide recommends
single quotes. The `lua-users.org` wiki uses both freely. The Lua
reference manual is indifferent.

More importantly, the guide provides no *reason* for preferring double
quotes. Without a reason, this is style noise that invites bikeshedding.

### Recommendation

State the project convention ("this project uses double quotes") and
move on. Remove the "by default" framing, which implies a universal Lua
norm that does not exist.

---

## 3. The semicolon exception is presented poorly

### Quoted guideline

> The one exception is disambiguating a function call from a statement
> when a line begins with `(`:
>
> ```lua
> local x = f()
> ;(function() end)()  -- semicolon prevents parsing as f()()
> ```
>
> This situation is rare and usually indicates the code should be
> restructured.

### Problem

The guide says "this situation is rare and usually indicates the code
should be restructured" -- which is the correct advice. But it then does
not show the restructured alternative. Presenting a semicolon-prefixed
IIFE as the "exception" to the no-semicolons rule legitimizes a pattern
that the guide itself admits should not exist.

In practice, Lua IIFEs beginning a line after a function call is a
pattern that essentially never occurs in well-structured module code.
Including it in a style guide gives it undeserved visibility.

### Recommendation

Either remove this exception entirely (it is too obscure to be
actionable in a project-level style guide) or show the restructured
alternative inline. Showing the problematic pattern without the fix
violates the guide's own "name over comment" and "show the good way"
philosophy.

---

## 4. The `tostring` coercion guidance is overly prescriptive

### Quoted guideline

> Lua automatically coerces numbers to strings in concatenation contexts,
> but relying on this makes code less clear:
>
> ```lua
> -- Implicit coercion (works but unclear intent)
> local s = "count: " .. count
>
> -- Explicit (preferred when formatting matters)
> local s = string.format("count: %d", count)
> ```

### Problem

Calling `"count: " .. count` "unclear intent" is an overstatement. In
Lua, the `..` operator is the string concatenation operator. Every Lua
programmer understands that `"count: " .. count` produces a string. The
intent is perfectly clear.

`string.format` is the right tool when you need padding, precision,
hexadecimal, or other formatting control. But for simple concatenation
of a number into a message string, `..` is idiomatic and clear.

The actual project code uses `tostring()` and `..` in exactly these
simple cases (e.g., `tostring(count)` in `sayableage.lua`). Labeling
this pattern as having "unclear intent" conflicts with the codebase.

### Recommendation

Reframe: recommend `string.format` when formatting control is needed
(padding, precision, multiple substitutions). Acknowledge that simple
number-to-string concatenation with `..` is idiomatic and clear. Do not
label it as "unclear."

---

## 5. Module table naming guidance is confusing

### Quoted guideline

> | Module tables | `PascalCase` or single uppercase letter | `SayableAge`, `M` |

### Problem

The guide gives two completely different naming conventions for the same
thing without explaining when to use which. `SayableAge` and `M` are
not interchangeable patterns -- they serve different purposes:

- `M` is the idiomatic convention for the *local module table within a
  module file*. It is internal to the file and never exposed to callers.
- `SayableAge` (PascalCase) is appropriate for class-like tables that
  use the prototype pattern with `__index`.

Conflating these into a single row in a naming table creates confusion.
A developer reading this could reasonably conclude that `M` and
`SayableAge` are style alternatives, when in fact they are structural
alternatives for different patterns.

### Recommendation

Split this into two entries:

- Local module table (return-table pattern): `M` (single letter,
  idiomatic convention)
- Class tables (prototype/OOP pattern): `PascalCase` (e.g., `Account`,
  `Point`)

---

## 6. The `or` default-value caveat deserves stronger treatment

### Quoted guideline

> **Caveat:** `or` treats `false` the same as `nil`. If `false` is a
> valid value, use an explicit nil check:

### Problem

The guide correctly identifies the caveat but buries it as a footnote
under an idiom recommendation. In practice, the `false`-as-valid-value
bug is one of the most common and subtle bugs in Lua code, especially
for developers coming from other languages. The `or`-for-defaults
pattern is genuinely dangerous for boolean parameters, which are
extremely common in configuration tables.

Consider: `local verbose = opts.verbose or true`. This *always* returns
`true`, even when `opts.verbose` is explicitly `false`. This is not a
corner case -- it is a frequent source of production bugs.

### Recommendation

Elevate this from a "caveat" to a first-class rule: "Never use `or` for
defaults on boolean parameters." Show the failure case prominently, not
as a secondary note. The explicit nil-check pattern should be the
*primary* recommendation for boolean defaults, with the `or` shorthand
reserved for string and numeric defaults where `false` is never a valid
value.

---

## 7. The ternary pattern caveat deserves stronger treatment

### Quoted guideline

> **Caveat:** This fails if the "true" branch is `false` or `nil`:
>
> ```lua
> -- BUG: returns "default" even when condition is true
> local x = true and false or "default"  --> "default"
> ```
>
> For those cases, use an `if`/`else` block.

### Problem

Same structural issue as the `or`-for-defaults caveat. The guide
recommends the `and`/`or` ternary pattern, then quietly warns it is
broken in a common case. This pattern is fragile enough that it should
be recommended with significant qualification, not as a primary idiom
with a trailing caveat.

The `and`/`or` ternary is fine when both possible results are guaranteed
to be truthy (non-nil, non-false). But the guide does not state this
precondition clearly. The caveat reads like an afterthought rather than
a constraint on usage.

### Recommendation

State the precondition upfront: "The `and`/`or` ternary pattern works
only when the `and` operand is guaranteed to be truthy." Lead with the
constraint, not the idiom. The `if`/`else` block should be presented as
the general-purpose solution, with `and`/`or` as a convenience shorthand
for the restricted case.

---

## 8. Lazy requires guidance is too permissive

### Quoted guideline

> For modules that are expensive to load or only sometimes needed,
> require inside the function that uses them:
>
> ```lua
> function M.get_locale(code)
>     local registry = require("locales.init")
>     return registry.get_locale(code)
> end
> ```
>
> This is acceptable but should be documented with a comment if it is
> not obvious why the require is deferred.

### Problem

The guide says lazy requires "should be documented with a comment" but
does not show the comment. More importantly, it does not address the
testability problem: lazy requires make dependency injection harder
and make it impossible to determine a module's dependencies by reading
its header.

The actual codebase uses this pattern in `sayableage.lua` for
`M.get_locale`, which is reasonable because the locale registry is large
and optional. But the guide frames this as a general practice ("for
modules that are expensive to load or only sometimes needed"), which is
too broad. In a codebase with 110 locale files, "expensive to load" is a
real concern. In general Lua code, lazy requires are much more rarely
justified and should be treated as an exception, not a documented
alternative pattern.

### Recommendation

Narrow the guidance: lazy requires are acceptable *only* for large
optional subsystems (like the locale registry in this project). Require
a justification comment in all cases (not just "if it is not obvious").
Warn that lazy requires make dependency tracking harder and should not be
used routinely.

---

## 9. The forward-declaration example has a subtle bug

### Quoted guideline

> ```lua
> local is_even, is_odd
>
> function is_even(n)
>     if n == 0 then return true end
>     return is_odd(n - 1)
> end
>
> function is_odd(n)
>     if n == 0 then return false end
>     return is_even(n - 1)
> end
> ```

### Problem

The forward-declared functions are assigned using the `function name()`
syntax *without* the `local` keyword. This means `is_even` and `is_odd`
are reassigned as assignments to the already-declared locals (correct
behavior), but the syntax is visually indistinguishable from a global
function declaration to a reader who does not notice the
forward-declaration above. This is a teaching hazard.

Luacheck will not flag this because the locals are already declared. But
if someone removes the forward declaration (thinking it is unnecessary),
the functions silently become globals. The guide should use the
assignment form to make the local binding explicit:

```lua
local is_even, is_odd

is_even = function(n)
    if n == 0 then return true end
    return is_odd(n - 1)
end

is_odd = function(n)
    if n == 0 then return false end
    return is_even(n - 1)
end
```

### Recommendation

Use the `name = function(...)` assignment form in the forward-declaration
example to make the binding relationship visually explicit. Add a brief
note explaining why this form is preferred over `function name(...)` in
the forward-declaration context.

---

## 10. The `rawget`/`rawset` section is misleadingly cautionary

### Quoted guideline

> `rawget` and `rawset` bypass metatables. They have legitimate uses
> (avoiding infinite `__index`/`__newindex` recursion), but using them to
> circumvent metatable behavior elsewhere makes code fragile and hard to
> reason about.

### Problem

This guidance is vague. "Circumvent metatable behavior elsewhere" is not
actionable -- what does "elsewhere" mean? The legitimate use case
(avoiding infinite recursion in metamethods) is exactly where `rawget`
and `rawset` belong, and the guide acknowledges this. But it then adds a
hand-wavy warning about using them "elsewhere" without defining what
problematic usage looks like.

In practice, `rawget` is commonly and correctly used for:
- Checking whether a key exists on an object itself (not inherited)
- Implementing `__newindex` guards
- Testing/introspection code

The current text reads as "these are scary, be careful" without giving
concrete guidance on when they are appropriate vs. inappropriate.

### Recommendation

Either provide concrete examples of problematic `rawget`/`rawset` usage
(e.g., bypassing `__newindex` validation from outside the class), or
remove this section. A vague warning is worse than no warning because it
creates unwarranted fear of a standard language feature.

---

## 11. The OOP section is disproportionately long for this project

### Quoted guideline

The entire section 8 (Metatables and OOP) spans roughly 160 lines,
covering basic metatable usage, all common metamethods, prototype-based
OOP, inheritance, and colon syntax.

### Problem

The actual Lua implementation in this project (`sayableage.lua`) uses
zero metatables, zero OOP, and zero colon syntax. It is a pure
functional module using the return-table pattern. The test file uses
Busted's BDD syntax but no custom OOP.

A style guide should be proportional to the codebase it governs. Having
160 lines on OOP patterns for a codebase that uses none of them is
reference-manual material, not a style guide. It dilutes the
actionable guidelines (like "use `local`", "use `table.concat` in
loops") with content that will never apply to this project.

The guide does correctly note at the end of section 8: "Reserve
metatables and OOP for cases where you need inheritance, operator
overloading, or instance-specific state management." But this advice is
buried under 150 lines of "here is how to do OOP" -- the structure
contradicts the message.

### Recommendation

Drastically reduce the OOP section. Keep the colon-vs-dot syntax
explanation (it is relevant even without OOP, as Busted uses colon
syntax). Keep the "when not to use OOP" advice, promoted to lead the
section. Move the detailed OOP patterns to an appendix or link to PiL.

---

## 12. The `std` setting in the Luacheck example is wrong

### Quoted guideline

> ```lua
> -- .luacheckrc
> std = "lua51+lua52+lua53"
> ```

### Problem

The `std` field in Luacheck does not use the `+` concatenation syntax
shown here. The correct syntax for multiple standard versions is to use
Luacheck's `+` modifier on individual standards:

```lua
std = "max"  -- allow globals from all known Lua versions
```

Or for a specific version:

```lua
std = "lua53"
```

The `"lua51+lua52+lua53"` syntax does actually work in Luacheck (each
`+std` adds to the allowed globals set), but presenting a triple-union
as the default configuration is unusual and potentially confusing. A
project targeting a specific Lua version (which most projects do) should
set exactly that version. A project supporting multiple versions should
use `"max"` or explicitly test under each version.

### Recommendation

Show a single-version example that matches the project's actual target
runtime (e.g., `std = "lua51"` or `std = "lua53"`). If multi-version
support is genuinely needed, explain why and show the correct union
syntax with a note about what it does.

---

## 13. The checklist conflates style rules with correctness rules

### Quoted guideline

> ## Quick Reference Checklist
>
> For code auditing, verify the following:
>
> - [ ] All variables are `local` (no accidental globals)
> - [ ] No unused variables or arguments (without justification)
> - [ ] All `require` calls are at the top of the file and assigned to locals
> - [ ] Module uses the return-table pattern
> - [ ] Functions are short, focused, and named descriptively
> ...

### Problem

The checklist mixes machine-verifiable correctness checks (accidental
globals, unused variables) with subjective style preferences (functions
are "short, focused, and named descriptively"). These are fundamentally
different kinds of review criteria:

- "All variables are `local`" can be verified by Luacheck. It is a
  binary pass/fail.
- "Functions are short, focused, and named descriptively" is a judgment
  call that requires human review and cannot be checked by tooling.

Mixing them in a flat list without distinguishing their nature makes the
checklist harder to use in practice. A reviewer checking off
"descriptive names" treats it as equivalent to "no globals," but the
confidence levels are completely different.

### Recommendation

Split the checklist into two sections: "Automated checks" (things
Luacheck or a linter can verify) and "Manual review" (things requiring
human judgment). This makes it clear which items are pass/fail gates and
which are review discussion points.

---

## 14. Missing: Lua version compatibility guidance

### Problem

The guide does not state which Lua version(s) this project targets. This
is critical because:

- `goto` exists in 5.2+ but not 5.1
- `#` behavior on tables changed between 5.1 and 5.2
- `setfenv`/`getfenv` exist in 5.1 but not 5.2+
- `bit32` exists in 5.2 but not 5.3 (where bitwise operators are native)
- String length semantics differ (byte length vs. UTF-8)
- Integer vs. float distinction was introduced in 5.3

The guide mentions `setfenv` removal in 5.2+ and `arg` deprecation, but
never states the project's target version. A developer does not know
whether they can use `goto`, integer division (`//`), or bitwise
operators.

### Recommendation

Add a clear statement of the project's target Lua version at the top of
the guide, and note any compatibility constraints.

---

## 15. Missing: UTF-8 / Unicode string handling

### Problem

The guide has a thorough string handling section but says nothing about
UTF-8. The project handles 110 locales including Hebrew, Arabic,
Amharic, and Chinese -- all of which use multi-byte UTF-8 sequences.

Key issues the guide should address:

- `#s` returns *byte length*, not character count, for UTF-8 strings
- `string.sub` operates on bytes, not characters
- `string.reverse` will corrupt multi-byte characters
- Lua 5.3+ provides `utf8.len`, `utf8.offset`, and `utf8.codes`
- Pattern matching (`%a`, `%l`, `%u`) only works for ASCII characters

For a project with locales in Arabic, Hebrew, Amharic, Thai, and other
non-Latin scripts, this is not an academic concern -- it is a practical
correctness issue.

### Recommendation

Add a UTF-8 section that covers the byte-vs-character distinction,
documents which `string` functions are safe for multi-byte strings, and
references the `utf8` library (5.3+) or LuaRocks UTF-8 alternatives for
5.1.

---

## 16. The error handling taxonomy is good but incomplete

### Quoted guideline

> | Situation | Approach |
> |-----------|----------|
> | Programming error (bug) | `error()` with descriptive message |
> | Precondition violation | `assert()` or `error(..., 2)` |
> | Expected failure (I/O, parsing) | Return `nil, error_message` |
> | Calling untrusted/risky code | Wrap in `pcall` or `xpcall` |

### Problem

This taxonomy is good but does not address a common pattern in the
actual codebase: returning `nil` (without an error message) to indicate
"no result." In `sayableage.lua`, functions like `parse_date` and
`format_age` return plain `nil` on invalid input, not `nil, error_msg`.

This is a legitimate third error pattern: "no result" (distinct from
"expected failure with diagnostic"). The guide's taxonomy does not
acknowledge this, which means a code reviewer using this guide might
flag bare `nil` returns as violations of the "`nil, error_message`"
convention when they are actually a deliberate design choice.

### Recommendation

Add a row to the taxonomy for "no meaningful result" (return `nil`
without a message) and clarify when it is appropriate vs. the
`nil, error_message` pattern.

---

## Summary

The guide is a solid foundation. The major issues are:

1. **Proportionality**: The OOP section is vastly oversized for a
   project that uses no OOP.
2. **Missing critical content**: No Lua version specification, no UTF-8
   guidance for a multi-locale project.
3. **Caveat positioning**: The `or`-for-defaults and `and`/`or`-ternary
   caveats are buried when they should be prominent.
4. **Inconsistencies**: Some guidelines conflict with the actual
   codebase conventions.
5. **Technical errors**: The Luacheck `std` example and the
   forward-declaration syntax are misleading.

These are fixable. The structure, sources, and overall direction are
sound.
