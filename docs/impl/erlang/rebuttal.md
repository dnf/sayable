# Rebuttal: Erlang Style Guide

Reviewed by a Senior Staff Engineer. Overall this is a solid guide that draws from reputable sources and covers the right ground. However, there are several points ranging from misleading to dogmatic that I want to address.

---

## 1. Line Length: 80 Characters Is Outdated and the Example Is Wrong

**Guideline:**

> Keep lines to a maximum of **80 characters**.

**Analysis:**

80 characters is a relic of punch cards and VT100 terminals. The Erlang community has largely moved to 100-120 characters. Erlang's syntax is inherently verbose -- qualified module calls (`sayableage_internal:compute_age/2`), record access (`Locale#locale.day`), and long atom-prefixed module names all conspire to make 80 characters genuinely painful. Forcing 80 columns leads to excessive line continuations that *reduce* readability -- the opposite of the rule's intent.

More critically, the example given to justify this rule is **wrong**:

```erlang
io:format("Name: ~s, Age: ~w, Phone: ~w~n"
          "Dictionary: ~w.~n",
          [Name, Age, Phone, Dict]).
```

Erlang does **not** automatically concatenate adjacent string literals the way C does. This code would fail. The two strings are separate arguments. To concatenate string literals in Erlang, you must use `++` explicitly or write the string as one literal. This is a factual error in the guide.

**Recommendation:** Set the limit at 100 characters, which is what most modern Erlang projects use. Remove or fix the broken string concatenation example.

---

## 2. "Avoid `if` Expressions" Is Dogmatic

**Guideline:**

> The `if` expression in Erlang is unusual: it uses guard expressions only, with no pattern matching. Prefer `case` for conditional logic. Reserve `if` for simple guard-based numeric checks.

And in the Elvis config:

> `{elvis_style, no_if_expression}`

**Analysis:**

The guide contradicts itself. It says "`if` is acceptable for simple guard-based branching," gives an example of that, and then the Elvis config bans `if` entirely with `no_if_expression`. You cannot simultaneously say "reserve `if` for simple guard-based numeric checks" and also lint-ban every `if` expression.

Furthermore, the blanket advice to "prefer `case`" leads to awkward code. When you have pure guard conditions and no values to pattern-match on, `case X of true -> ...; false -> ... end` is more verbose and less direct than `if X -> ...; true -> ... end`. The `if` expression exists for this exact purpose.

The "acceptable" example in the guide is actually the right way to use `if`, which proves the tool's own blanket ban is wrong.

**Recommendation:** Drop the `no_if_expression` Elvis rule. Keep the advice that `case` is preferred when pattern matching is involved, but state clearly that `if` is appropriate for pure guard-condition branching. Acknowledge the contradiction and resolve it in favor of pragmatism.

---

## 3. Module Size Limit of 400 Lines Is Too Restrictive

**Guideline:**

> Keep modules under **400 lines** of source code. If a module exceeds this, split it into smaller modules with clear responsibilities.

**Analysis:**

400 lines is too aggressive for Erlang. A `gen_server` with a non-trivial state machine can easily hit 400 lines with just the callback implementations, specs, type definitions, and public API wrappers -- all of which *belong together*. Splitting a gen_server across multiple modules to meet a line count just creates artificial coupling between modules and scatters related logic.

Erlang's flat module namespace and the convention of prefixing module names already impose a cost on splitting. Creating `my_server_helpers` just to stay under 400 lines is worse than having a cohesive 600-line module.

The Ericsson programming rules document (cited as a source) recommends "about 400 lines" but frames it as a guideline, not a hard rule, and that was written when monitors were smaller and IDEs were less capable.

**Recommendation:** Change to "aim for under 600 lines" as a guideline, not a hard rule. The real heuristic is cohesion: if every function in the module serves the same responsibility, size is less important.

---

## 4. "One Assertion Per Test" Is Misleading for EUnit

**Guideline:**

> **One assertion per test** (or per list element in a test generator). Each test should verify one behavior.

**Analysis:**

This advice is fine in theory but misleading in practice for EUnit test generators. When you have a `_test_()` function returning a list of `?_assertEqual` expressions, each list element is already a separate test. The guide's parenthetical "(or per list element in a test generator)" acknowledges this but buries the practical truth.

The bigger issue: for integration-style tests or tests that verify a multi-step computation, multiple assertions per test function are completely fine and often *necessary*. Dogmatic "one assertion per test" leads to either (a) duplicating expensive setup across many test functions or (b) contorting tests to pack everything into a single `?_assertMatch`.

**Recommendation:** Reword to "each test should verify one *behavior*" without the "one assertion" framing. Clarify that multiple assertions are fine when they collectively verify a single logical behavior or when they share necessary setup.

---

## 5. The `nothing | {just, Value}` Optional Pattern Is Non-Standard

**Guideline:**

> Use `nothing | {just, Value}` (or similar) for optional values in records.

**Analysis:**

This is a Haskell-ism (`Maybe = Nothing | Just a`) transplanted into Erlang. It is not conventional Erlang. The standard Erlang idiom for optional values is `undefined | Value`, which is what you see in OTP, most open-source Erlang code, and the default value of uninitialized record fields.

Using `{just, Value}` means every consumer must unwrap a tuple, while `undefined | Value` allows direct use of the value. For a style guide intended to promote *idiomatic* Erlang, recommending a non-standard pattern is counterproductive. Developers reading the codebase will be surprised by `{just, Val}` in a way they would never be by `undefined`.

I understand the guide notes "(or similar)" and the project itself uses this pattern, so this may be a deliberate project-specific choice. But the guide positions it as general Erlang style, which it is not.

**Recommendation:** Present `undefined | Value` as the standard Erlang idiom. If the project uses `nothing | {just, Value}` as a deliberate choice, document it as a project convention that departs from community norms, and explain the rationale (e.g., distinguishing "not set" from "set to a falsy value" more explicitly).

---

## 6. Process Dictionary Advice Is Correct but Overstated

**Guideline:**

> **Never** use `put/2`, `get/1`, or `erase/1`.

**Analysis:**

The reasoning is correct: process dictionary abuse leads to hidden state and impure functions. However, "never" is slightly too strong. There are legitimate uses:

- `logger` metadata (`logger:set_process_metadata/1`) uses the process dictionary internally.
- `rand:uniform/1` stores seed state in the process dictionary by default.
- Debugging with `put(trace_id, Id)` during development.

These are all OTP-internal or well-known patterns. Saying "never" in a guide that will be used for code auditing could lead to false-positive audit findings against code that uses standard OTP functions that happen to touch the process dictionary under the hood.

**Recommendation:** Change to "avoid direct use of `put/2`, `get/1`, and `erase/1`" and note that some OTP modules use the process dictionary internally, which is acceptable. The prohibition should be on application-level code storing state in the process dictionary.

---

## 7. The Dialyzer Claim of "No False Positives" Is Misleading

**Guideline:**

> It uses "success typing" -- it only reports issues it can **prove** will cause runtime failures, so it has no false positives.

**Analysis:**

This is the marketing claim, and it is technically true in a narrow theoretical sense but misleading in practice. Dialyzer can and does produce confusing warnings that *look* like false positives:

- Specs that are more restrictive than the code confuse Dialyzer in ways that produce cascading, hard-to-diagnose warnings on correct code.
- Overlapping function clause guards can trigger warnings about clauses that "will never match" when in fact they can.
- Complex type unions sometimes cause Dialyzer to report contract violations that are practically unreachable.

The guide then says "When Dialyzer complains about your spec, the spec is almost always wrong -- not Dialyzer." This is good pragmatic advice, but it contradicts the "no false positives" framing. If Dialyzer truly had no false positives, you would not need this caveat.

**Recommendation:** Soften to "Dialyzer uses success typing, which means it has a very low false-positive rate -- when it reports an issue, it is almost always a genuine problem." Drop the absolute "no false positives" claim.

---

## 8. Missing Topic: Binary Strings vs. List Strings

The guide mentions binaries in the data structures table ("prefer binaries over lists for large text") but does not give any guidance on when to use binary strings (`<<"hello">>`) vs. list strings (`"hello"`). This is one of the most common sources of confusion in Erlang and arguably more important for a style guide than, say, the supervisor restart strategy table.

**Recommendation:** Add a brief section in Data Structures or Common Idioms covering:
- List strings (`"hello"` = `[104,101,108,108,111]`) are traditional Erlang strings, easy to pattern match, but expensive for large text.
- Binary strings (`<<"hello">>`) are more memory-efficient for large text and used by most modern libraries.
- Most I/O functions accept iolists (mixed lists and binaries), so you often do not need to choose.
- Pick one convention per project for internal APIs and be consistent.

---

## 9. Missing Topic: `maybe` Expressions (OTP 25+)

The guide covers OTP patterns thoroughly but omits the `maybe` expression introduced in OTP 25 (stabilized in OTP 27). Given that the deeply-nested-case anti-pattern is discussed at length, the `maybe` expression is directly relevant as the language-level solution:

```erlang
maybe
    {ok, A} ?= foo(),
    {ok, B} ?= bar(A),
    {ok, C} ?= baz(B),
    {ok, C}
end.
```

This is the modern Erlang answer to the exact nesting problem the guide addresses with manual refactoring into helper functions.

**Recommendation:** Add a subsection under Pattern Matching or Functional Patterns covering `maybe` expressions, noting the OTP version requirement.

---

## 10. The `handle_info` Catch-All Advice Contradicts OTP Practice

**Guideline:**

> ```erlang
> %% Bad: silently ignores new message types
> handle_info(_Info, State) ->
>     {noreply, State}.
>
> %% Good: logs unexpected messages
> handle_info(Info, State) ->
>     logger:warning("Unexpected message: ~p", [Info]),
>     {noreply, State}.
> ```

**Analysis:**

The intent is right -- you should not silently swallow unexpected messages. But calling the silent version "bad" is too strong. In OTP, `handle_info/2` is *required* by the `gen_server` behaviour, and many processes legitimately receive messages they do not care about (system messages, late replies from timed-out calls, monitor notifications from processes you no longer track). Logging a warning for every one of these creates noise in production logs.

The example shown in the gen_server section (Section 7) itself uses the "bad" pattern:

```erlang
handle_info(_Info, State) ->
    {noreply, State}.
```

This is an internal contradiction. The gen_server template in Section 7 does exactly what Section 10 calls "bad."

**Recommendation:** Resolve the contradiction. The pragmatic advice is: log at `debug` level (not `warning`) in production code, and during development or in systems where unexpected messages indicate bugs, log at `warning`. Acknowledge that the silent catch-all is acceptable in many production contexts.

---

## 11. The `check_` Prefix Convention Is Uncommon

**Guideline:**

> | `check_` | `{ok, ...} \| {error, ...}` | `check_permissions(User)` |

**Analysis:**

The `is_` prefix for boolean predicates is well-established Erlang convention. The `get_` and `find_` conventions are reasonable. But `check_` returning `{ok, ...} | {error, ...}` is not a widely recognized Erlang convention. In practice, `validate_` is more commonly used for this pattern in Erlang codebases. The `check_` prefix in Erlang more commonly implies a side effect (like `check_process_code/2` in the `erlang` module) or a boolean check.

**Recommendation:** Either replace `check_` with `validate_` or note that this is a project convention rather than a community-wide standard.

---

## 12. Elvis Config Nesting Level Is Inconsistent with Guide Text

**Guideline (text):**

> Limit code to a maximum of **two levels** of indentation.

**Elvis config:**

> `{elvis_style, nesting_level, #{level => 3}}`

**Analysis:**

The prose says two levels, but the Elvis config allows three. This is a direct contradiction. One of them is wrong.

**Recommendation:** Align them. I would set both to three levels -- two is often too restrictive for `case` inside a function clause that itself has a guard, which is normal Erlang.

---

## Summary

The guide is well-structured and covers the right topics. The core advice on naming, pattern matching, error handling, OTP patterns, and functional idioms is sound. The main issues are:

1. **Factual error:** The string concatenation example is wrong.
2. **Internal contradictions:** `if` expression advice vs. Elvis config; nesting depth text vs. Elvis config; handle_info advice in Section 10 vs. Section 7.
3. **Overly dogmatic limits:** 80-char lines, 400-line modules, absolute "never" on process dictionary, absolute "no false positives" for Dialyzer.
4. **Non-idiomatic recommendation:** `nothing | {just, Value}` instead of `undefined | Value`.
5. **Missing modern topics:** `maybe` expressions (OTP 25+), binary vs. list strings.
6. **Minor naming issue:** `check_` prefix is uncommon; `validate_` is more standard.
