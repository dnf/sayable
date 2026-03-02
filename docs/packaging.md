# Packaging and locale subsetting

## How locale data is packaged

Every implementation ships all 71 locales by default. Each locale is a data object containing translated strings, plural rules, and formatting stages — roughly 1–2 KB per locale depending on the language.

The table below summarizes how each language structures its locale data:

| Language   | File layout                                  | Initialization                      | Lookup via `getLocale`  |
| ---------- | -------------------------------------------- | ----------------------------------- | ----------------------- |
| TypeScript | 71 individual ES modules + barrel `index.ts` | Eager (module-level `const`)        | `_ALL` Record           |
| Python     | 71 individual modules + `__init__.py` barrel | Eager (module-level assignment)     | `_ALL` dict             |
| Go         | 71 individual files in one package           | Eager (package-level `var`)         | `switch` statement      |
| Ruby       | 71 individual files, glob-required           | Eager (`Dir[].each { require }`)    | `case`/`when`           |
| Rust       | 71 individual modules + `mod.rs` barrel      | Lazy (`LazyLock`)                   | `match` expression      |
| Kotlin     | Single file (`Locales.kt`)                   | Eager (`val` on `object`)           | `ALL` map lookup        |
| C++        | 4 source files by alpha range + header       | Lazy (function-scoped `static`)     | `if`-chain              |
| PHP        | Single file (`Locales.php`)                  | Lazy (`??=` pattern)                | `match` expression      |
| Java       | Single file (`Locales.java`)                 | Eager (`static final` fields)       | `ALL` map lookup        |
| C#         | Single file (`Locales.cs`)                   | Eager (`static readonly` fields)    | `All` dictionary lookup |
| Elm        | 71 individual modules + `Locales.elm` barrel | Eager (module-level `locale` value) | `Dict.get` lookup       |
| Scala      | Single file (`Locales.scala`)                | Eager (`val` on `object`)           | `ALL` map lookup        |
| Swift      | Single file (`Locales.swift`)                | Eager (static `let` properties)     | `all` dictionary lookup |
| Zig        | Single file (`locales.zig`)                  | Eager (comptime `const`)            | `if`-chain              |

## Rationale

This design optimizes for simplicity and correctness:

1. **Zero configuration.** Install the package, import a locale by name, and call `formatAge`. No build plugins, no async loading, no registration step.

2. **Zero runtime dependencies.** Everything is self-contained data. No ICU, no CLDR runtime, no i18n framework.

3. **Identical behavior across all languages.** The codegen system generates locale data from a single set of JSON source files. Every language gets the same locales with the same data. Codegen subsetting (below) applies equally to all targets.

4. **Predictability.** There is no lazy network fetch, no dynamic `require`, and no locale-not-found error at runtime for published locales. If the code compiles, the locale is available.

The tradeoff is bundle size: all 71 locales are included whether you use them or not. The subsetting system described below addresses this.

## How `getLocale` defeats tree shaking

`getLocale("fr")` is convenient — you pass a string and get back a locale object. But it has a structural cost: the lookup function must reference every locale at once.

In TypeScript, the generated barrel file looks like this:

```typescript
import { am } from './am.js';
import { ar } from './ar.js';
// ... 69 more imports ...

const _ALL: Record<string, AgeLocale> = { am, ar, /* ... */ };

export function getLocale(code: string): AgeLocale | undefined {
  return _ALL[code];
}

export { am, ar, /* ... */ };
```

The `_ALL` map captures a reference to every locale constant. A bundler cannot remove any locale from the map because `getLocale` accepts an arbitrary string — the bundler cannot prove at build time that `getLocale("sw")` will never be called. This makes `_ALL` and all 71 imports it depends on non-tree-shakeable.

The same problem exists in every language: Go's `switch`, Rust's `match`, C++'s `if`-chain, and the equivalent structures in Python, Ruby, Kotlin, PHP, C#, Java, Scala, and Swift all reference every locale, making them all reachable from the lookup function.

**TypeScript is the only language where this distinction matters at the bundler level.** When a user imports individual locale constants (`import { en, fr } from 'parent-time'`) without importing `getLocale`, a bundler with tree shaking (webpack, Rollup, esbuild) can eliminate the 69 unused locales — the `sideEffects: false` declaration in `package.json` enables this. But importing `getLocale` from the same barrel pulls in the entire `_ALL` map and with it every locale.

The other languages have no equivalent mechanism. Their package managers and runtimes load entire modules, packages, or classes — not individual symbols.

## Does the engineer need to do anything?

| Language   | Unused locales eliminated automatically?                                                                              | Action required                                                     |
| ---------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| TypeScript | **Yes**, if you import individual locales without `getLocale` and use a tree-shaking bundler                          | None, *unless* you import `getLocale` — then use codegen subsetting |
| Python     | No                                                                                                                    | Use codegen subsetting                                              |
| Go         | No                                                                                                                    | Use codegen subsetting                                              |
| Ruby       | No                                                                                                                    | Use codegen subsetting                                              |
| Rust       | No in library builds; partial in optimized binaries via LLVM LTO if `get()` is unused                                 | Use codegen subsetting                                              |
| Kotlin     | No                                                                                                                    | Use codegen subsetting                                              |
| C++        | No in library builds; partial in optimized binaries with `-ffunction-sections` + `--gc-sections` if `get()` is unused | Use codegen subsetting                                              |
| PHP        | No                                                                                                                    | Use codegen subsetting                                              |
| Java       | No                                                                                                                    | Use codegen subsetting                                              |
| C#         | No                                                                                                                    | Use codegen subsetting                                              |
| Elm        | No                                                                                                                    | Use codegen subsetting                                              |
| Scala      | No                                                                                                                    | Use codegen subsetting                                              |
| Swift      | No                                                                                                                    | Use codegen subsetting                                              |
| Zig        | No                                                                                                                    | Use codegen subsetting                                              |

In practice, **codegen subsetting is the only reliable way to eliminate unused locales** and it works identically for all languages.

## Codegen subsetting

The `--locales` flag on the code generator rebuilds all language targets with only the locales you specify:

```bash
python -m codegen.generate --locales fr          # en + fr (en is always included)
python -m codegen.generate --locales core         # top 10 by internet users
python -m codegen.generate --locales cjk,romance  # combine named groups
```

This regenerates every generated file — locale source files, barrel/registry files, and the `getLocale` lookup — containing only the selected locales. Stale per-file locale files from a previous generation are automatically deleted.

Named groups are defined in `codegen/locale_groups.py`:

| Group             | Count | Locales                                                                                                                                                |
| ----------------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `core`            | 10    | ar, de, en, es, fr, hi, ja, pt, ru, zh                                                                                                                 |
| `european`        | 38    | bg, br, bs, ca, cs, cy, da, de, el, en, es, et, eu, fi, fr, ga, gd, gv, hr, hu, it, kw, lt, lv, mk, mt, nb, nl, pl, pt, ro, ru, sk, sl, sq, sr, sv, uk |
| `cjk`             | 3     | ja, ko, zh                                                                                                                                             |
| `south-asian`     | 10    | bn, gu, hi, mr, ne, pa, si, ta, te, ur                                                                                                                 |
| `middle-eastern`  | 4     | ar, fa, he, tr                                                                                                                                         |
| `nordic`          | 4     | da, fi, nb, sv                                                                                                                                         |
| `slavic`          | 11    | bg, bs, cs, hr, mk, pl, ru, sk, sl, sr, uk                                                                                                             |
| `romance`         | 6     | ca, es, fr, it, pt, ro                                                                                                                                 |
| `germanic`        | 6     | da, de, en, nb, nl, sv                                                                                                                                 |
| `southeast-asian` | 8     | fil, id, jv, km, ms, my, th, vi                                                                                                                        |

Use `python -m codegen.generate --list-groups` to see the full list.

To restore all 71 locales, run `python -m codegen.generate` with no `--locales` flag.
