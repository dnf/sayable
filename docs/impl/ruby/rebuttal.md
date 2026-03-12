# Ruby Style Guide -- Senior Engineering Review

Reviewer role: Senior Staff Engineer
Date: 2026-03-11

---

## Summary

The guide is largely competent and covers the right surface area. However, it contains several guidelines that are either technically incorrect, internally contradictory, impractical for this project's constraints, or reflect cargo-culted conventions without sufficient critical analysis. Below are the specific disagreements, ordered roughly by severity.

---

## 1. Line Length: 80 Characters is an Anachronism Presented as "Community Standard"

**Quoted guideline:**

> Limit lines to **80 characters** (community standard). Some teams allow up to 120, but never exceed 120.

**Why this is problematic:**

The guide calls 80 characters the "community standard" and frames 120 as a concession. This is backwards. The canonical RuboCop Ruby Style Guide has defaulted to 80 for historical reasons, but the actual community has moved on. Shopify (cited by this very guide as a reference) uses 120. The project's own `.rubocop.yml` sets `Max: 120`. The guide contradicts the project's actual configuration.

More importantly, the 80-character limit creates real costs in Ruby specifically. Ruby's block syntax, chained method calls, keyword arguments, and hash literals routinely produce lines that are readable at 100-120 characters but become contorted when forced into 80. The guide's own examples (e.g., the multi-line `AgeLocale.new` call) demonstrate this -- they are broken across lines *because* of a limit the guide imposes, not because readability demands it.

**Recommended alternative:**

State 120 characters as the project standard. Acknowledge that 80 is a historical convention that some teams still use. Do not present 120 as a reluctant exception -- present it as the deliberate, considered choice it is.

---

## 2. Numbers in Identifiers: The Guideline is Backwards

**Quoted guideline:**

> Do not separate numbers from letters with underscores:
>
> ```ruby
> # Good
> some_var1
> level3_value
>
> # Bad
> some_var_1
> level_3_value
> ```

**Why this is problematic:**

This is wrong on readability grounds. `level3_value` visually smashes `3` and `value` together, making it harder to parse where the number ends and the next word begins. `level_3_value` has clear visual separation between all semantic components.

The RuboCop cop `Naming/VariableNumber` actually defaults to `snake_case` style (i.e., `level_3_value`), *not* the `normalcase` style this guide advocates. The guide's recommendation contradicts the tool it recommends enforcing it with.

Furthermore, in this project, test IDs like `29_1`, `29_2` appear throughout the test suite. Writing `test_29_1_he_just_born` is more readable than `test_291_he_just_born` would be.

**Recommended alternative:**

Use underscores to separate numbers from words in identifiers (`level_3_value`). This aligns with RuboCop defaults, is more readable, and matches the project's actual test naming conventions.

---

## 3. Acronyms in Class Names: HTTPClient Convention is Outdated

**Quoted guideline:**

> Keep acronyms uppercase in PascalCase names:
>
> ```ruby
> # Good
> HTTPClient
> XMLParser
>
> # Bad
> HttpClient
> XmlParser
> ```

**Why this is problematic:**

The "keep acronyms uppercase" convention creates word-boundary ambiguity. `HTTPSServer` -- is that `HTTPS` + `Server` or `HTTP` + `SServer`? `XMLHTTPRequest` -- where do the acronyms start and end? The Ruby standard library itself is inconsistent here (`OpenSSL` vs `IPAddr` vs `TCPSocket`).

The broader software industry has been moving toward treating acronyms as words in PascalCase (Microsoft's .NET guidelines, Google's Java/Go style guides, Apple's Swift guidelines). RuboCop has `Naming/ClassAndModuleCamelCase` which does not enforce either convention -- it accepts both.

For a project with 29 language implementations that must share naming concepts, using `HttpClient` style is more portable -- it maps cleanly to Go (`HttpClient`), Java (`HttpClient`), C# (`HttpClient`), and every other language that uses PascalCase.

**Recommended alternative:**

Treat acronyms as words in PascalCase: `HttpClient`, `XmlParser`, `HtmlRenderer`. This eliminates word-boundary ambiguity and aligns better with cross-language conventions. Note that this is a soft preference -- consistency within the codebase matters more than which convention is chosen.

---

## 4. `case` Expression Alignment: The `when` Alignment is Misleading

**Quoted guideline:**

> ```ruby
> stage = case months
>         when 0...2   then :newborn
>         when 2...12  then :infant
>         when 12...36 then :toddler
>         else              :child
>         end
> ```

**Why this is problematic:**

This alignment style (aligning `when` with the argument of `case`) has two issues:

First, it creates very long lines because the entire `case` body is pushed rightward. In the example above, even simple identifiers like `months` push `when` clauses to column 10+. With a longer variable name like `stage_months_count`, you run into the line-length limit fast.

Second, and more importantly, the project's own code does not use this style. The actual formatter uses:

```ruby
ovr = case compactness
      when :short then locale.short
      when :compact then locale.compact
      end
```

which *does* match, but the `stage_key` method uses:

```ruby
if months < 2 then :newborn
elsif months < 12 then :infant
...
```

The guide should present both the assignment-aligned and the two-space-indent styles, noting that two-space indent is more practical for longer `case` bodies.

**Recommended alternative:**

Present two-space indent as the primary style for `case` bodies:

```ruby
stage = case months
when 0...2   then :newborn
when 2...12  then :infant
when 12...36 then :toddler
else              :child
end
```

This avoids the rightward drift problem and matches RuboCop's `Layout/CaseIndentation` with `EnforcedStyle: case` (the default when `IndentOneStep: false`). Mention the aligned style as acceptable for short `case` expressions.

---

## 5. Keyword Arguments vs Positional: Overly Prescriptive

**Quoted guideline:**

> Prefer keyword arguments over positional arguments when a method has optional parameters or when the caller benefits from named parameters:
>
> ```ruby
> # Bad -- positional optional
> def initialize(locale, compactness = :normal)
> ```

**Why this is problematic:**

Labeling positional optionals as "Bad" is too strong. The project's own public API uses positional optionals throughout:

```ruby
def format_age(date_of_birth, as_of = nil)
def format_stage(date_of_birth, as_of = nil, gender: nil)
```

These are perfectly clear. `format_age("2025-06-15", "2025-06-15")` reads fine -- the two arguments are obviously a date pair. Forcing keyword arguments here would make the API worse: `format_age(date_of_birth: "2025-06-15", as_of: "2025-06-15")` is noisier without being clearer.

The actual guideline should be: use keyword arguments when the meaning of an argument is not obvious from context or when there are multiple optional parameters that could be confused. Do not use keyword arguments when positional semantics are clear.

**Recommended alternative:**

Soften to: "Consider keyword arguments when a method has two or more optional parameters, or when the argument's role is not obvious from the call site." Present positional optionals as acceptable when the meaning is clear from context.

---

## 6. Sorbet and Steep: Irrelevant Tooling for This Project

**Quoted guideline (Section 11):**

The guide devotes two full subsections to Sorbet and Steep, including code examples and setup instructions.

**Why this is problematic:**

This project has a hard "zero runtime dependencies" rule. Sorbet's runtime component (`sorbet-runtime`) is a gem dependency. Including it in the style guide implies it is a viable choice for this project, which it is not.

Steep with RBS is technically dependency-free at runtime, but adding a type-checking layer to a library that already has 217 canonical tests across 29 languages is effort spent in the wrong place. The type safety comes from the test suite and the cross-language invariant that all implementations must produce identical output.

More broadly, a project-specific style guide should cover tools the project actually uses or plans to use. Documenting Sorbet and Steep here reads like a general Ruby reference, not a project style guide.

**Recommended alternative:**

Remove the Sorbet and Steep sections entirely. If type checking is ever adopted, add it then. The Tooling section should focus on RuboCop (which the project uses), Minitest (which the project uses), and `ruby -w` (which is free).

---

## 7. RSpec: Should Not Be Presented as an Equal Alternative

**Quoted guideline:**

> Choose one framework per project and stick with it. Minitest is preferred for libraries that target zero dependencies.

**Why this is problematic:**

The guide presents RSpec and Minitest side by side as roughly equivalent options, then adds a soft preference for Minitest at the end. For this project, RSpec is not an option -- it is an external dependency, violating the project's core constraint. The guide should be unambiguous about this.

**Recommended alternative:**

State that Minitest is the project's test framework. Mention RSpec only in passing as a popular alternative in the broader Ruby ecosystem, not as a viable choice for this project.

---

## 8. `Struct.new` with `keyword_init: true` -- Missing Ruby 3.2+ Context

**Quoted guideline:**

> Use `Struct.new` with `keyword_init: true` for simple data-holding classes.

Followed separately by:

> `Data.define` creates immutable value classes. Instances are frozen automatically.
> Prefer `Data.define` over `Struct.new` when the object should be immutable and you are on Ruby 3.2+.

**Why this is problematic:**

The guide recommends `Struct.new` with manual `freeze` as the primary pattern, then separately recommends `Data.define` as the immutable alternative. But the project's `.rubocop.yml` targets Ruby 3.0, not 3.2+. So `Data.define` is not available.

The guide should lead with the pattern the project can actually use (Struct + freeze) and explicitly note the Ruby version constraint that makes `Data.define` unavailable in this project. Otherwise, a contributor reading the guide top to bottom will reasonably ask: "Why isn't the project using `Data.define`?"

**Recommended alternative:**

Lead with Struct + freeze as the project's pattern. Mention `Data.define` as the preferred alternative when the project's minimum Ruby version reaches 3.2. Be explicit about the version constraint.

---

## 9. `extend self` vs `module_function` -- Incomplete Analysis

**Quoted guideline:**

> When a module is purely a namespace (no instances), use `extend self` or `module_function`.

**Why this is problematic:**

These are not interchangeable. `extend self` makes all module methods available as both instance methods (for `include`) and module methods. `module_function` makes them available as module methods but makes the instance-method versions private. The behavioral difference matters.

The guide presents them as equivalent, which will confuse developers who try to use `include` on a module that used `module_function`. The project uses `def self.method_name` in the actual code (see `sayable_age.rb`), not either of these patterns.

**Recommended alternative:**

Describe the actual behavioral difference between `extend self`, `module_function`, and `def self.method_name`. Recommend `def self.method_name` for this project's pattern (a small number of module-level convenience methods), since that is what the codebase already uses.

---

## 10. Missing Guidance on Date Handling

**What is absent:**

The guide has no section on date handling despite the entire project being date-arithmetic code. The formatter does manual date parsing (`split('-').map(&:to_i)`) and uses `Date.new` / `Date.today` from the standard library. This is the core domain logic, and the style guide should address it.

**Recommended addition:**

Add a section on date handling conventions: use `Date` from the standard library (zero-dependency), prefer explicit `(year, month, day)` construction over string parsing where possible, and document the pattern of accepting YYYY-MM-DD strings as the public API boundary while converting to `Date` objects internally.

---

## 11. `Shopify` Config Recommendation is Inappropriate

**Quoted guideline:**

> Use Shopify's config as a solid starting point:
>
> ```yaml
> inherit_gem:
>   rubocop-shopify: rubocop.yml
> ```

**Why this is problematic:**

`rubocop-shopify` is a gem dependency. This project targets zero dependencies. Even as a dev dependency, pulling in Shopify's opinionated config when the project already has a working `.rubocop.yml` tailored to its specific needs (with carefully chosen exclusions for locale data, test files, and metric overrides) is counterproductive.

**Recommended alternative:**

Remove the Shopify config recommendation. Reference the project's own `.rubocop.yml` as the starting point and explain the rationale behind its key overrides (locale data exclusions, elevated metric thresholds for the formatter algorithm, etc.).

---

## 12. Quote Style: The "Pick One" Guidance is a Non-Decision

**Quoted guideline:**

> Both single and double quotes are acceptable. Pick one and be consistent across the project.

**Why this is problematic:**

A style guide that says "pick one" has not made a decision. The project's actual code uses single quotes. The `.rubocop.yml` does not enforce a `StringLiterals` style, but the existing code is consistent. The guide should document what the project does, not punt.

**Recommended alternative:**

State the project's convention: single quotes for strings without interpolation, double quotes for strings with interpolation. This matches the existing codebase and the community guide's default RuboCop configuration.

---

## 13. `reduce` vs `inject` -- The Preference is Backwards for Rubyists

**Quoted guideline:**

> | Preferred | Avoid |
> |-----------|-------|
> | `reduce` | `inject` (acceptable but less clear) |

**Why this is problematic:**

`inject` is the original Ruby name, predating `reduce` by years. Many experienced Rubyists (and the Ruby documentation itself) use `inject` as the primary name. Calling it "less clear" is subjective and alienating to the portion of the community that prefers it.

RuboCop's `Style/CollectionMethods` cop is disabled by default precisely because the community could not agree on preferred names. The guide should not take a strong stance on a matter the community explicitly declined to standardize.

**Recommended alternative:**

List both `reduce` and `inject` as acceptable. Note that consistency within the codebase is what matters. Since the codebase does not currently use either (the formatter uses explicit iteration), this is a low-stakes preference.

---

## 14. The `retry` Example Uses `begin` Inside a Method

**Quoted guideline (Section 6, `retry`):**

> ```ruby
> def fetch_with_retry(url, max_attempts: 3)
>   attempts = 0
>   begin
>     attempts += 1
>     http_get(url)
>   rescue Timeout::Error
>     retry if attempts < max_attempts
>     raise
>   end
> end
> ```

**Why this is problematic:**

The guide's own Section 6 ("Implicit Begin in Methods") says to use the method body as the implicit `begin` block rather than adding explicit `begin...rescue...end`. But the `retry` example adds an explicit `begin` because `attempts = 0` needs to execute before the retry-able block. The guide should acknowledge this as the valid exception to the implicit-begin rule, rather than leaving the contradiction unaddressed.

**Recommended alternative:**

Add a note in the implicit-begin section: "Use explicit `begin` when you need setup code before the retry-able block." Or restructure the `retry` example to use implicit begin with the counter as an argument default.

---

## 15. Lazy Enumerators Example Has a Style Error

**Quoted guideline:**

> ```ruby
> File.open("huge.log").each_line.lazy
>   .select { |line| line.include?("ERROR") }
>   .first(10)
> ```

**Why this is problematic:**

The guide's own Section 2 says multi-line chains use a leading dot on continuation lines, indented one level. But this example places `.select` at the same level as `File.open`, not indented one level from it. More importantly, `File.open` without a block leaks the file descriptor. The example should use `File.foreach` or pass a block.

**Recommended alternative:**

```ruby
File.foreach("huge.log").lazy
  .select { |line| line.include?("ERROR") }
  .first(10)
```

This fixes both the style inconsistency and the file descriptor leak.

---

## Minor Issues Not Worth Full Sections

- The `Comparable` section is fine but irrelevant -- the project does not use it and has no natural ordering types.
- The `then` / `yield_self` section shows a three-stage pipeline that is more naturally written as three lines of assignment. `then` is useful for optional chaining; the example does not demonstrate its strengths.
- The `BEGIN` / `END` warning is so niche it barely needs mentioning. No one writing Ruby in 2026 is reaching for these.
- The guide does not mention `Ractor` or frozen-by-default discussions that are relevant to Ruby's concurrency future. This is fine for a library style guide but worth noting for completeness.

---

## Conclusion

The guide's coverage of error handling, block conventions, and things to avoid is solid. The naming conventions, core formatting rules, and Enumerable guidance are all sound foundations. The issues above are primarily about (a) contradicting the project's actual configuration and code, (b) presenting general Ruby reference material instead of project-specific decisions, and (c) a few technically inaccurate or incomplete recommendations. The rewrite should tighten the guide to be a project-specific document rather than a Ruby language tutorial.
