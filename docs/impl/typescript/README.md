# TypeScript Style Guide

A comprehensive, opinionated style guide for auditing TypeScript implementations. Each section includes rationale, code examples, and links to authoritative sources.

## Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Code Formatting](#2-code-formatting)
3. [Type System](#3-type-system)
4. [Strict Mode](#4-strict-mode)
5. [Function Design](#5-function-design)
6. [Error Handling](#6-error-handling)
7. [Module Design](#7-module-design)
8. [Immutability](#8-immutability)
9. [Common Idioms](#9-common-idioms)
10. [Things to Avoid](#10-things-to-avoid)
11. [Tooling](#11-tooling)

---

## 1. Naming Conventions

### Summary Table

| Identifier           | Convention       | Example                          |
| -------------------- | ---------------- | -------------------------------- |
| Local variable       | `camelCase`      | `userCount`, `filteredItems`     |
| Function             | `camelCase`      | `formatAge`, `getUserById`       |
| Parameter            | `camelCase`      | `dateOfBirth`, `localeCode`      |
| Boolean variable     | `camelCase`      | `isValid`, `hasExpired`          |
| Global constant      | `CONSTANT_CASE`  | `MAX_RETRIES`, `DEFAULT_LOCALE`  |
| Class                | `PascalCase`     | `AgeFormatter`, `HttpClient`     |
| Interface            | `PascalCase`     | `AgeLocale`, `FormatOptions`     |
| Type alias           | `PascalCase`     | `PluralCategory`, `DatePair`     |
| Enum                 | `PascalCase`     | `Direction` (prefer unions)      |
| Enum member          | `CONSTANT_CASE`  | `Direction.NORTH`                |
| Generic parameter    | `PascalCase`     | `T`, `TResult`, `TKey`          |
| File name            | `kebab-case`     | `format-age.ts`, `age-locale.ts` |
| Test file            | `kebab-case`     | `format-age.test.ts`             |

### Detailed Rules

**No Hungarian notation or interface prefixes.** Do not prefix interfaces with `I` or types with `T`. The type system itself communicates what something is.

```typescript
// Bad
interface IUserService { }
type TUserRole = "admin" | "viewer";

// Good
interface UserService { }
type UserRole = "admin" | "viewer";
```

**Treat abbreviations and acronyms as single words.** Capitalize only the first letter.

```typescript
// Bad
let loadHTTPURL: string;
class XMLParser { }

// Good
let loadHttpUrl: string;
class XmlParser { }

// Exception: existing platform names like XMLHttpRequest
```

**Boolean variables use verb prefixes** (`is`, `has`, `can`, `should`, `did`, `will`).

```typescript
const isExpired = age > maxAge;
const hasLocale = localeMap.has(code);
const canRetry = attempts < MAX_RETRIES;
```

**Never use leading or trailing underscores.** TypeScript visibility modifiers (`private`, `protected`) make this unnecessary.

```typescript
// Bad
private _name: string;
let __count = 0;

// Good
private name: string;
let count = 0;
```

**Generic type parameters** should be a single uppercase letter for simple cases (`T`, `K`, `V`) or `PascalCase` with a `T` prefix for descriptive names (`TResult`, `TLocale`).

```typescript
function map<T, TResult>(items: T[], fn: (item: T) => TResult): TResult[] { }
```

### Sources

- [Google TypeScript Style Guide: Naming](https://google.github.io/styleguide/tsguide.html#naming-style)
- [typescript-eslint naming-convention rule](https://typescript-eslint.io/rules/naming-convention/)

---

## 2. Code Formatting

### Indentation and Line Length

- **Indentation:** 2 spaces (no tabs). This is the dominant convention in the TypeScript ecosystem.
- **Line length:** 80-100 characters. Configure your formatter. 80 is traditional; 100 is practical for modern displays.
- **Trailing newline:** Every file ends with a single newline.

### Semicolons

Always use explicit semicolons. Never rely on Automatic Semicolon Insertion (ASI).

```typescript
// Bad: relies on ASI
const x = 5
const y = getValue()

// Good
const x = 5;
const y = getValue();
```

### Quotes

Use single quotes for strings. Use template literals for interpolation or multiline strings. Reserve double quotes for JSX attributes (if applicable).

```typescript
const greeting = 'hello';
const message = `Hello, ${name}`;
```

### Braces

Always use braces for control flow, even for single-statement bodies.

```typescript
// Bad
if (isValid) return result;

// Good
if (isValid) {
  return result;
}
```

### Trailing Commas

Use trailing commas in multiline constructs (arrays, objects, parameters, arguments). They produce cleaner diffs.

```typescript
const locales = [
  'en',
  'fr',
  'de', // <-- trailing comma
];

function format(
  dateOfBirth: Date,
  asOf: Date,
  locale: string, // <-- trailing comma
): string { }
```

### Import Ordering

Sort imports in a consistent order. A common convention:

1. External/node modules
2. Internal/project modules
3. Relative imports
4. Type-only imports last (or grouped with their source)

Separate groups with a blank line.

```typescript
import { readFile } from 'node:fs/promises';

import { formatDate } from '@project/utils';

import { AgeLocale } from './locale';
import type { PluralCategory } from './types';
```

### Formatter and Linter Configuration

Use an automated formatter. Do not argue about formatting in code review. Let the tool decide.

**Prettier** (most popular):
```json
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 80,
  "tabWidth": 2
}
```

**Biome** (faster alternative):
```json
{
  "formatter": {
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 80
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "single",
      "trailingCommas": "all",
      "semicolons": "always"
    }
  }
}
```

### Sources

- [Prettier: Options](https://prettier.io/docs/en/options.html)
- [Biome: Configuration](https://biomejs.dev/reference/configuration/)
- [Google TypeScript Style Guide: Formatting](https://google.github.io/styleguide/tsguide.html#formatting)

---

## 3. Type System

### Interfaces vs Type Aliases

**Use interfaces for object shapes.** Interfaces are faster for the compiler (they create a single flat object type with cached relationships), produce better error messages, and support declaration merging.

```typescript
// Preferred: interface for object shapes
interface AgeLocale {
  readonly code: string;
  readonly units: ReadonlyArray<string>;
  readonly halfMarker: string;
}

// Use type aliases for unions, intersections, mapped types, and primitives
type PluralCategory = 'zero' | 'one' | 'two' | 'few' | 'many' | 'other';
type Milliseconds = number;
type FormatResult = Success | Failure;
```

**Prefer `extends` over intersection for composition.** Intersections recursively merge properties and are harder for the compiler to cache.

```typescript
// Bad: intersection for object composition
type Animal = LivingThing & { species: string };

// Good: interface extension
interface Animal extends LivingThing {
  species: string;
}
```

### Discriminated Unions

Use a literal discriminator property (`kind`, `type`, `status`) to model variants. This enables exhaustive pattern matching and type narrowing.

```typescript
type Result<T> =
  | { kind: 'success'; value: T }
  | { kind: 'error'; message: string };

function handle<T>(result: Result<T>): void {
  switch (result.kind) {
    case 'success':
      console.log(result.value); // T
      break;
    case 'error':
      console.error(result.message); // string
      break;
    default:
      // Exhaustiveness check: if a new variant is added,
      // this line produces a compile error
      const _exhaustive: never = result;
  }
}
```

### Utility Types

Use built-in utility types instead of hand-rolling equivalents.

| Utility                          | Purpose                                    |
| -------------------------------- | ------------------------------------------ |
| `Partial<T>`                     | All properties optional                    |
| `Required<T>`                    | All properties required                    |
| `Readonly<T>`                    | All properties readonly                    |
| `Pick<T, Keys>`                  | Subset of properties                       |
| `Omit<T, Keys>`                  | All properties except specified            |
| `Record<Keys, Value>`            | Object type from key union and value type  |
| `Exclude<Union, Members>`        | Remove members from union                  |
| `Extract<Union, Members>`        | Keep only matching members from union      |
| `NonNullable<T>`                 | Remove `null` and `undefined` from union   |
| `ReturnType<F>`                  | Extract return type from function type     |
| `Parameters<F>`                  | Extract parameter types as tuple           |
| `Awaited<T>`                     | Unwrap Promise type                        |

### Mapped Types

Use mapped types to derive new types from existing ones systematically.

```typescript
// Make all properties optional and nullable
type Draft<T> = {
  [K in keyof T]?: T[K] | null;
};

// Rename properties with template literals
type Getters<T> = {
  [K in keyof T as `get${Capitalize<K & string>}`]: () => T[K];
};
```

### Conditional Types

Use conditional types for type-level branching. Extract sub-types with the `infer` keyword.

```typescript
// Extract the element type from an array, or return T unchanged
type Flatten<T> = T extends ReadonlyArray<infer U> ? U : T;

type A = Flatten<string[]>;    // string
type B = Flatten<number>;      // number
```

**Name complex conditional types.** Inline conditional types are hard to read and prevent the compiler from caching results.

```typescript
// Bad: inline, hard to read, recomputed every time
interface Parser<T> {
  parse<U>(input: U): U extends string ? T : never;
}

// Good: named, cacheable
type ParseResult<U, T> = U extends string ? T : never;
interface Parser<T> {
  parse<U>(input: U): ParseResult<U, T>;
}
```

### Template Literal Types

Construct precise string types using template literal syntax.

```typescript
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';
type ApiPath = `/api/${string}`;
type Endpoint = `${HttpMethod} ${ApiPath}`;

// Intrinsic string manipulation
type EventName = 'click' | 'focus';
type Handler = `on${Capitalize<EventName>}`; // 'onClick' | 'onFocus'
```

### Array Type Syntax

Use `T[]` for simple element types. Use `Array<T>` for complex element types where `[]` would be ambiguous.

```typescript
// Simple: use shorthand
let names: string[];
let matrix: number[][];
let items: readonly string[];

// Complex: use generic form
let mixed: Array<string | number>;
let records: Array<{ id: number; name: string }>;
let nested: ReadonlyArray<Map<string, number>>;
```

### Sources

- [TypeScript Handbook: Everyday Types](https://www.typescriptlang.org/docs/handbook/2/everyday-types.html)
- [TypeScript Handbook: Type Manipulation](https://www.typescriptlang.org/docs/handbook/2/types-from-types.html)
- [TypeScript Performance Wiki: Interfaces vs Intersections](https://github.com/microsoft/TypeScript/wiki/Performance#preferring-interfaces-over-intersections)
- [Total TypeScript: Deriving Types](https://www.totaltypescript.com/books/total-typescript-essentials/deriving-types)

---

## 4. Strict Mode

### Recommended `tsconfig.json`

Enable maximum type safety. Every project should start with `strict: true` and add additional strict flags on top.

```jsonc
{
  "compilerOptions": {
    // -- Strict type checking --
    "strict": true,                           // Enables all strict sub-flags
    "noUncheckedIndexedAccess": true,          // Index signatures include undefined
    "exactOptionalPropertyTypes": true,        // Distinguish omitted vs explicitly undefined
    "noImplicitOverride": true,                // Require 'override' keyword on overrides
    "noPropertyAccessFromIndexSignature": true, // Require bracket notation for index sigs
    "noImplicitReturns": true,                 // Every code path must return
    "noFallthroughCasesInSwitch": true,        // No implicit switch fallthrough

    // -- Module resolution --
    "module": "esnext",                        // ES module output (or "nodenext" for Node)
    "moduleResolution": "bundler",             // (or "nodenext" for Node projects)
    "isolatedModules": true,                   // Ensure files can be independently transpiled
    "esModuleInterop": true,                   // CommonJS/ESM interop

    // -- Emit --
    "target": "es2022",                        // Modern baseline
    "declaration": true,                       // Emit .d.ts files for libraries
    "sourceMap": true,                         // Debugging support

    // -- Consistency --
    "forceConsistentCasingInFileNames": true,  // Prevent case-sensitivity bugs
    "skipLibCheck": true,                      // Skip .d.ts checking for speed
    "verbatimModuleSyntax": true               // Enforce import type / export type
  }
}
```

### What `strict: true` Enables

The `strict` flag is a shorthand that enables all of the following:

| Flag                            | Effect                                                    |
| ------------------------------- | --------------------------------------------------------- |
| `noImplicitAny`                 | Error when a type is inferred as `any`                    |
| `noImplicitThis`                | Error when `this` has an implicit `any` type              |
| `strictNullChecks`              | `null` and `undefined` are distinct types                 |
| `strictFunctionTypes`           | Contravariant parameter checking for functions            |
| `strictBindCallApply`           | Type-check `bind`, `call`, `apply`                        |
| `strictPropertyInitialization`  | Class properties must be initialized or declared optional |
| `useUnknownInCatchVariables`    | Catch variables are `unknown` instead of `any`            |
| `alwaysStrict`                  | Emit `"use strict"` in every file                         |

### Key Flags Beyond `strict`

**`noUncheckedIndexedAccess`** -- Adds `| undefined` when accessing index signatures. This catches a very common class of runtime errors.

```typescript
const map: Record<string, number> = {};
const value = map['key'];
//    ^? number | undefined  (with noUncheckedIndexedAccess)
//    ^? number              (without -- dangerous!)
```

**`exactOptionalPropertyTypes`** -- Distinguishes between "property missing" and "property is `undefined`".

```typescript
interface Config {
  debug?: boolean;
}

const config: Config = { debug: undefined };
//    Error with exactOptionalPropertyTypes:
//    undefined is not assignable to boolean
//    Omit the property entirely instead
```

**`verbatimModuleSyntax`** -- Replaces the older `importsNotUsedAsValues` and `preserveValueImports`. Forces you to use `import type` for type-only imports, which is enforced at the syntax level.

### Sources

- [TypeScript TSConfig Reference](https://www.typescriptlang.org/tsconfig)
- [Total TypeScript: TSConfig Cheat Sheet](https://www.totaltypescript.com/tsconfig-cheat-sheet)

---

## 5. Function Design

### Prefer Function Declarations

Use function declarations for top-level named functions. They are hoisted and produce clearer stack traces.

```typescript
// Preferred
function formatAge(dateOfBirth: Date, asOf: Date): string { }

// Arrow functions for callbacks and short expressions
const doubled = values.map((v) => v * 2);
```

### Return Type Annotations

Annotate return types on public API functions and exported functions. This catches accidental changes and produces better error locations. For internal helpers, inference is acceptable.

```typescript
// Public API: annotate return type
export function formatAge(dob: Date, asOf: Date, locale: string): string {
  // ...
}

// Internal helper: inference is fine
function daysBetween(a: Date, b: Date) {
  return Math.floor((b.getTime() - a.getTime()) / 86_400_000);
}
```

### Overloads

Use overloads when the return type depends on the input type. Place the implementation signature last. Prefer union types over overloads when the return type does not depend on the input.

```typescript
// Good: overload because return type depends on input
function parse(input: string): Date;
function parse(input: number): Date;
function parse(input: string | number): Date {
  if (typeof input === 'string') {
    return new Date(input);
  }
  return new Date(input);
}

// Bad: overload not needed (same return type)
function format(value: string): string;
function format(value: number): string;
function format(value: string | number): string { }

// Good: use union instead
function format(value: string | number): string { }
```

### Generic Functions

Use generics when the function relates input types to output types. If a generic parameter appears only once, you probably do not need it.

```typescript
// Good: T relates input to output
function first<T>(items: readonly T[]): T | undefined {
  return items[0];
}

// Bad: T appears only once, adds no value
function print<T>(value: T): void {
  console.log(value);
}

// Good: just use the concrete type
function print(value: unknown): void {
  console.log(value);
}
```

### Readonly Parameters

Mark array and object parameters as `readonly` when the function does not mutate them.

```typescript
function sum(values: readonly number[]): number {
  return values.reduce((a, b) => a + b, 0);
}

function getName(user: Readonly<User>): string {
  return user.name;
}
```

### Rest Parameters

Use rest parameters instead of the `arguments` object.

```typescript
// Good
function log(message: string, ...args: unknown[]): void {
  console.log(message, ...args);
}

// Bad: arguments is untyped
function log(message: string): void {
  console.log(message, arguments);
}
```

### Single Object Parameter

When a function takes more than 2-3 parameters, prefer a single options object. This is self-documenting at call sites and extensible without breaking callers.

```typescript
// Bad: positional parameters are unclear at call sites
function createUser(name: string, email: string, role: string, active: boolean) { }
createUser('Alice', 'a@b.com', 'admin', true); // What is true?

// Good: options object
interface CreateUserOptions {
  name: string;
  email: string;
  role: UserRole;
  active: boolean;
}
function createUser(options: CreateUserOptions) { }
createUser({ name: 'Alice', email: 'a@b.com', role: 'admin', active: true });
```

### Sources

- [Google TypeScript Style Guide: Functions](https://google.github.io/styleguide/tsguide.html#functions)
- [TypeScript Handbook: More on Functions](https://www.typescriptlang.org/docs/handbook/2/functions.html)
- [TypeScript Handbook: Do's and Don'ts](https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html)

---

## 6. Error Handling

### Always Throw `Error` Objects

Never throw strings or plain objects. Only `Error` instances (or subclasses) produce stack traces.

```typescript
// Bad: no stack trace
throw 'something went wrong';
throw { code: 404 };

// Good
throw new Error('something went wrong');
throw new NotFoundError('user not found');
```

### Use `unknown` in Catch Blocks

With `strict: true` (specifically `useUnknownInCatchVariables`), caught errors are typed as `unknown`. Always narrow before accessing properties.

```typescript
try {
  riskyOperation();
} catch (error: unknown) {
  if (error instanceof Error) {
    console.error(error.message);
  } else {
    console.error('Unknown error', error);
  }
}
```

### Assertion Functions

Use assertion functions (`asserts` keyword) for precondition checks that narrow types in the calling scope.

```typescript
function assertIsString(value: unknown): asserts value is string {
  if (typeof value !== 'string') {
    throw new TypeError(`Expected string, got ${typeof value}`);
  }
}

function processInput(input: unknown): void {
  assertIsString(input);
  // input is narrowed to string here
  console.log(input.toUpperCase());
}
```

### The Result Pattern

For operations that can fail in expected ways, consider a discriminated union instead of throwing. This makes error handling explicit in the type system.

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function parseAge(input: string): Result<number> {
  const n = Number(input);
  if (Number.isNaN(n) || n < 0) {
    return { ok: false, error: new Error(`Invalid age: ${input}`) };
  }
  return { ok: true, value: n };
}

const result = parseAge(userInput);
if (result.ok) {
  console.log(result.value); // number
} else {
  console.error(result.error.message); // Error
}
```

### Handle Promises Properly

Never leave a Promise floating. Always `await` it, return it, or explicitly discard it with `void`.

```typescript
// Bad: floating promise (silent failure)
fetchData();

// Good
await fetchData();

// Good: explicit discard
void fetchData();
```

The `@typescript-eslint/no-floating-promises` rule enforces this.

### Sources

- [Google TypeScript Style Guide: Exceptions](https://google.github.io/styleguide/tsguide.html#exceptions)
- [typescript-eslint: no-floating-promises](https://typescript-eslint.io/rules/no-floating-promises/)

---

## 7. Module Design

### Use ES Modules

Always use `import`/`export`. Never use `require()`, `module.exports`, or `namespace`.

```typescript
// Bad
const fs = require('fs');
namespace Utils { }

// Good
import { readFile } from 'node:fs/promises';
```

### Named Exports Only

Prefer named exports exclusively. Default exports lack a canonical name, making refactoring error-prone and imports inconsistent.

```typescript
// Bad
export default function formatAge() { }
// Importers can name it anything: import blah from './format-age'

// Good
export function formatAge() { }
// Importers must use the real name: import { formatAge } from './format-age'
```

### Type-Only Imports and Exports

Use `import type` for imports used only in type positions. This ensures they are erased at runtime and clarifies intent.

```typescript
import type { AgeLocale } from './locale';
import { formatAge } from './format-age';

// Or combined syntax
import { formatAge, type AgeLocale } from './module';

// Re-exporting types
export type { AgeLocale };
```

With `verbatimModuleSyntax` enabled in tsconfig, this is enforced automatically.

### Barrel Exports

Use barrel files (`index.ts`) sparingly. They can cause circular dependencies and bloat bundle sizes by pulling in entire modules. When you do use them, keep them thin.

```typescript
// age/index.ts -- barrel file
export { formatAge } from './format-age';
export type { AgeLocale } from './locale';
export type { PluralCategory } from './types';
```

For internal code, prefer direct imports over barrels.

### Declaration Files (`.d.ts`)

For libraries, emit `.d.ts` declaration files with `"declaration": true` in tsconfig. Hand-written `.d.ts` files are appropriate for typing external untyped libraries or augmenting existing types.

Never put implementation logic in `.d.ts` files. They are type-only.

### No Mutable Exports

Never use `export let`. If external code needs a changing value, export a getter function.

```typescript
// Bad: mutable export
export let currentLocale = 'en';

// Good: getter
let currentLocale = 'en';
export function getCurrentLocale(): string {
  return currentLocale;
}
```

### Sources

- [Google TypeScript Style Guide: Exports](https://google.github.io/styleguide/tsguide.html#exports)
- [TypeScript Handbook: Modules](https://www.typescriptlang.org/docs/handbook/2/modules.html)

---

## 8. Immutability

### `const` Over `let`

Use `const` by default. Use `let` only when reassignment is required. Never use `var`.

```typescript
const name = 'Alice';    // Good: never reassigned
let count = 0;           // Good: reassigned in loop below
count += 1;

var legacy = 'no';       // Bad: function-scoped, confusing
```

### `as const` Assertions

Use `const` assertions to narrow literals and make objects/arrays deeply readonly.

```typescript
// Without: type is string[]
const roles = ['admin', 'viewer'];

// With: type is readonly ['admin', 'viewer']
const roles = ['admin', 'viewer'] as const;

// Works on objects too
const config = {
  maxRetries: 3,
  timeout: 5000,
} as const;
// config.maxRetries is literal type 3, not number
```

### `readonly` Properties

Mark class and interface properties as `readonly` when they should not change after initialization.

```typescript
interface AgeLocale {
  readonly code: string;
  readonly units: ReadonlyArray<string>;
}

class Formatter {
  constructor(private readonly locale: AgeLocale) { }
}
```

### `Readonly<T>` and `ReadonlyArray<T>`

Use these utility types for function parameters and return types to prevent mutation.

```typescript
function processLocales(locales: ReadonlyArray<AgeLocale>): void {
  // locales.push(...) -- compile error
  // locales[0] = ...  -- compile error
}

function getConfig(): Readonly<Config> {
  return config; // Caller cannot modify
}
```

For deeply nested structures, `Readonly<T>` is shallow. Consider a recursive `DeepReadonly<T>` type or a library like `ts-essentials` for deep immutability.

```typescript
type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object ? DeepReadonly<T[K]> : T[K];
};
```

### `Object.freeze` at Runtime

TypeScript's `readonly` is compile-time only. For true runtime immutability, combine with `Object.freeze`.

```typescript
const DEFAULTS = Object.freeze({
  locale: 'en',
  maxAge: 120,
});
// DEFAULTS.locale = 'fr' -- runtime error in strict mode
```

Note: `Object.freeze` is shallow. It does not freeze nested objects.

### Prefer Immutable Operations

Return new arrays/objects instead of mutating existing ones.

```typescript
// Bad: mutates the array
function addItem(items: string[], item: string): void {
  items.push(item);
}

// Good: returns a new array
function addItem(items: readonly string[], item: string): string[] {
  return [...items, item];
}
```

### Sources

- [TypeScript Handbook: Object Types (readonly)](https://www.typescriptlang.org/docs/handbook/2/objects.html#readonly-properties)
- [Google TypeScript Style Guide: Use const and let](https://google.github.io/styleguide/tsguide.html#use-const-and-let)

---

## 9. Common Idioms

### Type Narrowing

TypeScript narrows types through control flow analysis. Use these techniques instead of type assertions.

**`typeof` guards:**
```typescript
function format(value: string | number): string {
  if (typeof value === 'string') {
    return value.toUpperCase(); // narrowed to string
  }
  return value.toFixed(2); // narrowed to number
}
```

**`instanceof` guards:**
```typescript
function getLength(value: string | string[]): number {
  if (value instanceof Array) {
    return value.length; // narrowed to string[]
  }
  return value.length; // narrowed to string
}
```

**`in` operator:**
```typescript
interface Dog { bark(): void; }
interface Cat { meow(): void; }

function speak(animal: Dog | Cat): void {
  if ('bark' in animal) {
    animal.bark(); // narrowed to Dog
  }
}
```

**Equality narrowing:**
```typescript
function process(value: string | null): void {
  if (value !== null) {
    console.log(value.toUpperCase()); // narrowed to string
  }
}
```

### User-Defined Type Guards

Write custom type guards with the `is` keyword for narrowing that TypeScript cannot infer.

```typescript
interface Fish { swim(): void; }
interface Bird { fly(): void; }

function isFish(animal: Fish | Bird): animal is Fish {
  return 'swim' in animal;
}

function move(animal: Fish | Bird): void {
  if (isFish(animal)) {
    animal.swim(); // narrowed to Fish
  } else {
    animal.fly(); // narrowed to Bird
  }
}
```

### Exhaustiveness Checking

Use the `never` type to ensure all union members are handled. If a new variant is added, the compiler will report an error at the `never` assignment.

```typescript
type Shape =
  | { kind: 'circle'; radius: number }
  | { kind: 'square'; side: number };

function area(shape: Shape): number {
  switch (shape.kind) {
    case 'circle':
      return Math.PI * shape.radius ** 2;
    case 'square':
      return shape.side ** 2;
    default: {
      const _exhaustive: never = shape;
      return _exhaustive;
    }
  }
}
```

### The `satisfies` Operator

Use `satisfies` to validate that an expression conforms to a type while preserving the narrower inferred type. This is the best of both worlds: type checking without widening.

```typescript
type ColorMap = Record<string, string | number[]>;

// With type annotation: loses literal types
const colors: ColorMap = {
  red: [255, 0, 0],
  green: '#00ff00',
};
colors.red; // string | number[] -- too wide

// With satisfies: validated AND preserves literals
const colors = {
  red: [255, 0, 0],
  green: '#00ff00',
} satisfies ColorMap;
colors.red;   // number[] -- preserved
colors.green; // string   -- preserved
```

Combine `as const` with `satisfies` for maximum type safety:

```typescript
type Role = 'admin' | 'editor' | 'viewer';

const ROLES = ['admin', 'editor', 'viewer'] as const satisfies readonly Role[];
// Type: readonly ['admin', 'editor', 'viewer']
// AND validated against Role[]
```

### The `infer` Keyword

Use `infer` inside conditional types to extract sub-types.

```typescript
// Extract element type from an array
type ElementOf<T> = T extends ReadonlyArray<infer E> ? E : never;
type A = ElementOf<string[]>; // string

// Extract return type of a function
type Return<T> = T extends (...args: any[]) => infer R ? R : never;

// Extract string template parts
type ExtractId<T> = T extends `user_${infer Id}` ? Id : never;
type A = ExtractId<'user_123'>; // '123'
```

### Optional Chaining and Nullish Coalescing

Prefer these over manual checks and logical OR.

```typescript
// Bad
const name = user && user.profile && user.profile.name;
const port = config.port || 3000; // Bug: 0 is falsy!

// Good
const name = user?.profile?.name;
const port = config.port ?? 3000; // Only null/undefined trigger default
```

### `Record` for Dictionaries

Use `Record<K, V>` instead of index signatures when keys are known.

```typescript
// When keys are known
type Scores = Record<'math' | 'english' | 'science', number>;

// When keys are dynamic
const cache: Record<string, unknown> = {};
```

Prefer `Map` over plain objects for truly dynamic key-value stores.

### Sources

- [TypeScript Handbook: Narrowing](https://www.typescriptlang.org/docs/handbook/2/narrowing.html)
- [TypeScript 4.9: satisfies](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-9.html)
- [Total TypeScript: Tips](https://www.totaltypescript.com/tips)

---

## 10. Things to Avoid

### `any`

The `any` type disables type checking entirely. It propagates silently through your code, defeating the purpose of TypeScript.

```typescript
// Bad
function parse(input: any): any { }

// Good: use unknown and narrow
function parse(input: unknown): Result<Data> {
  if (typeof input !== 'string') {
    return { ok: false, error: new Error('expected string') };
  }
  // input is narrowed to string
  return { ok: true, value: JSON.parse(input) };
}
```

If you absolutely must use `any` (e.g., interfacing with an untyped library), isolate it at a narrow boundary and add a comment explaining why.

### Type Assertions (`as`)

Type assertions bypass the compiler. They tell TypeScript "trust me" without any runtime guarantee. Prefer narrowing.

```typescript
// Bad: silently wrong if response changes shape
const user = response as User;

// Good: validate at runtime
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'name' in value &&
    'email' in value
  );
}
if (isUser(response)) {
  // response is User
}
```

When annotation is possible, prefer it over assertion for object literals:

```typescript
// Bad: misses excess property checks
const config = { timout: 5000 } as Config;

// Good: excess property check catches the typo
const config: Config = { timout: 5000 }; // Error: 'timout' does not exist
```

### Non-Null Assertions (`!`)

The postfix `!` operator tells TypeScript a value is not `null | undefined` without proof. Prefer explicit checks.

```typescript
// Bad
const name = user!.name;

// Good
if (user) {
  const name = user.name;
}

// Good: with optional chaining
const name = user?.name ?? 'anonymous';
```

### Enums

Traditional TypeScript `enum`s have several problems: they generate runtime code, `const enum`s are incompatible with `--isolatedModules`, numeric enums allow unsafe reverse mappings, and they do not work well with tree-shaking.

```typescript
// Avoid
enum Status {
  Active,
  Inactive,
}

// Prefer: union of string literals
type Status = 'active' | 'inactive';

// Prefer: const object when you need runtime values
const STATUS = {
  Active: 'active',
  Inactive: 'inactive',
} as const;
type Status = (typeof STATUS)[keyof typeof STATUS];
```

### `namespace`

Namespaces are a legacy TypeScript-specific module system. Use ES modules instead.

```typescript
// Bad
namespace StringUtils {
  export function capitalize(s: string): string { }
}

// Good
export function capitalize(s: string): string { }
```

### `@ts-ignore`

Never use `@ts-ignore`. It suppresses all errors on the next line with no indication of what error is expected. If you must suppress an error, use `@ts-expect-error` with a description -- it will produce an error when the suppression is no longer needed.

```typescript
// Bad: suppresses everything, silently
// @ts-ignore
const x = broken.code;

// Acceptable: targeted, self-removing
// @ts-expect-error -- testing invalid input deliberately
const result = formatAge(null, null);
```

### Wrapper Types (`String`, `Number`, `Boolean`)

Never use the capitalized wrapper types. Always use lowercase primitives.

```typescript
// Bad
let name: String;
let count: Number;
let flag: Boolean;

// Good
let name: string;
let count: number;
let flag: boolean;
```

### `Function` Type

The `Function` type accepts anything callable with no type safety. Use specific function signatures.

```typescript
// Bad
function apply(fn: Function): void { }

// Good
function apply(fn: () => void): void { }
function apply(fn: (value: string) => number): void { }
```

### `Object` and `{}`

Avoid `Object` (the wrapper type) and `{}` (any non-nullish value). Use `object` (non-primitive) or `Record<string, unknown>` for generic objects.

```typescript
// Bad
function process(data: Object): void { }
function process(data: {}): void { }

// Good
function process(data: object): void { }
function process(data: Record<string, unknown>): void { }
```

### Sources

- [Google TypeScript Style Guide: Any](https://google.github.io/styleguide/tsguide.html#any)
- [typescript-eslint: no-explicit-any](https://typescript-eslint.io/rules/no-explicit-any/)
- [typescript-eslint: no-non-null-assertion](https://typescript-eslint.io/rules/no-non-null-assertion/)
- [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance)

---

## 11. Tooling

### TypeScript Compiler (`tsc`)

Use `tsc --noEmit` as a type-checking step in CI. This validates types without producing output files.

```bash
# Type check only
npx tsc --noEmit

# Type check and build
npx tsc --build
```

### typescript-eslint

The standard linter for TypeScript. It provides three preset configurations of increasing strictness.

**Recommended presets:**

| Preset                  | Level      | Includes                                        |
| ----------------------- | ---------- | ----------------------------------------------- |
| `recommended`           | Baseline   | Catches common errors                           |
| `recommended-type-checked` | Standard | Adds rules requiring type information            |
| `strict-type-checked`   | Maximum    | Adds opinionated rules for maximum correctness   |
| `stylistic-type-checked`| Style      | Consistent code style using type information     |

**Key rules to enable:**

```javascript
// eslint.config.js (flat config)
import tseslint from 'typescript-eslint';

export default tseslint.config(
  ...tseslint.configs.strictTypeChecked,
  ...tseslint.configs.stylisticTypeChecked,
  {
    rules: {
      // Enforce import type for type-only imports
      '@typescript-eslint/consistent-type-imports': 'error',
      '@typescript-eslint/consistent-type-exports': 'error',

      // Prevent floating promises
      '@typescript-eslint/no-floating-promises': 'error',
      '@typescript-eslint/no-misused-promises': 'error',

      // Ban any and unsafe operations
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-unsafe-assignment': 'error',
      '@typescript-eslint/no-unsafe-call': 'error',
      '@typescript-eslint/no-unsafe-member-access': 'error',
      '@typescript-eslint/no-unsafe-return': 'error',

      // Prefer modern operators
      '@typescript-eslint/prefer-nullish-coalescing': 'error',
      '@typescript-eslint/prefer-optional-chain': 'error',

      // Prevent unnecessary assertions
      '@typescript-eslint/no-unnecessary-type-assertion': 'error',
      '@typescript-eslint/no-non-null-assertion': 'error',

      // Naming conventions
      '@typescript-eslint/naming-convention': [
        'error',
        { selector: 'default', format: ['camelCase'] },
        { selector: 'variable', format: ['camelCase', 'UPPER_CASE'] },
        { selector: 'typeLike', format: ['PascalCase'] },
        { selector: 'enumMember', format: ['UPPER_CASE'] },
      ],

      // Restrict template expressions to safe types
      '@typescript-eslint/restrict-template-expressions': 'error',
    },
  },
);
```

### Prettier

Automated code formatter. Configure it and never argue about formatting in reviews.

```json
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 80,
  "tabWidth": 2,
  "arrowParens": "always"
}
```

Run prettier as a pre-commit hook or CI check:

```bash
npx prettier --check "src/**/*.ts"
npx prettier --write "src/**/*.ts"
```

### Biome

A faster alternative to ESLint + Prettier combined. Written in Rust. Handles both linting and formatting in a single tool.

```bash
# Format
npx @biomejs/biome format --write src/

# Lint
npx @biomejs/biome lint src/

# Both
npx @biomejs/biome check --write src/
```

Notable Biome lint rules for TypeScript:
- `noExplicitAny` -- Disallow `any`
- `noNonNullAssertion` -- Disallow `!`
- `useConst` -- Require `const` when variable is never reassigned
- `noUnusedVariables` -- Flag dead code

### Deno Lint

If using Deno as a runtime, `deno lint` provides built-in TypeScript linting with no configuration required.

```bash
deno lint src/
```

### CI Integration

A typical CI pipeline for TypeScript:

```yaml
steps:
  - name: Install
    run: npm ci

  - name: Type check
    run: npx tsc --noEmit

  - name: Lint
    run: npx eslint .

  - name: Format check
    run: npx prettier --check .

  - name: Test
    run: npx vitest run
```

### Sources

- [typescript-eslint: Getting Started](https://typescript-eslint.io/getting-started/)
- [typescript-eslint: Rules](https://typescript-eslint.io/rules/)
- [Prettier: Options](https://prettier.io/docs/en/options.html)
- [Biome: Getting Started](https://biomejs.dev/guides/getting-started/)
- [Total TypeScript: Essential resources](https://www.totaltypescript.com/)

---

## Further Reading

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html) -- Official language documentation
- [Google TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html) -- Battle-tested conventions from Google
- [typescript-eslint](https://typescript-eslint.io/) -- Linting rules and configuration
- [Total TypeScript](https://www.totaltypescript.com/) -- Matt Pocock's advanced TypeScript patterns and tips
- [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance) -- Compiler performance best practices
- [TypeScript Deep Dive](https://basarat.gitbook.io/typescript/) -- Basarat's comprehensive TypeScript guide
