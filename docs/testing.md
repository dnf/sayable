# Testing

Sayable promises that every implementation produces **identical output** for the same input, in 50 languages. A promise like that can't rest on 50 hand-written test suites, so testing is layered: one language-independent specification, a native suite per language that implements it, and then two checks that **don't trust those native suites at all**.

| Layer | What it is | What it guards against | Run it |
|---|---|---|---|
| 1. Canonical spec | `<component>/config/tests.json` | Ambiguity about what correct output is | (data, not code) |
| 2. Native suites | Each language's own tests of the spec | Regressions, with fast idiomatic feedback | `just test <lang>` |
| 3. CLI harness | One generated harness drives every language's CLI | A native suite that skips, weakens or misreads a spec case | `just test cli` |
| 4. Fuzz test | Random requests, all languages compared to each other | Divergence outside the spec; code that only gets the tested inputs right | `just fuzz` |

## 1. The canonical specification

Each component's `config/tests.json` (for example [`age/config/tests.json`](../age/config/tests.json)) is the single, language-independent definition of correct behaviour. Each case has an ID, an input, the expected output and a note on why it matters. Every input is an explicit date pair; tests never depend on today's date.

**Spec first.** A new behaviour, edge case or bug fix starts as a case in `tests.json`, then gets implemented everywhere. A bug that can't be written as a spec case can't be reliably fixed in 50 languages.

## 2. Native test suites

Every language implements every applicable spec case in its own test framework, annotated with the canonical ID (`// 3.1`, `# 25.10, 25.11`) so a reviewer can trace each test back to the spec. These suites give fast feedback in each language's own tooling and run in CI on every push (`.github/workflows/<lang>.yml`).

**But they are written by hand, once per language, and they drift.** Real examples found in this repository:

- A suite asserted only that an output *contains* "weeks" where the spec defines exact strings.
- Python's `format_stage` raised an exception on the input `undefined`. The one-shot CLI exited 1 as a result, which is the code for "null result", so the canonical null test passed by accident.
- Several suites test whole sections without annotating them with their IDs, so a missing or altered case is invisible in review.
- A compiled language skips cases it finds awkward (default-asOf, `undefined`) and has to say so in a comment; nothing else enforces that the rest are all present.

None of this is malicious, but the effect is the same as a suite that cheats: green tests, wrong behaviour. So the next two layers check the **implementations**, not their test code.

## 3. The CLI harness: one test driver for every language

Each language ships a `sayable` CLI in `cli/impl/<lang>/` that exposes the public API ([`cli/SPEC.md`](../cli/SPEC.md)). [`cli/test-harness.sh`](../cli/test-harness.sh) is **generated from the same `tests.json` files** by `cli/generate-test-harness.py`, and the same harness, with the same expected strings, drives every language. A language can't weaken an assertion it doesn't own.

The harness talks to the CLI's **REPL mode**: `sayable --repl` reads one tab-separated request per line and answers each with `<exit><TAB><output>`, flushing every line. The harness queues every case, sends them all to **one process**, then checks the responses. Startup is paid once per language instead of once per test. The Python CLI went from about 30 s to under half a second, and JVM, .NET and Node implementations gain far more.

```
just test cli                          # every CLI, in parallel
bash cli/test-harness.sh cli/impl/go/sayable
python3 cli/check-repl.py cli/impl/go/sayable   # REPL protocol conformance (flushing, errors, EOF)
```

Regenerate the harness after changing any `tests.json`: `python3 cli/generate-test-harness.py`.

## 4. The fuzz test: implementations check each other

The spec covers a few hundred hand-picked inputs. [`cli/fuzz.py`](../cli/fuzz.py) generates thousands of random requests across commands, all 168 locales, compactness modes, genders and malformed inputs. It is biased toward the boundaries where bugs hide: month ends, leap days, birthdays on the 31st, tier thresholds, the 500-year limit. It sends the identical batch to every language's REPL and reports every request on which the languages don't all agree.

It needs no expected values: answers are compared against a **reference implementation**, Python by default, whose CLI runs from source anywhere `python3` does. That makes it the guarantee behind the native suites. An implementation that passes its own tests only because the tests are narrow, or that gets the specified inputs right and nearby inputs wrong, shows up as disagreeing with the reference.

Because the reference is always available, you can fuzz **one language, or any subset**, without the other 49 toolchains, and each language's CI job does exactly that. A full run compares everything with the reference too. When the reference is itself outside the majority on a request, the report says so, since then it's probably the reference that's wrong. `--reference none` compares languages only with each other.

```
just fuzz                              # every CLI vs python, 2000 random requests
just fuzz --langs go                   # one language vs python (what CI runs)
just fuzz --langs go,rust,zig          # a subset vs python
just fuzz --reference none             # every CLI vs each other
just fuzz -n 20000 --seed 1234 --report fuzz.json
```

Every run prints its seed, and a failing run prints the exact command to reproduce it.

**Triage.** Neither the reference nor the majority is the truth: check the behaviour against the spec and the reference algorithm. Then follow the spec-first rule: add the input as a new case in `tests.json`, regenerate the harness, and fix every language that fails it. The fuzz finding becomes a permanent canonical test.

## Coverage limits

- Layers 3 and 4 only see languages that have a CLI (`cli/impl/<lang>/sayable`). A language with no CLI is covered only by its native suite. Add a CLI as part of adding a language.
- A component a CLI doesn't implement (it answers exit 2) is skipped for that language by both the harness and the fuzzer.
- Default-asOf ("today") behaviour can't be compared across processes deterministically. It is covered by the native suites only.

## License

[MIT](../LICENSE.md)
