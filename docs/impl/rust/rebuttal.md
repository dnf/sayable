# Rebuttal: Rust Style Guide Review

Senior Staff Engineering review of `docs/impl/rust/README.md`.

Reviewer context: This guide is intended for auditing Rust implementations in the Sayable project -- a zero-dependency, multi-language formatting library. The actual Rust codebase (`age/impl/rust/`) is a small, focused library with no external dependencies, no `unsafe`, and no async. Many sections of this guide are accurate and well-written. This rebuttal addresses only the guidelines I disagree with or find problematic.

---

## 1. Recommending `thiserror` and `anyhow` in a zero-dependency project

### Quoted guideline

> For library code, use [`thiserror`](https://docs.rs/thiserror) to reduce boilerplate in custom error types.
>
> For application code (binaries, CLI tools), use [`anyhow`](https://docs.rs/anyhow) for ergonomic error handling without defining custom types.

### Why this is problematic

This project has a hard constraint stated in `CLAUDE.md`: **"Zero runtime dependencies. No exceptions in any language."** Recommending `thiserror` and `anyhow` directly contradicts that constraint. A reviewer auditing the Rust implementation against this guide might add these dependencies and break the project's invariant.

Even setting aside the project constraint, `thiserror` is a proc-macro dependency that adds compile time. For a crate with one or two error types (which is all Sayable needs), the manual `Display` impl is roughly ten lines and carries zero compilation cost. The boilerplate reduction is negligible.

`anyhow` is legitimate advice for application code, but Sayable's Rust implementation is a library. Including application-level advice in a library-focused style guide creates confusion about what applies where.

### Recommended alternative

Acknowledge that `thiserror` and `anyhow` exist as ecosystem conventions, but frame them as external references that do not apply to this project. The guide should show the manual pattern as the primary approach and note the zero-dependency constraint explicitly.

---

## 2. Blanket prohibition on `unwrap()` and `expect()` in library code

### Quoted guideline

> Never use `unwrap()` or `expect()` in library code.

### Why this is problematic

The word "never" is too strong and contradicts actual idiomatic Rust practice. The actual Sayable codebase uses `unwrap()` in library code -- on a `Mutex::lock()` call and on `SystemTime::now().duration_since(UNIX_EPOCH)` -- and both are correct. A `Mutex` that is poisoned indicates a panic on another thread; propagating that panic via `unwrap()` is the standard approach (and the one `std` itself documents). `UNIX_EPOCH` being after `SystemTime::now()` would require time travel.

The Rust standard library itself uses `unwrap()` and `expect()` internally where invariants are provably upheld. The Rust API Guidelines (C-CALLER-CONTROL) say functions should not panic on *inputs the caller controls* -- they do not say "never unwrap."

More importantly, this guideline makes the checklist at the bottom of the guide mechanically wrong. The checklist says:

> No `unwrap()` or `expect()` in library code (only in tests)

An auditor following this literally would flag the Mutex lock and the SystemTime call as defects, when they are actually fine.

### Recommended alternative

Replace "never" with a nuanced rule: `unwrap()` and `expect()` are acceptable in library code when the invariant is provably upheld and a comment documents why. They should not be used on fallible operations whose failure depends on user input or runtime state the caller controls.

---

## 3. Claiming `as` casts should always be replaced with `From`/`TryFrom`

### Quoted guideline

> **Using `as` for numeric casts.** Prefer `From`/`TryFrom` for safe conversions. `as` silently truncates.

### Why this is problematic

This is good general advice but presented as an absolute. There are legitimate uses of `as` in Rust:

1. **Casting between `usize` and pointer-width integers** -- `From` is not implemented for all `usize` conversions on all platforms because `usize` varies by target.
2. **Casting in `const` contexts** -- until recently, `From` and `TryFrom` were not available in `const fn`. Even now, not all conversions are const-stable.
3. **Performance-sensitive inner loops** -- `as` is a single instruction; `TryFrom` introduces a branch and a `Result`. In hot paths where the range is already validated, `as` is the right tool.

The Sayable codebase itself uses `as` casts (see `cast_possible_truncation`, `cast_possible_wrap`, `cast_sign_loss` allows in `Cargo.toml`) because the date arithmetic involves known-safe range conversions. The guide should acknowledge this pattern rather than implying it is always wrong.

### Recommended alternative

Prefer `From`/`TryFrom` for conversions where the range is not statically guaranteed. Use `as` when the range is provably safe and document the safety reasoning. Note that the project's Clippy configuration already manages this with targeted allows.

---

## 4. The `Arc<Mutex<T>>` section is irrelevant and misleading

### Quoted guideline

> `Arc<Mutex<T>>` is a code smell in many contexts. Before reaching for it:
> 1. Can the data be passed by value or reference instead of shared?
> 2. Can the architecture be restructured to avoid shared mutable state?
> 3. Is message passing (channels) more appropriate?
> 4. Would `RwLock` (for read-heavy workloads) or atomics (for simple counters) suffice?

### Why this is problematic

The actual codebase uses `Mutex` (without `Arc`) for a test-only time override (`NOW_OVERRIDE`). This section reads like generic Rust advice copy-pasted from a concurrency tutorial. It has no relevance to a single-threaded formatting library with no async, no spawned threads, and no shared state beyond a test fixture.

Calling `Arc<Mutex<T>>` a "code smell" without qualification is also technically wrong. It is the standard, recommended pattern for sharing mutable state across threads in Rust. The standard library documentation uses it as the primary example. The real smell is using it when you do not actually need shared ownership -- but the guide does not draw that distinction clearly.

The suggestion to use channels instead of `Arc<Mutex<T>>` is architecture advice that belongs in a systems design document, not a code style guide for a formatting library.

### Recommended alternative

Remove this section entirely, or replace it with a brief note that this project does not use concurrency primitives beyond a test-only `Mutex`, and that reviewers should flag any introduction of `Arc`, `Mutex`, or `RwLock` in the formatter itself as a design concern.

---

## 5. The `PhantomData` and type-state sections are over-scoped

### Quoted guideline

The guide devotes roughly 50 lines to `PhantomData` and the type-state pattern (the `Door<Locked>/Door<Unlocked>` example, the `Article<Draft>/Article<Published>` example).

### Why this is problematic

This is a style guide for auditing a specific codebase that contains zero uses of `PhantomData`, zero type-state patterns, and zero generic structs parameterized by phantom types. Including these patterns at length gives the impression that they are expected or encouraged in this codebase, when they are irrelevant.

A reviewer encountering these sections will either (a) skip them because they do not apply, wasting their time, or (b) try to apply them where they do not belong, over-engineering simple data types.

The type-state pattern is a legitimate advanced technique, but it belongs in a general Rust patterns reference, not in a project-specific style guide for a formatting library.

### Recommended alternative

Cut these sections entirely. If a brief mention is desired, a single sentence noting that `PhantomData` exists for advanced generic programming is sufficient, with a link to the Rust Reference.

---

## 6. The builder pattern section encourages unnecessary abstraction

### Quoted guideline

> Use the builder pattern for types with many optional parameters.

(Followed by a 40-line `QueryBuilder` example.)

### Why this is problematic

The Sayable Rust implementation constructs its main type (`SayableAge`) via `SayableAge::new(&locale, compactness)` -- two parameters, neither optional. The builder pattern is appropriate for types with five or more optional fields, but this codebase has no such types.

Including a full builder pattern example in the style guide signals to contributors that this is an expected pattern for this project. In practice, it would be over-engineering. The `SayableAge::new` constructor is clear, simple, and idiomatic.

### Recommended alternative

Remove the builder pattern section, or reduce it to a single sentence noting when the pattern is appropriate (many optional parameters) with a link to the Rust Design Patterns book. Do not include a full implementation example.

---

## 7. The prelude pattern recommendation is at odds with the codebase

### Quoted guideline

> For crates with many commonly-used types, provide an optional prelude module.
>
> Use this sparingly. Glob imports reduce readability when overused.

### Why this is problematic

The guide simultaneously recommends creating a prelude module and warns against glob imports. The sole purpose of a prelude is glob imports. This is contradictory advice.

The actual codebase does not have a prelude module. It uses explicit re-exports in `lib.rs`, which is the correct approach for a library of this size. The prelude pattern is designed for large frameworks (like `bevy` or `tokio`) where importing 10+ types individually would be tedious. Sayable exports roughly six public types.

### Recommended alternative

Remove the prelude section. The existing re-export pattern in `lib.rs` is the right approach and should be documented as such.

---

## 8. Comment line length rule of 80 characters is arbitrary and conflicting

### Quoted guideline

> Line comments should not exceed 80 characters (excluding indentation) or the max line width, whichever is smaller.

### Why this is problematic

The guide itself states that `rustfmt`'s `max_width` is 100 characters. Imposing a separate 80-character limit on comments creates two competing line-width rules in the same file. This is confusing and unenforceable -- `rustfmt` does not reflow comments, so this rule can only be checked manually or with a custom lint.

The 80-character tradition comes from terminal widths that have been irrelevant for decades. Modern code review tools, IDEs, and terminals comfortably handle 100+ characters. Having code at 100 characters but comments at 80 creates an awkward ragged right margin.

### Recommended alternative

Use a single line width rule: 100 characters for both code and comments, matching the `rustfmt` configuration. If shorter comment lines are desired for readability, frame it as a soft preference, not a rule.

---

## 9. `cargo audit` and `cargo deny` are irrelevant for a zero-dependency crate

### Quoted guideline

> `cargo audit`: Scans dependencies for known security vulnerabilities. Run periodically and in CI.
>
> `cargo deny`: Comprehensive dependency linter. Checks licenses, bans specific crates, detects duplicate versions, and audits for vulnerabilities.

### Why this is problematic

The `Cargo.toml` has zero dependencies and zero dev-dependencies. There is nothing for `cargo audit` or `cargo deny` to scan. Including these tools in the guide and the CI pipeline adds complexity and execution time for zero benefit.

More importantly, including them implies the project might have dependencies in the future, which contradicts the zero-dependency invariant. A reviewer might interpret their presence as "we expect dependencies to be added eventually."

### Recommended alternative

Remove these sections. Add a note that the zero-dependency constraint means dependency auditing tools are unnecessary. If the project ever adds dependencies (which it should not), these tools can be re-evaluated.

---

## 10. Miri section is irrelevant when `unsafe` is forbidden

### Quoted guideline

> Miri: An interpreter for Rust's mid-level intermediate representation (MIR). Detects undefined behavior in unsafe code.
>
> Use it for any crate that contains `unsafe` code.

### Why this is problematic

The `Cargo.toml` contains `unsafe_code = "forbid"`. There is no unsafe code and there cannot be any. Miri has no useful work to do on this crate.

Including Miri in the guide suggests to reviewers that they should run it, adding nightly toolchain requirements and CI time for no benefit.

### Recommended alternative

Remove the Miri section. Note that `unsafe_code = "forbid"` in `Cargo.toml` eliminates the need for Miri entirely.

---

## 11. The Deref anti-pattern example is correct but the `AsRef` alternative is incomplete

### Quoted guideline

> Only implement `Deref` for smart pointers (C-DEREF). Use `AsRef` for lightweight borrowing conversions.
>
> ```rust
> // Incorrect: Deref for non-smart-pointer types
> impl Deref for LocaleCode {
>     type Target = str;
>     fn deref(&self) -> &str { &self.0 }
> }
> ```

### Why this is problematic

The advice against `Deref` on newtypes is correct per the API guidelines, but the guide does not acknowledge that this is a genuinely debated point in the Rust community. Many well-regarded crates (including `url::Url`, `camino::Utf8Path`) implement `Deref` on newtypes, and the `Deref`-based approach provides method delegation automatically, which `AsRef` does not.

The guide presents `AsRef` as a drop-in replacement, but it is not. `AsRef<str>` does not let you call `.len()`, `.contains()`, or any other `str` method directly on the newtype. You would need to either implement `Deref` (which the guide forbids) or add forwarding methods manually.

### Recommended alternative

Keep the `Deref` warning but add nuance: `Deref` on newtypes is discouraged by the API guidelines because it bypasses the abstraction boundary the newtype creates. However, for newtypes that are genuinely transparent wrappers (where you want the inner type's full API), `Deref` is pragmatically acceptable. For newtypes that enforce invariants, use `AsRef` or explicit accessor methods.

---

## 12. The checklist conflates "what to check" with "what to enforce"

### Quoted guideline

The "Quick Reference Checklist" at the end includes items that range from mechanically verifiable (`cargo fmt -- --check passes`) to subjective judgment calls (`No unnecessary .clone() calls`).

### Why this is problematic

Mixing automated checks with manual review items in a single flat checklist makes it unclear which items are CI-enforceable and which require human judgment. A reviewer might skip the entire checklist if the first few items pass in CI, missing the manual review items. Or they might try to automate items like "Comments explain why, not what" and waste time.

Additionally, several checklist items duplicate the Clippy configuration already in `Cargo.toml`. For example, "Functions accept `&str` instead of `&String`" is already caught by `clippy::needless_pass_by_value`. "Numeric conversions use `From`/`TryFrom`, not `as`" is caught by `clippy::cast_lossless`. Listing them again in a manual checklist is redundant.

### Recommended alternative

Split the checklist into two sections: "Automated (CI)" listing the commands that enforce rules mechanically, and "Manual review" listing the items that require human judgment. Remove items that are already covered by the Clippy configuration.

---

## 13. Clone vs. Borrow advice oversimplifies `store_name` pattern

### Quoted guideline

> ```rust
> // Correct: caller decides when to clone
> fn store_name(name: String) {
>     // owns the string
> }
>
> // Avoid: hidden clone inside the function
> fn store_name(name: &str) {
>     let owned = name.to_string(); // caller cannot avoid this allocation
> }
> ```

### Why this is problematic

This advice is correct in isolation but ignores the common case where the caller already has a `&str` (from a string literal, a slice, or a borrowed field). In that case, `store_name(name: String)` forces the caller to allocate before calling, even if they have to write `store_name(name.to_string())`. The "caller decides" framing is misleading because in many cases the caller has no choice but to allocate.

The idiomatic Rust solution for this tension is `impl Into<String>`:

```rust
fn store_name(name: impl Into<String>) {
    let owned = name.into();
}
```

This accepts both `String` (moved, zero cost) and `&str` (allocated once). The guide does not mention this pattern.

### Recommended alternative

Show the `impl Into<String>` pattern as the preferred approach for functions that need ownership but want to be ergonomic for callers with either owned or borrowed data. Note that for functions called in hot loops, taking `String` directly is preferable to avoid the trait dispatch overhead (though in practice it is monomorphized away).

---

## 14. The "stringly-typed API" example creates types that do not exist in the codebase

### Quoted guideline

> ```rust
> // Prefer: type-safe
> fn format(locale: Locale, precision: Precision) { ... }
> format(Locale::English, Precision::Half);
> ```

### Why this is problematic

The actual API is `SayableAge::new(&AgeLocale, Compactness)`, where `AgeLocale` is a struct (not an enum of languages) and `Compactness` is the right enum. The guide's example invents `Locale::English` and `Precision::Half` which do not exist and would be a worse design -- enumerating all 110 locales as enum variants would be impractical.

Style guide examples should either use the actual codebase's types or use clearly generic examples that cannot be confused with the real API.

### Recommended alternative

Either use the actual Sayable types in the example or use a domain-unrelated example (like the Width/Height newtype example, which is already in the guide and is fine).

---

## Summary

The guide is well-structured and most of the Rust-specific advice is sound. The core problems are:

1. **Scope creep**: It includes patterns and tools that are irrelevant to this specific codebase (PhantomData, type-state, builder pattern, Miri, cargo-audit, cargo-deny, Arc/Mutex advice).
2. **Zero-dependency violation**: It recommends `thiserror` and `anyhow`, contradicting the project's fundamental constraint.
3. **Overly absolute rules**: "Never use unwrap", "never use as" -- these need nuance.
4. **Phantom examples**: Invented types like `Locale::English` that do not match the real API.

The rewrite should be a focused, project-specific guide that helps reviewers audit the actual code, not a general Rust tutorial.
