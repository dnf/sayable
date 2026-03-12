# Perl Style Guide

A guide to idiomatic Perl coding style and best practices for code auditing Perl
implementations in the Sayable project. This is a zero-dependency library -- all
recommendations reflect that constraint.

## Table of Contents

- [1. Naming Conventions](#1-naming-conventions)
- [2. Code Formatting](#2-code-formatting)
- [3. Pragmas and Strictures](#3-pragmas-and-strictures)
- [4. Module Design](#4-module-design)
- [5. Data Structures](#5-data-structures)
- [6. Error Handling](#6-error-handling)
- [7. Regular Expressions](#7-regular-expressions)
- [8. String Handling](#8-string-handling)
- [9. Common Idioms](#9-common-idioms)
- [10. Things to Avoid](#10-things-to-avoid)
- [11. Tooling](#11-tooling)
- [Sources](#sources)

---

## 1. Naming Conventions

Perl's official `perlstyle` document establishes the core naming rules. The principle is:
use case to indicate scope and purpose.

### Variables

| Scope / Purpose | Convention | Example |
|---|---|---|
| Lexical (function-scoped) | `$lower_snake_case` | `$diff_days` |
| Package-wide globals | `$Some_Caps_Here` | `$VERSION` |
| Constants | `$ALL_CAPS` | `$MAX_AGE_MONTHS` |
| Private (internal) | Leading underscore | `$_cache`, `$_default_formatter` |

Use underscores to separate words in multi-word identifiers. Prefer `$var_names_like_this`
over `$VarNamesLikeThis`.

### Subroutines

Subroutine and method names should be all lowercase with underscores:

```perl
sub format_age { ... }
sub _parse_date { ... }     # private: leading underscore
sub resolve_unit { ... }
```

A leading underscore signals that the subroutine is internal and not part of the
public API. This is a convention, not an enforcement mechanism.

### Packages and Modules

- **Pragmas** use all lowercase: `strict`, `warnings`, `utf8`
- **Modules** use `CamelCase` (no underscores): `SayableAge`, `Time::Local`, `List::Util`
- **Nested packages** use `::` as separator: `SayableAge::Formatter`, `SayableAge::Locales::EN`

Module names should be descriptive of purpose, not implementation. Stay consistent with
existing CPAN naming conventions. Do not create new top-level hierarchies when an
established one fits.

### File Names

- Module files match their package name: `SayableAge/Formatter.pm`
- Test files use `.t` extension: `formatter.t`
- Script files use `.pl` extension or no extension

### Constants

The primary approach for constants is a lexical `my` variable in `ALL_CAPS`:

```perl
my $MAX_AGE_MONTHS = 6000;
```

This is simple, lexically scoped, interpolates in strings, and works as a hash key without
surprises.

For true compile-time constants where the value must be inlined by the optimizer, use the
`constant` pragma:

```perl
use constant MAX_RETRIES => 3;
```

Be aware of `use constant` traps: constants are bareword subroutines, so they do not
interpolate in strings (`"max is MAX_RETRIES"` prints literally) and require explicit
syntax when used as hash keys (`{ MAX_RETRIES() => 1 }`).

---

## 2. Code Formatting

### Indentation

Use **2 spaces** per indent level. Do not use tabs for indentation.

### Braces

Opening brace on the same line as the keyword (K&R style):

```perl
sub format_age {
  my ($self, $dob, $as_of) = @_;

  if ($months < 3) {
    return $result;
  } elsif ($months < 24) {
    return $other_result;
  } else {
    return $fallback;
  }
}
```

The closing brace of a multi-line block lines up with the keyword that opened it.
`} elsif {` and `} else {` go on the same line as the closing brace.

One-line blocks may stay on a single line when short:

```perl
return 'newborn' if $months < 2;
```

### Spacing

- Space around most operators: `$x = $y + 1`
- Space after commas: `my ($class, $locale, %opts) = @_;`
- No space between function name and parenthesis: `format_age($dob)`
- Space before opening brace of a block: `if ($cond) {`
- No space before semicolons: `return $result;`
- Space around complex subscripts: `$hash{ $key }`
- No space around simple subscripts: `$array[0]`, `$hash{name}`

### Line Length

Keep lines under **100 characters** as a guideline. Break long lines after an operator
(except `and` and `or`, which read better at the start of the continuation line):

```perl
my $result = SayableAge::Locale::resolve_unit(
  $years, $self->{year}, $self->{locale}, $self->{half}
);
```

### Vertical Alignment

Do not manually align hash values, assignments, or other structures with extra whitespace.
Alignment creates noisy diffs when keys are added or renamed, makes merge conflicts more
likely, and reduces the usefulness of `git blame`. Let each line stand on its own:

```perl
my $self = bless {
  locale => $locale,
  day => $day_unit,
  week => $week_unit,
  month => $month_unit,
  year => $year_unit,
  half => $half_marker,
  delimiter => $delimiter,
}, $class;
```

### Blank Lines

Use blank lines between chunks of code that do different things. Separate logical sections
within a subroutine with a blank line. Separate subroutine definitions with a blank line.

### Perl::Tidy

Automate formatting with [Perl::Tidy](https://metacpan.org/pod/Perl::Tidy). A `.perltidyrc`
file at the project root captures the team's formatting preferences.

Example `.perltidyrc`:

```
-nst     # don't output to STDOUT
-l=100   # max line length
-i=2     # 2-space indent
-ci=2    # continuation indent
-ce      # cuddled elses
-bt=1    # brace tightness
-pt=1    # parenthesis tightness
```

Notable flags:

| Flag | Meaning |
|---|---|
| `-i=N` | Set indent level to N columns |
| `-l=N` | Maximum line length |
| `-ci=N` | Continuation indent |
| `-ce` | Cuddled elses |
| `-nce` | Uncuddled elses |
| `-bt=N` | Brace tightness (0=always space, 2=never space) |
| `-pt=N` | Parenthesis tightness |
| `-sbt=N` | Square bracket tightness |

Do not use `-pbp` as a base. Its defaults (4-space indent, uncuddled elses) conflict
with this project's conventions.

---

## 3. Pragmas and Strictures

### The Non-Negotiable Three

Every Perl file must begin with these pragmas:

```perl
use strict;
use warnings;
use utf8;
```

- **`use strict`** -- catches misspelled variable names, enforces `my`/`our`/`local`
  declarations, prohibits bareword strings, and restricts symbolic references.
- **`use warnings`** -- enables compile-time and runtime warnings for ambiguous or
  questionable constructs. Prefer `use warnings` over the `-w` flag; the pragma is
  lexically scoped while `-w` is global and only applies to the main script.
- **`use utf8`** -- declares that the source file itself is encoded in UTF-8, allowing
  non-ASCII characters in string literals and identifiers. Note that `use utf8` affects
  source encoding only, not I/O. See the UTF-8 I/O section below.

### UTF-8 I/O

`use utf8` does not change how filehandles read or write data. Code that outputs Unicode
(test output, formatted ages in non-Latin scripts) needs explicit encoding on the output
layer:

```perl
binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';
```

Or when opening files:

```perl
open(my $fh, '>:encoding(UTF-8)', $filename)
  or croak "Cannot open '$filename': $!";
```

In test files, `Test::More` output goes through STDOUT. Set `binmode` at the top of the
test file to avoid "Wide character in print" warnings.

### Minimum Version

This project uses the explicit three-pragma form (`use strict; use warnings; use utf8`)
for broad compatibility. On Perl 5.36+, `use v5.36` enables `strict` and `warnings`
automatically, but it does not enable `utf8` -- you would still need `use utf8` separately.
Since the three-pragma form works on all Perl versions the project supports and is only
one line longer, prefer it for consistency.

### Additional Pragmas

| Pragma | Purpose | When to use |
|---|---|---|
| `use Carp` | `carp`, `croak`, `confess` | In modules (reports errors from caller's perspective) |
| `use Exporter` | Symbol export | When a module provides importable functions |
| `use constant` | Compile-time constants | For values that benefit from compile-time inlining |
| `use feature 'say'` | `say` function (print + newline) | Perl 5.10+ |
| `use feature 'state'` | `state` variables | Perl 5.10+ |
| `no feature 'indirect'` | Disable indirect object syntax | Perl 5.32+ |

### Pragma Placement

Pragmas go at the very top of the file, before the `package` declaration:

```perl
use strict;
use warnings;
use utf8;

package SayableAge::Formatter;

use Time::Local qw(timegm);
use SayableAge::Locale;
```

Module imports (`use SomeModule`) come after the `package` declaration.

---

## 4. Module Design

### Package Structure

One primary package per file. The file path mirrors the package name:

```
lib/
  SayableAge.pm                    # package SayableAge
  SayableAge/
    Formatter.pm                   # package SayableAge::Formatter
    Locale.pm                      # package SayableAge::Locale
    Locales/
      EN.pm                        # package SayableAge::Locales::EN
```

Every module file must end with a true value:

```perl
1;
```

### Exporter

Use `Exporter` to provide importable symbols. Prefer explicit export lists over
`@EXPORT` (which pollutes the caller's namespace by default):

```perl
package SayableAge::Locale;

use Exporter 'import';
our @EXPORT_OK = qw(resolve_unit resolve_stage);
```

Callers then import explicitly:

```perl
use SayableAge::Locale qw(resolve_unit);
```

Avoid `@EXPORT` (auto-imports everything). Use `@EXPORT_OK` (caller must ask for each
symbol) or `%EXPORT_TAGS` (named groups):

```perl
our %EXPORT_TAGS = (
  all => [qw(resolve_unit resolve_stage)],
);
our @EXPORT_OK = @{ $EXPORT_TAGS{all} };
```

### Object-Oriented Design

This project uses `bless`-based OO exclusively. It is the simplest approach, requires
zero dependencies, and is appropriate for lightweight value objects and formatters.

For projects that allow dependencies, `Moo` provides declarative OO with attribute
definitions and type checking. It is not applicable here.

#### Constructor

```perl
sub new {
  my ($class, %args) = @_;
  my $self = bless {
    name => $args{name},
    value => $args{value} // 0,
  }, $class;
  return $self;
}
```

Accept `$class` as the first argument to support subclassing. Always use `->new()`
(direct method call), never `new Class` (indirect object notation).

#### Accessors

Objects in this project are immutable after construction. Write read-only accessor methods
rather than exposing hash slots directly:

```perl
# Good: read-only accessor
sub locale { return $_[0]->{locale} }

# Bad: direct slot access from outside the class
$formatter->{locale}
```

Do not write read-write accessors unless mutation is specifically required by the design.

### POD Documentation

Document every public module with POD (Plain Old Documentation). The standard sections
in order:

```perl
=head1 NAME

SayableAge::Formatter - Human-friendly age formatting

=head1 SYNOPSIS

    use SayableAge::Formatter;
    my $fmt = SayableAge::Formatter->new($locale);
    my $age = $fmt->format_age('2020-01-15', '2024-06-20');

=head1 DESCRIPTION

Formats ages the way parents talk: "6 weeks", "14 months", "3 1/2 years".

=head1 METHODS

=head2 new($locale, %opts)

Creates a new formatter for the given locale.

=head2 format_age($date_of_birth, $as_of)

Returns a human-readable age string.

=head1 AUTHOR

Your Name <email@example.com>

=head1 LICENSE

See LICENSE.md

=cut
```

Formatting codes for POD:

| Code | Purpose | Example |
|---|---|---|
| `C<>` | Code (function, variable, module) | `C<format_age()>` |
| `B<>` | Bold (commands, emphasis) | `B<perltidy>` |
| `I<>` | Italic (filenames, terms) | `I<perlstyle>` |
| `L<>` | Link | `L<perlstyle>`, `L<Some::Module>` |
| `F<>` | Filename | `F<.perltidyrc>` |

Place POD near the code it documents. For subroutine documentation, put the POD directly
above the subroutine definition to keep them in sync.

---

## 5. Data Structures

### Scalars, Arrays, Hashes

Perl's three basic variable types are distinguished by sigil:

```perl
my $scalar = 42;           # scalar
my @array  = (1, 2, 3);    # array
my %hash   = (a => 1, b => 2);  # hash
```

Access individual elements with the `$` sigil (you are extracting a single scalar):

```perl
$array[0]       # first element of @array
$hash{name}     # value for key 'name' in %hash
$array[-1]      # last element (not $array[$#array])
```

Get the length of an array in scalar context:

```perl
my $len = scalar @array;   # explicit
my $len = @array;          # implicit (scalar context from assignment)
```

Do not use `$#array + 1` for length. Do not use `@array[$idx]` for a single element
(that creates a slice).

### References

References are scalars that point to other data structures. Use the backslash operator
or anonymous constructors:

```perl
my $array_ref = \@array;           # reference to existing array
my $hash_ref  = \%hash;            # reference to existing hash
my $code_ref  = \&some_function;   # reference to subroutine

my $anon_array = [1, 2, 3];       # anonymous array reference
my $anon_hash  = { a => 1 };      # anonymous hash reference
my $anon_sub   = sub { ... };     # anonymous subroutine reference
```

Dereference with the arrow operator:

```perl
$array_ref->[0]          # element of array ref
$hash_ref->{name}        # value from hash ref
$code_ref->(@args)       # call code ref
```

Do not use the `$$ref[0]` or `$$ref{key}` forms -- the arrow notation is clearer and
less error-prone.

### Complex Data Structures

Build complex structures with nested references:

```perl
my $locale = {
  code => 'en',
  units => {
    day => { one => '{n} day', other => '{n} days' },
    week => { one => '{n} week', other => '{n} weeks' },
  },
  plural => sub {
    my ($n) = @_;
    return $n == 1 ? 'one' : 'other';
  },
};
```

Access nested values with chained arrows:

```perl
my $form = $locale->{units}{day}{one};
my $cat  = $locale->{plural}->(5);
```

### Passing Complex Data to Subroutines

Always pass arrays and hashes by reference to avoid flattening:

```perl
# Good
sub process {
  my ($array_ref, $hash_ref) = @_;
  for my $item (@{$array_ref}) { ... }
}
process(\@items, \%config);

# Bad: arrays flatten into a single list
sub process {
  my (@items, %config) = @_;   # %config will be empty!
}
```

### Subroutine Argument Unpacking

Use list assignment from `@_` as the standard pattern for unpacking arguments:

```perl
sub format_age {
  my ($self, $date_of_birth, $as_of) = @_;
  ...
}
```

Do not use `shift` for argument unpacking unless there is a specific reason (e.g., a
read-write accessor that checks `@_` after extracting `$self`). The list assignment form
is non-destructive, explicit about expected parameters, and consistent across the codebase.

### Slices

Use slices to extract multiple elements at once:

```perl
my @subset = @array[0, 2, 4];            # array slice
my @values = @hash{qw(name age city)};   # hash slice
```

Note the `@` sigil -- slices return lists, so use `@`, not `$`.

---

## 6. Error Handling

### die and croak

`die` raises an exception. In modules, prefer `croak` from the `Carp` module, which
reports the error from the caller's perspective rather than the module's:

```perl
use Carp qw(croak carp);

sub new {
  my ($class, %args) = @_;
  croak 'locale is required' unless $args{locale};
  ...
}
```

| Function | Behavior |
|---|---|
| `die "msg"` | Reports error at the current file/line |
| `croak "msg"` | Reports error at the caller's file/line |
| `warn "msg"` | Prints warning at the current file/line |
| `carp "msg"` | Prints warning at the caller's file/line |
| `confess "msg"` | Like `croak` but includes a full stack trace |
| `cluck "msg"` | Like `carp` but includes a full stack trace |

### Error Messages

Good error messages include:

1. What operation failed
2. What the arguments were
3. The system error (`$!`) for system calls

```perl
open my $fh, '<', $filename
  or croak "Cannot open '$filename' for reading: $!";
```

### eval for Exception Handling

Catch exceptions with `eval { }` blocks. Capture `$@` immediately after the `eval`
block, before any other statement can clobber it:

```perl
my $result = eval {
  potentially_dangerous_operation();
  1;    # true on success
};
my $error = $@;    # capture immediately -- $@ can be clobbered by destructors
if (!$result) {
  # handle $error
}
```

The `1;` return value pattern is important: checking the return value of `eval` is more
reliable than testing `$@` directly, because `$@` can be overwritten by destructors or
intermediate `eval` calls between the `eval` block and the check. By capturing `$@` on
the very next line, before the conditional, you minimize the clobber window.

### Return Values for Expected Failures

For operations that can legitimately fail (like parsing optional input), return a value
that signals the failure:

```perl
sub _parse_age {
  my ($date_of_birth, $as_of) = @_;
  return undef unless defined $date_of_birth && $date_of_birth ne '';
  ...
}
```

In this project, functions that return failure use `return undef` and are always called in
scalar context. This is safe and explicit.

Be aware of the tradeoff: `return undef` in list context returns a one-element list
`(undef)`, which is true in boolean context. Bare `return` returns an empty list in list
context, which is false. Since this project's functions are called in scalar context, this
distinction does not apply, but `Perl::Critic`'s `ProhibitExplicitReturnUndef` policy
(severity 5) will flag `return undef` by default. Disable this policy in `.perlcriticrc`
with a comment explaining that all affected functions are scalar-context-only:

```ini
[-Perl::Critic::Policy::Subroutines::ProhibitExplicitReturnUndef]
```

### Error Propagation

In module code, let exceptions propagate upward unless you can genuinely handle them.
Do not silently swallow errors:

```perl
# Bad: silently ignores errors
eval { dangerous(); };

# Good: re-raise with context
eval { dangerous() };
my $error = $@;
if ($error) {
  croak "Failed during initialization: $error";
}
```

---

## 7. Regular Expressions

### Use /x for Readability

The `/x` modifier allows whitespace and comments inside a regex. Use it for anything
beyond trivial patterns:

```perl
# Without /x -- dense and hard to read
my @parts = split(/(\d{4})-(\d{2})-(\d{2})/, $date);

# With /x -- self-documenting
my $date_re = qr{
  (\d{4})   # year
  -
  (\d{2})   # month
  -
  (\d{2})   # day
}x;
```

Perl 5.26+ offers `/xx`, which also allows spaces inside character classes.

### Named Captures

Prefer named captures over numbered ones for anything non-trivial:

```perl
if ($date =~ m{
  (?<year>  \d{4} )
  -
  (?<month> \d{2} )
  -
  (?<day>   \d{2} )
}x) {
  my $year  = $+{year};
  my $month = $+{month};
  my $day   = $+{day};
}
```

Named captures live in the `%+` hash. They eliminate the fragility of numbered groups
(`$1`, `$2`) shifting when the pattern is modified.

### Non-Capturing Groups

When you need grouping for alternation or quantification but do not need the captured
value, use `(?:...)`:

```perl
# Capturing (unnecessary)
if ($str =~ /(foo|bar)baz/) { ... }

# Non-capturing (better when you don't need $1)
if ($str =~ /(?:foo|bar)baz/) { ... }
```

### Compiled Regexes with qr//

Pre-compile patterns with `qr//` when reusing them or building them from parts:

```perl
my $word_re = qr/[A-Za-z]+/;
my $line_re = qr/^ $word_re \s+ \d+ $/x;

if ($line =~ $line_re) { ... }
```

### String Anchors

Use `\A` and `\z` for start and end of string, not `^` and `$`. The caret and dollar
change meaning with `/m` (multiline mode), while `\A` and `\z` always mean start and
end of the entire string:

```perl
# Fragile: depends on absence of /m
if ($input =~ /^valid$/) { ... }

# Robust: unambiguous
if ($input =~ /\Avalid\z/) { ... }
```

### Escaping User Input

When interpolating variables into regexes, use `\Q...\E` or `quotemeta()` to escape
metacharacters:

```perl
my $literal = quotemeta($user_input);
if ($string =~ /$literal/) { ... }

# Or inline
if ($string =~ /\Q$user_input\E/) { ... }
```

### Always Check Match Success

Never use capture variables (`$1`, `$+{name}`) without first confirming the match
succeeded:

```perl
# Bad: $1 may hold a value from a previous match
$string =~ /(\d+)/;
my $num = $1;

# Good: check match result
if ($string =~ /(\d+)/) {
  my $num = $1;
}
```

---

## 8. String Handling

### Interpolation

Double-quoted strings interpolate variables and escape sequences. Single-quoted strings
are literal:

```perl
my $name = "world";
my $msg  = "Hello, $name!\n";    # interpolation
my $raw  = 'Hello, $name!\n';    # literal: $name and \n are not expanded
```

Do not wrap a variable in unnecessary double quotes:

```perl
# Bad: pointless interpolation
print "$name";

# Good: direct
print $name;
```

Disambiguate variable names in interpolation with braces:

```perl
my $result = "${prefix}_suffix";   # clear boundary
```

### q// and qq//

Use `q{}` and `qq{}` as alternatives to single and double quotes, especially when the
string contains quote characters:

```perl
my $sql   = q{SELECT * FROM users WHERE name = 'O''Brien'};
my $html  = qq{<div class="item">$label</div>};
my $regex = qr{^\d{4}-\d{2}-\d{2}$};
```

Any paired delimiter works: `q()`, `q[]`, `q<>`, `q{}`, `q!!`, etc.

### Heredocs

Use heredocs for multi-line strings. Prefer single-quoted heredocs (`<<'END'`) when no
interpolation is needed:

```perl
my $template = <<'END';
This is a literal string.
No $interpolation or \n expansion happens here.
END

my $message = <<"END";
Hello, $name!
You have $count items.
END
```

**Indented heredocs** (`<<~`) strip leading whitespace, keeping source code neatly
indented (Perl 5.26+):

```perl
sub usage {
  return <<~'END';
    Usage: program [options]
    Options:
        --help    Show this message
        --verbose Enable verbose output
    END
}
```

### String Repetition

Use the `x` operator for repetition:

```perl
my $separator = '-' x 40;
my $padding   = ' ' x $indent_level;
```

---

## 9. Common Idioms

### map, grep, sort

Use `map` to transform lists, `grep` to filter, and `sort` to order:

```perl
my @names   = map  { $_->{name} } @records;
my @adults  = grep { $_->{age} >= 18 } @people;
my @sorted  = sort { $a->{name} cmp $b->{name} } @items;
```

Guidelines:

- Use `map` and `grep` only when you need the resulting list. For side effects, use
  `for`/`foreach`.
- Keep the block short. If the transformation is complex, extract it into a named
  subroutine.
- For simple transformations, the expression form is fine: `map { lc } @words`.

### The Ternary Operator

Use `?:` for simple conditional expressions:

```perl
my $label = $count == 1 ? 'item' : 'items';
```

Do not nest ternaries deeply -- use `if`/`elsif` instead. Do not use ternaries for
side effects (assignments inside branches):

```perl
# Bad: side effects in ternary
$cond ? ($x = 1) : ($x = 2);

# Good: straightforward
$x = $cond ? 1 : 2;
```

### Statement Modifiers (unless, until, if, while)

Perl allows postfix control flow for single statements:

```perl
return undef unless defined $input;
print "Starting\n" if $verbose;
$count++ while <$fh>;
```

Use statement modifiers when the action is the main point and the condition is a guard.
Do not use them when the condition is the main logic:

```perl
# Good: the return is the main point, guard is secondary
return $cached if defined $cached;

# Bad: the open is the main point, hiding it in a modifier obscures it
die "Cannot open: $!" unless open(my $fh, '<', $file);

# Good: open is prominent
open(my $fh, '<', $file) or die "Cannot open '$file': $!";
```

**`unless` rules:**

- `unless` is acceptable as a postfix modifier for simple guard clauses:
  `return undef unless defined $x;`
- `unless` blocks (`unless (...) { ... }`) should be rewritten as `if (!...)` for clarity.
- Never use `unless` with `elsif` or with compound conditions -- the double negation is
  too hard to reason about:

```perl
# Bad: double-negation
unless (!$valid || $expired) { ... }

# Good: positive logic
if ($valid && !$expired) { ... }
```

### The // (Defined-Or) Operator

Use `//` (Perl 5.10+) to provide defaults for potentially undefined values:

```perl
my $name = $opts{name} // 'default';
```

This is preferable to `||` because `||` also treats `0` and `''` as false:

```perl
my $count = $opts{count} || 10;   # Bug: $opts{count} = 0 gives 10
my $count = $opts{count} // 10;   # Correct: 0 stays 0
```

### Context Sensitivity

Perl expressions behave differently in scalar vs. list context. Functions should have
a single, predictable return type. Do not use `wantarray` to change return behavior
based on calling context -- it makes functions unpredictable and has been deprecated
in recent Perl versions.

### Boolean Idioms

Perl has no boolean type. False values are: `undef`, `''` (empty string), `0`, and `'0'`.
Everything else is true.

```perl
# Idiomatic boolean checks
if ($value)          { ... }   # true
if (!$value)         { ... }   # false
if (defined $value)  { ... }   # not undef (but could be 0 or '')
if (length $value)   { ... }   # defined and non-empty string
```

---

## 10. Things to Avoid

### Two-Argument open

The two-argument form of `open` is a security vulnerability. The filename is parsed for
shell metacharacters, enabling command injection:

```perl
# DANGEROUS: two-arg open
open(FH, $filename);              # $filename = "| rm -rf /" works!
open(FH, ">$filename");           # shell metacharacters in $filename

# SAFE: three-arg open with lexical filehandle
open(my $fh, '<', $filename) or die "Cannot open '$filename': $!";
open(my $fh, '>', $output)   or die "Cannot write '$output': $!";
```

Always use three-argument `open` with a lexical filehandle.

### Bareword Filehandles

Bareword filehandles (`STDIN`, `STDOUT`, `STDERR` excepted) are package globals that
cannot be passed to subroutines, managed with garbage collection, or scoped lexically:

```perl
# Bad: bareword filehandle
open(INPUT, '<', $file) or die $!;
print INPUT "data";

# Good: lexical filehandle
open(my $fh, '<', $file) or die "Cannot open '$file': $!";
print {$fh} "data";
```

When printing to a filehandle stored in a variable, use braces to disambiguate for
human readers:

```perl
print {$fh} "output\n";    # clear to the reader
print $fh "output\n";      # works, but looks like $fh is a string argument
```

When a trailing newline is desired, prefer `say` (requires `use feature 'say'` or
Perl 5.10+):

```perl
say {$fh} "output";        # prints "output\n"
```

### Indirect Object Notation

The indirect syntax `new Class(@args)` is ambiguous and was removed from Perl 5.36+:

```perl
# Bad: indirect object notation
my $obj = new SayableAge::Formatter($locale);

# Good: direct method call
my $obj = SayableAge::Formatter->new($locale);
```

On Perl 5.32+, explicitly disable it:

```perl
no feature 'indirect';
```

### Overuse of $_

The default variable `$_` is convenient in short pipelines but obscure in longer code.
Use named variables:

```perl
# Acceptable: short, obvious pipeline
my @upper = map { uc } @words;

# Bad: $_ in nested or long blocks
for (@records) {
  for (@{$_->{items}}) {
    process($_);      # which $_ ?
  }
}

# Good: explicit variables
for my $record (@records) {
  for my $item (@{$record->{items}}) {
    process($item);
  }
}
```

### Subroutine Prototypes

Prototypes do not validate argument types; they change how Perl parses function calls.
They are a source of subtle bugs:

```perl
# Bad: prototype does not do what it looks like
sub add ($$) { return $_[0] + $_[1]; }

# Good: no prototype, manual unpacking
sub add {
  my ($x, $y) = @_;
  return $x + $y;
}
```

The only legitimate uses of prototypes are: overriding builtins, creating compile-time
constants (`sub PI () { 3.14159 }`), and the `($$)` prototype for custom sort comparators.

### Ampersand-Prefixed Calls

Calling subroutines with `&` disables prototype checking and, when used without
parentheses, passes the current `@_` to the called function. This is almost never what
you want:

```perl
# Bad
&my_function(@args);

# Good
my_function(@args);
```

### Symbolic References

Using a variable's value as a variable name (`$$varname`) is fragile and dangerous.
`use strict 'refs'` (included in `use strict`) prohibits it:

```perl
# Bad: symbolic reference
my $name = 'count';
$$name = 42;            # sets $count = 42

# Good: use a hash
my %data;
$data{count} = 42;
```

### chop vs. chomp

`chop` removes the last character unconditionally. `chomp` removes only a trailing
record separator (newline by default). Almost always use `chomp`:

```perl
# Bad
chop $line;     # removes last char even if not a newline

# Good
chomp $line;    # removes trailing newline only
```

### map and grep in Void Context

Using `map` or `grep` purely for side effects wastes memory building a list that is
discarded. Use `for`/`foreach` instead:

```perl
# Bad: builds and discards a list
map { print "$_\n" } @items;

# Good: no wasted list
for my $item (@items) {
  print "$item\n";
}
```

### Backticks in Void Context

Backticks capture command output. If you do not need the output, use `system`:

```perl
# Bad: captures output you never use
`rm -f $tempfile`;

# Good: uses system for side effects
system('rm', '-f', $tempfile);

# Better: use Perl's own file operations
unlink $tempfile;
```

### Global Variables

Avoid modifying Perl's special global variables (`$/`, `$\`, `$,`, etc.) without
localizing them:

```perl
# Bad: changes $/ globally
$/ = undef;
my $content = <$fh>;

# Good: localize the change
my $content = do {
  local $/;
  <$fh>;
};
```

### foreach on File Lines

Reading a file with `foreach` loads the entire file into memory:

```perl
# Bad: slurps entire file
foreach my $line (<$fh>) { ... }

# Good: reads line by line
while (my $line = <$fh>) { ... }
```

---

## 11. Tooling

### Perl::Critic

[Perl::Critic](https://metacpan.org/pod/Perl::Critic) is a static analysis tool that
checks code against policies derived from *Perl Best Practices* and community standards.

**Severity levels** (1 = most pedantic, 5 = most critical):

| Level | Name | Focus |
|---|---|---|
| 5 | gentle | Critical issues only |
| 4 | stern | Important style violations |
| 3 | harsh | Moderate violations |
| 2 | cruel | Minor violations |
| 1 | brutal | Everything, including cosmetic |

Start at severity 5 and gradually lower the threshold as the codebase matures.

**Configuration** via `.perlcriticrc`:

```ini
severity = 3
verbose  = %f:%l:%c: %m (%p, severity %s)\n

# This project uses return undef in scalar-context-only functions
[-Perl::Critic::Policy::Subroutines::ProhibitExplicitReturnUndef]

[Perl::Critic::Policy::ControlStructures::ProhibitPostfixControls]
severity = 2
allow = if unless

[Perl::Critic::Policy::ValuesAndExpressions::ProhibitMagicNumbers]
allowed_values = 0 1 2 -1

[-Perl::Critic::Policy::Documentation::RequirePodSections]
```

Prefix a policy with `-` to disable it entirely. When disabling a policy, include a
comment explaining why.

**Inline suppression** (use sparingly, with justification):

```perl
## no critic (ProhibitMagicNumbers)
my @days = (0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
## use critic
```

**Key policy categories:**

| Category | Notable Policies |
|---|---|
| TestingAndDebugging | `RequireUseStrict`, `RequireUseWarnings` |
| NamingConventions | `Capitalization` |
| ControlStructures | `ProhibitPostfixControls`, `ProhibitUnlessBlocks` |
| Subroutines | `ProhibitExcessComplexity`, `RequireFinalReturn` |
| ValuesAndExpressions | `ProhibitMagicNumbers`, `ProhibitEmptyQuotes` |
| InputOutput | `ProhibitTwoArgOpen`, `ProhibitBarewordFileHandles` |
| Documentation | `RequirePodSections` |

### Perl::Tidy

[Perl::Tidy](https://metacpan.org/pod/Perl::Tidy) is the standard code formatter.
Run it from the command line:

```bash
perltidy script.pl                   # format (output to script.pl.tdy)
perltidy -b script.pl                # format in-place (backup to .bak)
perltidy -pro=.perltidyrc script.pl  # use project config
```

Integrate into CI to enforce consistent formatting across contributors.

### perlbrew / plenv

[perlbrew](https://perlbrew.pl/) manages multiple Perl installations without root access:

```bash
perlbrew install perl-5.38.2
perlbrew switch perl-5.38.2
perlbrew list
```

[plenv](https://github.com/tokuhirom/plenv) is a lighter alternative inspired by rbenv.

Both allow testing against multiple Perl versions in CI.

### cpanm (App::cpanminus)

[cpanm](https://metacpan.org/pod/App::cpanminus) is the standard CPAN module installer:

```bash
cpanm Module::Name
cpanm --installdeps .            # install dependencies from Makefile.PL/cpanfile
cpanm -n Module::Name            # skip tests
cpanm -l local Module::Name      # install to local/ directory
```

Use a `cpanfile` to declare project dependencies:

```perl
requires 'Test::More', '0.98';
requires 'Time::Local';

on 'test' => sub {
  requires 'Test::Deep';
};
```

### prove

[prove](https://perldoc.perl.org/prove) is the standard test runner:

```bash
prove                      # run all tests in t/
prove -v                   # verbose output
prove -l t/formatter.t     # run one test, add lib/ to @INC
prove -j4                  # run 4 tests in parallel
prove --state=failed       # re-run only previously failed tests
```

### perldoc

Access Perl's built-in documentation:

```bash
perldoc perlstyle          # style guide
perldoc perlmodstyle       # module design
perldoc perlre             # regular expressions
perldoc perlsub            # subroutines
perldoc perltrap           # common traps
perldoc -f open            # documentation for a function
perldoc -v '$_'            # documentation for a variable
```

---

## Sources

### Official Perl Documentation (perldoc)

- [perlstyle](https://perldoc.perl.org/perlstyle) -- Perl style guide
- [perlmodstyle](https://perldoc.perl.org/perlmodstyle) -- Perl module style guide
- [perlsub](https://perldoc.perl.org/perlsub) -- Perl subroutines
- [perlre](https://perldoc.perl.org/perlre) -- Perl regular expressions
- [perlop](https://perldoc.perl.org/perlop) -- Perl operators (string quoting, heredocs)
- [perltrap](https://perldoc.perl.org/perltrap) -- Perl traps for the unwary
- [perlobj](https://perldoc.perl.org/perlobj) -- Perl object reference
- [perlopentut](https://perldoc.perl.org/perlopentut) -- Perl open tutorial
- [perlunitut](https://perldoc.perl.org/perlunitut) -- Perl Unicode tutorial

### Books

- [Modern Perl](https://www.modernperlbooks.com/books/modern_perl/) by chromatic -- free online book covering contemporary Perl idioms. See especially [Chapter 11: What to Avoid](https://www.modernperlbooks.com/books/modern_perl/chapter_11.html)

### CPAN Modules and Tools

- [Perl::Critic](https://metacpan.org/pod/Perl::Critic) -- static code analysis
- [Perl::Tidy](https://metacpan.org/pod/Perl::Tidy) -- code formatter
- [Perl::Critic::Policies](https://metacpan.org/release/Perl-Critic) -- complete policy list
- [App::cpanminus](https://metacpan.org/pod/App::cpanminus) -- CPAN installer

### Community Resources

- [Perl Elements to Avoid](https://perl-begin.org/tutorials/bad-elements/) -- comprehensive anti-pattern catalog
- [Turn off indirect object notation](https://www.effectiveperlprogramming.com/2020/06/turn-off-indirect-object-notation/) -- Effective Perl Programming
- [CERT Perl Coding Standard](https://wiki.sei.cmu.edu/confluence/display/perl/) -- security-focused coding rules
- [perlbrew](https://perlbrew.pl/) -- Perl version manager
- [MetaCPAN](https://metacpan.org/) -- CPAN search engine
