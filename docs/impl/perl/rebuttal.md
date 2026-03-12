# Rebuttal: Perl Style Guide Review

Senior Staff Engineering review of the Perl Style Guide (`docs/impl/perl/README.md`).
This document identifies guidelines that are technically problematic, internally
contradictory, or poor advice for a zero-dependency library project like Sayable.

---

## 1. Indentation: "2 or 4 spaces" is not a guideline

**Quoted guideline:**

> Use **2 or 4 spaces** per indent level. The `perlstyle` document recommends 4-column
> indentation. Many modern Perl projects use 2 spaces. Pick one and be consistent across the
> entire project.

**Problem:** A style guide that says "pick either" is not a style guide -- it is a
description of options. The whole purpose of this document is to eliminate ambiguity for
contributors and reviewers. Offering both choices creates exactly the situation this guide
should prevent: two contributors each pick a different option, both are "compliant," and
the codebase is inconsistent.

Furthermore, the actual codebase (`SayableAge::Formatter`) uses 2-space indentation. The
guide should codify what the project actually does, not present a menu.

**Recommendation:** Mandate 2-space indentation, since that is what the project uses.
Drop the mention of 4-space as an alternative. If 4-space is mentioned at all, it should
be as historical context, not as a valid choice.

---

## 2. Vertical alignment is a maintenance burden, not a readability win

**Quoted guideline:**

> Align corresponding items vertically when it aids readability, particularly in hash
> assignments and similar structures:
>
> ```perl
> my $self = bless {
>     locale    => $locale,
>     day       => $day_unit,
>     ...
> };
> ```

**Problem:** Vertical alignment creates noisy diffs. Adding a key longer than any existing
key (e.g., `just_born`) forces re-aligning every line in the block. This means a
single-line semantic change produces a multi-line diff, making code review harder, blame
output less useful, and merge conflicts more frequent.

The guide presents alignment as an unqualified good. In practice it is a tradeoff, and in
a project with 29 implementations and frequent cross-language changes, the cost of noisy
diffs outweighs the readability benefit.

The actual Formatter.pm in this project does not use vertical alignment in its `bless`
block. The guide contradicts the code it is supposed to govern.

**Recommendation:** Remove the recommendation for vertical alignment in hash assignments,
or at minimum present it as optional with an explicit warning about diff noise. Better
yet: let `perltidy` handle spacing decisions and do not manually align.

---

## 3. `Readonly` has no place in a zero-dependency guide

**Quoted guideline:**

> ```perl
> # Or with Readonly (more flexible, supports arrays/hashes)
> use Readonly;
> Readonly my $MAX_AGE_MONTHS => 6000;
> ```

**Problem:** This guide is written for a project whose foundational rule is "zero runtime
dependencies." Recommending `Readonly` -- an external CPAN module -- directly contradicts
that constraint. A reader following this advice will add a dependency and then fail review.

The guide does mention `use constant` first, but giving `Readonly` equal billing as an
alternative normalizes dependency addition. The "more flexible" parenthetical even frames
it as the superior choice.

**Recommendation:** Remove `Readonly` entirely. For the zero-dependency context, the
options are `use constant` for compile-time constants and `my $ALL_CAPS` for runtime
constants. That is sufficient.

---

## 4. `use constant` issues are not mentioned

**Quoted guideline:**

> For true constants, use the `constant` pragma or `Readonly` module:
>
> ```perl
> use constant MAX_RETRIES => 3;
> ```

**Problem:** The guide recommends `use constant` without mentioning its significant
footguns:

1. Constants created with `use constant` are bareword subroutines, not variables. They
   cannot be interpolated in strings: `"max is MAX_RETRIES"` does not interpolate.
2. They cannot be used as hash keys without disambiguation: `{ MAX_RETRIES => 1 }` treats
   `MAX_RETRIES` as a string, not the constant value.
3. List constants are returned as lists, not array references, which can cause subtle bugs
   in list context.
4. They are package-scoped, not lexically scoped.

The guide should either warn about these traps or recommend the `my $ALL_CAPS` pattern
(which the actual codebase uses) as the primary approach, with `use constant` as a
secondary option for true compile-time constants.

**Recommendation:** Lead with `my $ALL_CAPS` as the primary pattern. Mention
`use constant` as suitable for compile-time optimization but warn about interpolation and
hash-key traps.

---

## 5. Pragma placement advice is wrong for modern Perl

**Quoted guideline:**

> Pragmas go at the very top of the file, before the `package` declaration:
>
> ```perl
> use strict;
> use warnings;
> use utf8;
>
> package SayableAge::Formatter;
> ```

**Problem:** This is technically correct and matches the project's actual code. However,
the guide fails to mention that this placement has a subtle implication: `strict`,
`warnings`, and `utf8` are lexically scoped, so placing them before `package` means they
apply to the file scope, not the package scope. In a single-package-per-file codebase (which
this is), there is no practical difference. But the guide presents this as a universal rule
without explaining why.

More importantly, the guide fails to note that `use v5.36` (which it recommends later)
already implies `use strict` and `use warnings`. If the project targets 5.36+, the
three-pragma form is redundant. If it must support older Perls, `use v5.36` should not be
recommended as a drop-in replacement. The guide muddles these two paths without helping the
reader choose.

**Recommendation:** State clearly which minimum Perl version the project targets. If
5.36+, use `use v5.36; use utf8;`. If older, use the three-pragma form. Do not present
both as interchangeable.

---

## 6. The `eval` / `$@` error handling pattern is subtly broken

**Quoted guideline:**

> ```perl
> my $result = eval {
>     potentially_dangerous_operation();
>     1;    # true on success
> };
> if (!$result) {
>     my $error = $@;
>     # handle error
> }
> ```

**Problem:** The guide correctly identifies that `$@` can be clobbered between the `eval`
and the check, and recommends the `1;` return pattern. But its example still reads `$@`
after the `if (!$result)` check, which is the exact window where `$@` can be clobbered. If
an object destructor triggered by the `eval` block's cleanup runs `eval` internally, `$@`
gets overwritten before `my $error = $@` executes.

The correct pattern captures `$@` immediately:

```perl
my $result = eval {
    potentially_dangerous_operation();
    1;
};
my $error = $@;
if (!$result) {
    # use $error
}
```

Or even better, use the idiom from Perl 5.14+ where `$@` is more reliable, but the guide
does not discuss version-specific `$@` behavior at all.

**Recommendation:** Fix the example to capture `$@` immediately after the `eval` block,
before the conditional check. Explain why the ordering matters.

---

## 7. `Try::Tiny` recommendation contradicts zero-dependency rule

**Quoted guideline:**

> For cleaner syntax (at the cost of a dependency), `Try::Tiny` avoids the pitfalls of
> bare `eval`:

**Problem:** Same issue as `Readonly`. This is a zero-dependency project. Recommending
`Try::Tiny` is actively harmful -- it tells the reader "this is a good approach" when it
would actually violate the project's most important constraint.

The guide does note "at the cost of a dependency," but this understatement does not
adequately signal that this option is completely off the table for this project.

**Recommendation:** Either remove `Try::Tiny` entirely or explicitly mark it as
"NOT APPLICABLE to this project (zero-dependency constraint)" to prevent confusion.

---

## 8. `return undef` vs bare `return` advice is contentious and incomplete

**Quoted guideline:**

> Use `return undef` (explicit) rather than bare `return` when you specifically mean to
> return an undefined value. Bare `return` returns an empty list in list context, which
> behaves differently.

**Problem:** This is one of the most debated points in Perl style. The guide picks a side
without acknowledging the tradeoff.

`return undef` in list context returns a one-element list containing `undef`, which is
*true* in boolean context:

```perl
my @results = maybe_get_value();  # returns (undef) not ()
if (@results) {
    # THIS BRANCH EXECUTES -- @results has 1 element
}
```

Meanwhile, bare `return` returns an empty list in list context, which is false:

```perl
my @results = maybe_get_value();  # returns ()
if (@results) {
    # This branch does NOT execute
}
```

Perl::Critic's `ProhibitExplicitReturnUndef` policy (severity 5 -- the highest) flags
`return undef` precisely because of this list-context trap. The guide is recommending a
pattern that the project's own recommended linter considers a critical violation.

The actual codebase uses `return undef` consistently, and in this project's context
(functions always called in scalar context), it is harmless. But the guide should
acknowledge the tradeoff rather than presenting `return undef` as universally correct.

**Recommendation:** Acknowledge both forms. Recommend `return undef` when the function is
exclusively called in scalar context (as in this project). Note that `Perl::Critic`
defaults to flagging it and explain the policy override in `.perlcriticrc`.

---

## 9. Moo/Moose coverage is unnecessary scope creep

**Quoted guideline:**

> For larger systems, `Moo` (lightweight) or `Moose` (full-featured) provide declarative
> attribute definitions, type checking, roles, and more.

**Problem:** This guide serves a specific project that mandates zero dependencies and uses
`bless`-based OO throughout. Spending 20+ lines on Moo and Moose -- frameworks the project
cannot use -- is wasted space that dilutes the guide's authority. A reviewer reading this
guide should get clear, actionable rules, not a survey of the Perl OO ecosystem.

The guide does note that these "add runtime dependencies, so they are unsuitable for
zero-dependency libraries," but this reads as an afterthought to the recommendation rather
than a clear prohibition.

**Recommendation:** Remove the Moo/Moose section entirely. Mention their existence in a
one-line note ("For projects that allow dependencies, Moo provides declarative OO") and
move on. The guide should focus exclusively on patterns the project actually uses.

---

## 10. The read-write accessor pattern encourages mutable state

**Quoted guideline:**

> For read-write accessors:
>
> ```perl
> sub name {
>     my $self = shift;
>     $self->{name} = shift if @_;
>     return $self->{name};
> }
> ```

**Problem:** This combined getter/setter pattern using `@_` is a Perl tradition, but the
guide presents it without qualification. In a formatting library where locale objects and
formatters should be immutable after construction, recommending read-write accessors invites
bugs. The actual `SayableAge::Formatter` has no setters -- all state is set in `new`.

Additionally, the `shift` + `@_` pattern is confusing to readers unfamiliar with Perl
idioms: `$self` is shifted off `@_`, but then `@_` is checked for remaining arguments.
This works but is not self-documenting.

**Recommendation:** Lead with read-only accessors as the default. Present the read-write
pattern only as an exception for cases that genuinely need mutation, with a note that the
project's objects are immutable after construction.

---

## 11. The `wantarray` section encourages bad API design

**Quoted guideline:**

> Perl expressions behave differently in scalar vs. list context. The `wantarray` function
> detects calling context:
>
> ```perl
> sub flexible {
>     my @results = compute();
>     return wantarray ? @results : $results[0];
> }
> ```

**Problem:** The guide says "Use `wantarray` sparingly" but then provides a full example
and explanation. For a style guide aimed at code review, this section normalizes a pattern
that makes functions unpredictable. The project's code does not use `wantarray` anywhere.

Furthermore, `wantarray` is considered a misfeature by many experienced Perl developers.
It has been deprecated in recent Perl versions (5.40 adds a deprecation warning). A
forward-looking style guide should discourage its use, not teach it.

**Recommendation:** Replace the `wantarray` section with a clear statement: "Functions
should have a single, predictable return type. Do not use `wantarray` to change return
behavior based on calling context." One sentence, not a subsection.

---

## 12. Method chaining section is irrelevant to this project

**Quoted guideline:**

> For method chaining, return `$self`:
>
> ```perl
> sub set_locale {
>     my ($self, $locale) = @_;
>     $self->{locale} = $locale;
>     return $self;
> }
> ```

**Problem:** The project's Formatter is immutable after construction. There are no setter
methods. There is no method chaining anywhere in the codebase. This section describes a
pattern that does not exist in the project and would conflict with the immutable-after-
construction design.

**Recommendation:** Remove this section. It adds no value for reviewers of this codebase
and implicitly suggests a mutable design that contradicts the existing architecture.

---

## 13. The `print {$fh}` brace recommendation is oversimplified

**Quoted guideline:**

> When printing to a filehandle stored in a variable, use braces to disambiguate:
>
> ```perl
> print {$fh} "output\n";    # clear
> print $fh "output\n";      # ambiguous (looks like $fh is the first arg)
> ```

**Problem:** The braced form `print {$fh}` is recommended by *Perl Best Practices*, and
the guide correctly calls it out. But the commentary is misleading: `print $fh "output\n"`
is not actually ambiguous to the Perl parser -- it works correctly as indirect object
syntax for `print`. The "ambiguity" is purely for human readers.

More importantly, the guide should note that in modern Perl, the idiomatic approach is to
use `say` (with `use feature 'say'`) or method-style I/O with modules, rather than bare
`print` to filehandles. The guide mentions `say` in passing in the pragmas section but
does not connect it to this recommendation.

This is a minor point, but the reasoning should be accurate.

**Recommendation:** Keep the recommendation but fix the explanation: the ambiguity is for
human readers, not the parser. Mention `say` as the preferred alternative when a newline
is desired.

---

## 14. The guide does not address the `unless` block prohibition consistently

**Quoted guideline (in statement modifiers):**

> Avoid `unless` with `elsif` or complex conditions -- it becomes hard to reason about

**Quoted guideline (in Perl::Critic section):**

> `ProhibitUnlessBlocks` is listed as a notable policy under ControlStructures

**Problem:** The guide mentions `ProhibitUnlessBlocks` as a Perl::Critic policy but does
not take a position on whether `unless` blocks (not just statement modifiers) are
acceptable. The statement modifiers section discusses `unless` as a postfix modifier but
does not address `unless { ... }` blocks directly. The actual codebase uses `unless` only
in postfix position, never as a block.

**Recommendation:** State explicitly: `unless` is acceptable as a postfix modifier for
simple guard clauses (`return undef unless defined $x`). `unless` blocks
(`unless (...) { ... }`) should be rewritten as `if (!...)` for clarity.

---

## 15. Missing: no guidance on `@_` unpacking conventions

**Problem:** The guide shows `my ($self, $dob, $as_of) = @_;` in examples but never
explicitly states this as the required pattern. It also shows `my $self = shift;` in
the accessor section. The actual codebase uses list assignment from `@_` consistently
(never `shift` except implicitly). The guide should pick one and mandate it.

The `shift` pattern and the list-assignment pattern have different failure modes:
- `shift` modifies `@_`, which is confusing if `@_` is used later (as in the read-write
  accessor example).
- List assignment is non-destructive and explicit about expected parameters.

**Recommendation:** Mandate list assignment (`my ($self, ...) = @_;`) as the standard
pattern. Acknowledge `shift` as acceptable only for `$self` extraction when followed by
further `@_` usage, and note that the accessor example is the only case where this applies.

---

## 16. Perltidy `-pbp` flag recommendation is outdated

**Quoted guideline:**

> ```
> -pbp     # Perl Best Practices base
> ```

**Problem:** The `-pbp` flag applies the formatting conventions from *Perl Best Practices*
(2005). Some of those conventions conflict with modern Perl community standards. For
example, `-pbp` implies 4-space indentation, but the guide's own code examples and the
project codebase use 2-space indentation. Using `-pbp` and then overriding it with `-i=2`
is a confusing starting point.

**Recommendation:** Do not recommend `-pbp` as a base. Instead, provide a complete
`.perltidyrc` that reflects the project's actual conventions. Start from the flags the
project needs, not from a 20-year-old book's preferences.

---

## 17. Missing: no mention of `binmode` for UTF-8 I/O

**Problem:** The guide correctly mandates `use utf8` (source encoding) but says nothing
about I/O encoding. In Perl, `use utf8` only affects the source file -- it does not change
how filehandles read or write data. Any code that reads or writes UTF-8 data (which this
project does, given its 110 locales including Arabic, Hebrew, Amharic, and CJK) needs:

```perl
binmode STDOUT, ':encoding(UTF-8)';
```

or the equivalent `open` layer. The test file outputs Unicode characters via `Test::More`,
and whether those display correctly depends on the terminal's encoding and Perl's output
layer.

**Recommendation:** Add a section on UTF-8 I/O that complements the `use utf8` pragma
discussion. Explain the distinction between source encoding and I/O encoding.

---

## Summary

The guide is generally well-structured and covers the right topics. The core problems are:

1. **Ignores the zero-dependency constraint.** Recommending `Readonly`, `Try::Tiny`, and
   `Moo`/`Moose` in a zero-dependency project is actively misleading.
2. **Fence-sitting on choices.** A style guide should make decisions. "2 or 4 spaces"
   and "either `use constant` or `Readonly`" are descriptions, not guidelines.
3. **Does not reflect the actual codebase.** Several recommendations (vertical alignment,
   method chaining, read-write accessors) contradict the patterns used in the project's
   own Perl implementation.
4. **Presents deprecated or dangerous patterns without adequate warnings.**
   `return undef`, `wantarray`, and the `eval`/`$@` capture ordering all have significant
   footguns that the guide either ignores or underplays.
5. **Missing practical guidance.** No `@_` unpacking convention, no UTF-8 I/O guidance, no
   clear minimum Perl version requirement.
