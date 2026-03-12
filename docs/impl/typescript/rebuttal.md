# Style Guide Rebuttal

Senior Staff Engineer review of the TypeScript Style Guide (`docs/impl/typescript/README.md`).

This document covers guidelines I disagree with or believe need significant revision. Items not mentioned here are ones I consider sound.

---

## 1. Acronym Casing: "Treat abbreviations and acronyms as single words"

### Quoted guideline

> **Treat abbreviations and acronyms as single words.** Capitalize only the first letter.
>
> ```typescript
> // Bad
> let loadHTTPURL: string;
> class XMLParser { }
>
> // Good
> let loadHttpUrl: string;
> class XmlParser { }
> ```

### Why this is problematic

This rule is presented as universal when it is actually a minority position in the TypeScript ecosystem. The dominant convention in the TypeScript/JavaScript world -- used by the Node.js core API, the DOM API, and the vast majority of npm packages -- preserves acronym casing: `URL`, `HTTP`, `JSON`, `HTML`, `CSS`, `DOM`, `API`. The standard library itself uses `XMLHttpRequest`, `HTMLElement`, `URL`, `JSON.parse`, `HTMLInputElement`, and so on.

Enforcing `XmlParser` and `loadHttpUrl` creates a jarring inconsistency against every platform type your code interacts with. You end up writing `const xmlParser = new XMLParser()` (because the dependency uses the standard convention) or forcing developers to mentally translate between two naming worlds within the same file.

The Google TypeScript Style Guide is cited as the source, and Google does indeed use this convention internally. But Google also rewrites platform types behind internal abstractions -- a luxury most teams do not have. The TypeScript compiler team itself does not follow this rule (see `TSConfig`, `AST`, `ESNext`, `ESModule` in the compiler source).

The guide does acknowledge "existing platform names like XMLHttpRequest" as an exception, but that exception swallows the rule in practice. HTTP, URL, JSON, HTML, CSS, DOM, API, SQL, XML, IO -- these acronyms appear constantly in typical TypeScript code.

### Recommendation

Preserve standard acronym casing in `PascalCase` identifiers (e.g., `HTTPClient`, `XMLParser`, `URLBuilder`). In `camelCase` identifiers, lowercase the acronym only when it appears at the start (`httpClient`, `urlBuilder`), but preserve it mid-identifier (`loadHTTPClient` or `loadHttpClient` -- either is fine, pick one and be consistent). Do not fight the platform.

---

## 2. Semicolons: "Always use explicit semicolons"

### Quoted guideline

> Always use explicit semicolons. Never rely on Automatic Semicolon Insertion (ASI).

### Why this is problematic

This is stated as an absolute rule with no acknowledgment that it is a stylistic preference with a legitimate, well-established alternative. The "no semicolons" style is used by significant parts of the ecosystem, including the Vue.js core team, Standard JS, and many prominent open-source projects. ASI is not a bug -- it is a well-specified part of the language with exactly three edge cases (lines starting with `(`, `[`, or a template literal), all of which are trivially caught by any linter or formatter.

More importantly, this is exactly the kind of bikeshed debate that the guide itself says to delegate to a formatter (Section 2 ends with "Use an automated formatter. Do not argue about formatting in code review. Let the tool decide."). The semicolon rule contradicts that philosophy. If you use Prettier or Biome, configure `semi: true` or `semi: false` and move on. Making it a style guide rule invites exactly the arguments the guide says to avoid.

### Recommendation

Remove the prescriptive rule. State that a consistent semicolon style should be enforced by the formatter, and that either `semi: true` or `semi: false` is acceptable as long as it is configured project-wide. The formatter handles this.

---

## 3. Single Quotes: "Use single quotes for strings"

### Quoted guideline

> Use single quotes for strings. Use template literals for interpolation or multiline strings. Reserve double quotes for JSX attributes (if applicable).

### Why this is problematic

Same issue as semicolons. This is a formatter concern, not a style guide concern. The guide undermines its own later advice ("Do not argue about formatting in code review. Let the tool decide.") by making a prescriptive choice here. Single quotes vs. double quotes has zero impact on code quality, readability, or correctness.

Additionally, "Reserve double quotes for JSX attributes" is wrong for a project that explicitly states it has zero dependencies and no JSX. It introduces irrelevant complexity.

### Recommendation

Delegate to the formatter. Remove the prescriptive choice. If the guide wants to offer a default, say "configure your formatter for consistent quote style" and note that single quotes are the most common convention in the TypeScript ecosystem.

---

## 4. Enum Members: `CONSTANT_CASE`

### Quoted guideline

> | Enum member | `CONSTANT_CASE` | `Direction.NORTH` |

And later:

> ```typescript
> '@typescript-eslint/naming-convention': [
>   'error',
>   { selector: 'enumMember', format: ['UPPER_CASE'] },
> ],
> ```

### Why this is problematic

The guide tells you to avoid enums entirely (Section 10: "Avoid... Traditional TypeScript `enum`s have several problems"), but then has a naming rule for enum members. This is contradictory. If enums are to be avoided, specifying their naming convention is noise.

More substantively, when enums are used (which they are, despite the guidance), `PascalCase` members are the dominant convention in the TypeScript ecosystem: `Status.Active`, `Direction.North`. `CONSTANT_CASE` is a Java/C# convention that looks foreign in TypeScript and conflicts with the guide's own alternative (`const STATUS = { Active: 'active', Inactive: 'inactive' } as const`), where the keys are `PascalCase`.

### Recommendation

Either remove the enum member naming convention entirely (since enums are discouraged) or, if retained, recommend `PascalCase` for enum members to match the TypeScript ecosystem and the guide's own `as const` pattern.

---

## 5. `exactOptionalPropertyTypes`: Recommended as default

### Quoted guideline

> ```jsonc
> "exactOptionalPropertyTypes": true,        // Distinguish omitted vs explicitly undefined
> ```

### Why this is problematic

`exactOptionalPropertyTypes` is one of the most disruptive tsconfig flags in practice. It breaks a very common JavaScript pattern: explicitly setting optional properties to `undefined` to clear them or reset them. Consider:

```typescript
interface User {
  name: string;
  nickname?: string;
}

// This is an error with exactOptionalPropertyTypes:
const user: User = { name: 'Alice', nickname: undefined };
```

This flag also breaks compatibility with most third-party type definitions, which were not written with it in mind. Libraries like React, Express, and Prisma will produce type errors. The TypeScript team deliberately did not include it in `strict: true` for this reason -- it is an experimental/advanced flag.

Recommending it as a default configuration, without prominent warning about the practical implications, will cause significant pain for teams adopting this guide. Most teams that enable it end up disabling it within weeks.

### Recommendation

Move `exactOptionalPropertyTypes` out of the recommended defaults and into a separate "advanced/optional flags" section with a warning about its compatibility implications. It is a good flag for greenfield projects with full type ownership, but not a safe default.

---

## 6. `skipLibCheck: true` recommended without caveat

### Quoted guideline

> ```jsonc
> "skipLibCheck": true,                      // Skip .d.ts checking for speed
> ```

### Why this is problematic

`skipLibCheck` is presented as a pure performance win ("Skip .d.ts checking for speed") with no mention of its tradeoff: it disables type checking of all `.d.ts` files, including your own declaration files. If you are writing a library and emit `.d.ts` files (which this same guide recommends with `"declaration": true`), `skipLibCheck` means your emitted declarations are never type-checked. You can ship broken type definitions to your consumers without the compiler catching it.

For application code consuming well-typed dependencies, `skipLibCheck` is fine. For library authors -- the very audience that would use `"declaration": true` -- it is dangerous.

### Recommendation

Keep the recommendation but add a clear caveat: `skipLibCheck` should be disabled (or at minimum tested without it) for library projects that emit `.d.ts` files. The speed gain is not worth shipping broken type declarations.

---

## 7. Named Exports Only: "Prefer named exports exclusively"

### Quoted guideline

> **Named Exports Only**
>
> Prefer named exports exclusively. Default exports lack a canonical name, making refactoring error-prone and imports inconsistent.

### Why this is problematic

This is stated too strongly. Default exports have legitimate, well-understood use cases:

1. **Framework conventions**: React components are conventionally default-exported (especially with `React.lazy`). Next.js pages, Remix routes, and Astro components require default exports. Svelte components use default exports. Fighting framework conventions creates friction for no benefit.

2. **Single-responsibility modules**: When a module has exactly one primary export (a class, a component, a factory function), a default export communicates that intent clearly. `import Formatter from './formatter'` is perfectly readable and refactorable -- modern IDEs track default imports just as reliably as named imports.

3. **Dynamic imports**: `import()` returns the module namespace, and default exports are accessed as `.default`. This is standard and well-supported.

The refactoring argument is overstated with modern tooling. TypeScript Language Server, VSCode, and WebStorm all handle default export renames correctly.

### Recommendation

Soften to "prefer named exports for modules with multiple exports" and acknowledge that default exports are appropriate for single-export modules and when required by framework conventions.

---

## 8. The `Result` Pattern Without Ecosystem Context

### Quoted guideline

> **The Result Pattern**
>
> For operations that can fail in expected ways, consider a discriminated union instead of throwing.

### Why this is problematic

The pattern shown is fine in isolation, but the guide does not address the elephant in the room: the JavaScript/TypeScript ecosystem is built on thrown errors. `JSON.parse` throws. `fetch` rejects. `fs.readFile` rejects. Every third-party library throws. If you adopt the Result pattern internally, you spend significant code at every boundary converting between thrown errors and Result types.

More critically, the pattern shown uses `{ ok: true; value: T } | { ok: false; error: E }` but does not mention that this is not standardized. There are at least four common Result encodings in the TypeScript ecosystem (`ok/error`, `success/failure`, `data/error`, `kind: 'success'/'error'`), plus libraries like `neverthrow`, `fp-ts Either`, `effect`, and `true-myth`. Introducing a bespoke Result type without acknowledging the ecosystem creates yet another incompatible variant.

The guide also does not mention that the TC39 proposal for `try` expressions and the recent `Promise.withResolvers` indicate the language is evolving but has not settled on a pattern yet.

### Recommendation

Keep the pattern as an option but add context: (1) it requires disciplined boundary conversion since the ecosystem throws, (2) consider using an established library like `neverthrow` if adopting this pattern at scale, and (3) for small projects or utility libraries, thrown errors with proper typing (via `@throws` JSDoc or documented error types) are pragmatically simpler.

---

## 9. Overloads: Bad example is actually fine

### Quoted guideline

> ```typescript
> // Bad: overload not needed (same return type)
> function format(value: string): string;
> function format(value: number): string;
> function format(value: string | number): string { }
>
> // Good: use union instead
> function format(value: string | number): string { }
> ```

### Why this is problematic

The "bad" example is not categorically bad. Overloads with the same return type are still useful when the function has different behavior per input type that callers need to understand from the signature. Overloads appear in IDE intellisense as separate entries, which can provide better documentation than a union parameter.

More importantly, overloads are useful when the implementation needs different parameter counts or shapes:

```typescript
function createElement(tag: string): HTMLElement;
function createElement(tag: string, props: Props): HTMLElement;
function createElement(tag: string, props?: Props): HTMLElement { ... }
```

The guide's rule ("Use overloads when the return type depends on the input type") is too narrow. The actual heuristic should be: use overloads when distinct call signatures have meaningfully different contracts, whether that difference is in return type, parameter shape, or documented behavior.

### Recommendation

Replace the "same return type means no overload" heuristic with: "prefer union parameters over overloads when the function handles all input types uniformly. Use overloads when distinct call signatures represent meaningfully different contracts (different return types, different parameter shapes, or different documented behaviors)."

---

## 10. `DeepReadonly<T>` implementation is incorrect

### Quoted guideline

> ```typescript
> type DeepReadonly<T> = {
>   readonly [K in keyof T]: T[K] extends object ? DeepReadonly<T[K]> : T[K];
> };
> ```

### Why this is problematic

This implementation is buggy. The `extends object` check matches arrays, functions, `Date`, `RegExp`, `Map`, `Set`, and every other non-primitive. This means:

- `DeepReadonly<{ fn: () => void }>` tries to recursively make function properties readonly, which produces nonsensical types.
- `DeepReadonly<{ d: Date }>` makes `Date` properties readonly, which strips its methods from the type.
- `DeepReadonly<{ items: string[] }>` produces `{ readonly items: { readonly [x: number]: string; ... } }` which is not `ReadonlyArray<string>` and does not prevent `.push()`.

A correct implementation needs to handle arrays, functions, primitives, and built-in objects as special cases. This is precisely why the guide's own advice to use `ts-essentials` is correct -- but showing a broken implementation right before that recommendation undermines confidence.

### Recommendation

Remove the inline `DeepReadonly` implementation. It is wrong and will be copy-pasted. Simply recommend `ts-essentials`'s `DeepReadonly` or show the correct (much longer) implementation that handles arrays, Maps, Sets, Dates, functions, and primitives. If brevity is required, just show:

```typescript
// For deep immutability, use a well-tested library:
import type { DeepReadonly } from 'ts-essentials';
```

But even this contradicts the project's zero-dependency rule. A better approach: recommend `Readonly<T>` for shallow cases and note that deep immutability requires a more complex type (link to `ts-essentials` as reference, not dependency).

---

## 11. `Object.freeze` section is misleading

### Quoted guideline

> **`Object.freeze` at Runtime**
>
> TypeScript's `readonly` is compile-time only. For true runtime immutability, combine with `Object.freeze`.
>
> ```typescript
> const DEFAULTS = Object.freeze({
>   locale: 'en',
>   maxAge: 120,
> });
> // DEFAULTS.locale = 'fr' -- runtime error in strict mode
> ```
>
> Note: `Object.freeze` is shallow. It does not freeze nested objects.

### Why this is problematic

The guidance to "combine `readonly` with `Object.freeze`" for "true runtime immutability" is misleading in several ways:

1. `Object.freeze` only throws in strict mode. In sloppy mode, the assignment silently fails. The guide does not mention this.
2. The guide just told you to use `as const` (compile-time, zero cost) and `readonly` (compile-time, zero cost). Adding `Object.freeze` (runtime cost, no deep support, no performance benefit) for the same protection is redundant if you trust your type system -- and this guide says you should.
3. `Object.freeze` has a real performance cost: it transitions the object to a different V8 hidden class, preventing certain optimizations. For hot paths, this matters.
4. The "shallow" caveat is mentioned but not addressed. Without `deepFreeze`, this gives a false sense of security for nested objects -- exactly the case where you would want runtime protection.

### Recommendation

Reframe the section. `Object.freeze` is useful at module boundaries where frozen config objects cross trust boundaries (e.g., plugin APIs). For internal code, `as const` + `readonly` is sufficient and has zero runtime cost. Do not recommend combining them routinely -- it is belt and suspenders with a performance cost.

---

## 12. `void` operator for floating promises

### Quoted guideline

> ```typescript
> // Good: explicit discard
> void fetchData();
> ```

### Why this is problematic

Using the `void` operator to suppress `no-floating-promises` is an anti-pattern disguised as a pattern. It tells the linter "I know this promise is floating and I don't care," but floating promises are floating for a reason: if `fetchData()` rejects, the rejection is unhandled and becomes an `unhandledrejection` event (which crashes Node.js by default since v15).

The `void` operator does not add error handling. It does not add a `.catch()`. It simply silences the linter. This is categorically different from `await fetchData()` or `fetchData().catch(handleError)`, both of which actually handle the promise.

The only legitimate use case for `void promise` is fire-and-forget side effects where you have a top-level `unhandledrejection` handler that catches everything. That context is not mentioned.

### Recommendation

Remove `void fetchData()` as a "Good" example. Replace with:

```typescript
// Good: awaited
await fetchData();

// Good: error handled
fetchData().catch(handleError);

// Acceptable in rare fire-and-forget cases with a global rejection handler:
void fetchData();
```

---

## 13. Missing: `import` assertion / `import` attribute syntax

The guide covers `import type` but does not mention `import ... with { type: 'json' }` (import attributes, Stage 3 TC39, supported in Node 22+ and TypeScript 5.3+). For a project that imports JSON locale files, this is directly relevant. The older `import ... assert { type: 'json' }` syntax is deprecated in favor of `with`.

### Recommendation

Add a note in the Module Design section about import attributes for JSON imports, since this is relevant to the project's locale handling.

---

## 14. Missing: Testing guidance

The guide covers 11 sections but says nothing about testing. For a project where "spec-first testing" is a core principle and every implementation must match `tests.json`, this is a significant omission. There is no mention of:

- Test file naming and organization
- Test framework choice (Vitest is shown in the CI section but never discussed)
- Assertion patterns (expect vs. assert, custom matchers)
- Test structure (describe/it/test conventions)
- How to handle the project's spec-driven test ID annotation requirement

### Recommendation

Add a Testing section that addresses test structure, framework conventions, and the project-specific requirement of annotating tests with canonical IDs from `tests.json`.

---

## Summary

The guide is well-structured and covers most important topics. The core issues are:

1. **Contradicts itself** on formatter delegation (prescribes semicolons and quotes, then says "let the tool decide")
2. **Fights the platform** on acronym casing
3. **Recommends a dangerous default** with `exactOptionalPropertyTypes` and does not caveat `skipLibCheck` for library authors
4. **Shows broken code** in the `DeepReadonly` example
5. **Presents anti-patterns as patterns** (`void` for floating promises)
6. **Overstates positions** on default exports, overloads, and the Result pattern
7. **Missing sections** on testing and import attributes
