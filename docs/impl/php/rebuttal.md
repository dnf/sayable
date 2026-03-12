# PHP Style Guide -- Senior Engineering Review

Reviewer context: This review evaluates the PHP style guide at `docs/impl/php/README.md` against the actual codebase (`age/impl/php/`), PHP ecosystem norms, and practical engineering trade-offs. The guide is mostly solid. The issues below range from technically incorrect to unnecessarily dogmatic.

---

## 1. Compound Namespace Depth Limit Is Fabricated

**Quoted guideline (Section 5):**

> Compound namespaces are allowed but limited to two sub-namespace levels:
>
> ```php
> // Not allowed -- too deep
> use Vendor\Package\Namespace\{
>     SubOne\SubTwo\ClassA,
>     SubOne\ClassB,
> };
> ```

**Why this is problematic:**

PER Coding Style 2.0 had a "depth of two" rule for compound namespace groups. PER Coding Style 3.0 -- which this guide claims to follow -- dropped it entirely. The current PER spec says only that compound use declarations "MAY be used" and that each import should be on its own line within the group. There is no depth restriction.

The example shown as "not allowed" is perfectly valid PHP and perfectly valid PER 3.0. A guide that prohibits legal, standards-compliant code based on an obsolete spec revision creates false negatives in code review. Engineers will waste time restructuring imports that are already fine.

**Recommendation:** Remove the depth restriction. State that compound use declarations are permitted, and that each import should appear on its own line within the group. If the team wants to limit depth for readability, frame it as a project preference, not a standards requirement.

---

## 2. "Never Use `strlen`, `substr`, `strpos` on Multibyte Strings" Is Overbroad

**Quoted guideline (Section 8):**

> Use `mb_*` functions for Unicode-safe string operations. Never use `strlen`, `substr`, `strpos` on strings that may contain multibyte characters.

**Why this is problematic:**

This conflates byte operations with character operations, which are different tools for different jobs. The actual codebase uses `strlen` and `substr` correctly in `SayableAge::parseDateParts()`:

```php
if (\strlen($s) < 10 || $s[4] !== '-' || $s[7] !== '-') {
    return null;
}
$y = (int) \substr($s, 0, 4);
```

This is parsing a fixed-format ASCII date string (`YYYY-MM-DD`). Using `mb_strlen` here would be slower and semantically wrong -- the code is checking byte positions, not character positions. The byte-level functions are the correct choice.

`strlen` returns byte count. `mb_strlen` returns character count. These are different questions with different correct answers. A blanket "never use `strlen`" rule would flag correct code as violations. In practice:

- Protocol parsing, binary formats, ASCII-only data: use `strlen`/`substr`
- User-facing text display, truncation, search: use `mb_strlen`/`mb_substr`

**Recommendation:** Replace the blanket prohibition with guidance that distinguishes byte operations from character operations. Explain when each is appropriate. The rule should be "use `mb_*` for character-level operations on user-facing text; use `strlen`/`substr` for byte-level operations on known-encoding data."

---

## 3. Recommending Both phpcs and PHP-CS-Fixer Without a Decision Framework

**Quoted guideline (Section 11):**

> | Purpose         | Tool                  |
> | --------------- | --------------------- |
> | Code formatting | PHP-CS-Fixer or phpcs |

**Why this is problematic:**

Listing both tools with "or" is non-guidance. These tools have overlapping but different capabilities, different configuration formats, and different philosophies. Running both simultaneously causes conflicts -- phpcs may flag code that PHP-CS-Fixer just formatted as correct, and vice versa. The actual project uses PHP-CS-Fixer (per `composer.json`), making this a solved decision.

Furthermore, the guide provides configuration examples for both tools in separate subsections without explaining when you would choose one over the other. An engineer reading this guide cannot determine which to adopt.

**Recommendation:** State that the project uses PHP-CS-Fixer with the `@PER-CS` ruleset. Mention phpcs as an alternative for teams that prefer a linting-only approach (check without auto-fix), but make it clear that you should not run both on the same codebase without careful rule alignment.

---

## 4. PHPStan Level Recommendation Undersells the Project's Own Standard

**Quoted guideline (Section 11):**

> Recommended: start at level 5 or 6, work toward `max`.

**Why this is problematic:**

The project's own `phpstan.neon` runs at level 9 (one below `max`). Recommending level 5 or 6 as a starting point in a style guide for this project sends a contradictory signal. New code written against this guide could reasonably target level 5 and pass the guide's criteria while failing the project's actual CI.

The phrasing "work toward max" is also vague. There is no actionable threshold or timeline, making it effectively optional.

**Recommendation:** State the project's minimum PHPStan level (currently 9). The "start at 5, work toward max" advice is reasonable for greenfield projects, so frame it that way -- but make the project's own bar explicit and non-negotiable.

---

## 5. `match(true)` Is Presented Without Caveats

**Quoted guideline (Section 9):**

> Use `match(true)` for condition-based branching:
>
> ```php
> $stage = match (true) {
>     $days < 14  => 'newborn',
>     $days < 91  => 'weeks',
>     $days < 548 => 'months',
>     default     => 'years',
> };
> ```

**Why this is problematic:**

`match(true)` is a useful idiom, but the guide presents it without its most important behavioral distinction from `if/elseif`: `match` throws `UnhandledMatchError` if no arm matches and there is no `default`. For `match($value)` on an enum, that exhaustiveness check is a feature. For `match(true)` on arbitrary boolean conditions, an omitted `default` is a runtime bomb.

The example happens to include `default`, but the guide never calls out that `match(true)` without `default` will throw. Since this is a pattern the guide actively recommends, it should spell out the footgun.

**Recommendation:** Add a note that `match(true)` should always include a `default` arm, because unlike `if/elseif` (which simply falls through), an unmatched `match` throws `UnhandledMatchError`.

---

## 6. Fibers Section Is Irrelevant Filler

**Quoted guideline (Section 9):**

> ### Fibers (PHP 8.1+)
>
> Cooperative multitasking primitive. Use when building async frameworks or coroutines. For application code, prefer higher-level abstractions.

**Why this is problematic:**

This is a style guide for a zero-dependency, synchronous formatting library. Fibers are an async concurrency primitive. No one auditing this codebase's PHP implementation will need guidance on Fibers. Including them adds noise and dilutes the signal of sections that actually apply.

The guide's own preamble says it is "a comprehensive reference for auditing PHP implementations." Fibers are not relevant to auditing this implementation.

**Recommendation:** Remove the Fibers section entirely. If the guide is intended to be a general-purpose PHP style reference beyond this project, move Fibers to an appendix or advanced topics section with a clear note that it is outside the scope of typical application code.

---

## 7. Missing Guidance on Function-Scoped Static Variables

**What's missing:**

The codebase uses function-scoped `static` variables in `functions.php`:

```php
function formatAge(?string $dateOfBirth, ?string $asOf = null): ?string
{
    static $default = null;
    $default ??= new SayableAge(Locales::EN());
    return $default->formatAge($dateOfBirth, $asOf);
}
```

This is a legitimate PHP pattern for memoization in stateless function contexts. The style guide says nothing about `static` variables in function scope, when they are appropriate, or their testing implications (they persist across calls within a request, which can cause test pollution if not handled carefully).

**Recommendation:** Add a brief subsection on function-scoped `static` variables. Cover when they are appropriate (lazy singletons in convenience functions), their lifetime (per-request in FPM, per-process in CLI), and the testing implications (state persists across test cases unless the process is restarted).

---

## 8. Leading Backslash on Global Functions Is Unaddressed

**What's missing:**

The codebase consistently uses leading backslashes on global PHP functions:

```php
\strlen($s)
\intdiv($diffDays, 7)
\str_contains($half, '{n}')
\date('Y')
```

This is a deliberate performance and correctness pattern. In a namespaced file, `strlen()` triggers a namespace-relative lookup first, then falls back to the global function. `\strlen()` goes directly to the global function, skipping the namespace lookup. This avoids a (minor) performance penalty and, more importantly, prevents accidental shadowing if someone defines a function with the same name in the namespace.

The style guide does not mention this convention. Since it is used consistently in the codebase, it should be documented.

**Recommendation:** Add guidance that global PHP functions should be called with a leading backslash in namespaced code (e.g., `\strlen()`, `\array_map()`). Explain the rationale: it prevents namespace-relative lookup overhead and eliminates the risk of accidental function shadowing.

---

## 9. Trait Guidance Oversimplifies and Contradicts Itself

**Quoted guideline (Section 4):**

> Use for horizontal code reuse across unrelated classes. Never for state that belongs in a base class.

**Why this is problematic:**

The example immediately below this guidance puts state in a trait:

```php
trait HasTimestamps
{
    private DateTimeInterface $createdAt;

    public function getCreatedAt(): DateTimeInterface
    {
        return $this->createdAt;
    }
}
```

The trait holds a `$createdAt` property -- that is state. The rule says "never for state that belongs in a base class," but the example demonstrates a trait carrying state. The distinction the guide is trying to draw ("state that belongs in a base class" vs. other state) is too subtle for a one-line rule without further elaboration.

**Recommendation:** Rewrite the trait guidance to be precise. Traits can carry state -- that is one of their legitimate uses. The actual anti-pattern is using traits as a substitute for inheritance when the classes share an is-a relationship, or piling unrelated behaviors into a single trait. Align the rule with the example, or change the example.

---

## 10. The `abstract protected static readonly` Example Is Invalid PHP

**Quoted guideline (Section 4):**

> ```php
> abstract protected static readonly int $value;
> ```

**Why this is problematic:**

This line does not compile. You cannot declare a property as both `abstract` and have a concrete type declaration in PHP. Properties cannot be abstract at all -- only methods can be abstract. Additionally, `static` and `readonly` on the same property is not allowed (readonly properties cannot be static, per PHP 8.1+ rules). This is three errors in a single example line.

A style guide example that produces a fatal error undermines confidence in the entire document.

**Recommendation:** Replace this with a valid example that demonstrates modifier ordering on constructs where multiple modifiers actually apply. For example:

```php
final public static function create(): static {}
abstract protected function compute(): int;
public readonly string $name;
```

---

## 11. No Guidance on PHPDoc vs. Native Types

**What's missing:**

The codebase uses PHPDoc annotations alongside native types for cases where PHP's type system is insufficient:

```php
/** @var array<string, string>|string */
private readonly string|array $day;

/** @param Closure(int): PluralCategory $plural */
```

The style guide covers native type declarations thoroughly but says nothing about when to use PHPDoc `@var`, `@param`, `@return` annotations to supplement them. This is important because PHPStan and Psalm read these annotations for generic types, callable signatures, and array shapes that PHP's native type system cannot express.

**Recommendation:** Add a section on PHPDoc usage. The rule should be: use native types for everything PHP can express natively; use PHPDoc annotations to provide additional type information that static analyzers can use (generic arrays, callable signatures, array shapes, template types). Do not duplicate information that the native type already expresses -- e.g., do not write `@param int $count` when the parameter is already declared as `int`.

---

## 12. Single-Quoted String Preference Is Based on a Myth

**Quoted guideline (Section 8):**

> Use single-quoted strings when no interpolation is needed (marginal performance benefit, but mainly about intent).

**Why this is problematic:**

The parenthetical "marginal performance benefit" perpetuates a myth. PHP's lexer handles single and double-quoted strings with negligible performance difference -- the parser checks for `$` and `{` in double-quoted strings, but this is a trivial scan. No modern benchmark shows a measurable difference. Including this claim, even hedged as "marginal," gives it undeserved credibility and invites bikeshedding.

The "intent" argument is valid. The performance argument is not.

**Recommendation:** Drop the performance claim. Keep the intent argument: single-quoted strings signal "this string contains no interpolation," which is a useful readability signal for the next reader.

---

## Summary

The guide is well-structured and covers most of what matters. The issues above fall into three categories:

1. **Technically incorrect** (items 2, 10): examples that do not compile or rules that would flag correct code
2. **Missing guidance for patterns the codebase actually uses** (items 7, 8, 11): function-scoped statics, leading backslash conventions, PHPDoc supplementation
3. **Imprecise or misleading** (items 1, 3, 4, 5, 6, 9, 12): outdated spec references, non-decisions presented as guidance, irrelevant sections, myth-based reasoning

None of these are catastrophic. But a style guide that contains invalid code examples or contradicts the project's own configuration erodes trust in the document as a whole. Fix the errors, fill the gaps, and tighten the language.
