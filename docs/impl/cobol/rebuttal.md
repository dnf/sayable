# COBOL Style Guide -- Rebuttal

A senior engineering review of the COBOL style guide. This document covers points of disagreement, missing topics, and areas where the guide's recommendations are misleading, contradictory, or insufficiently nuanced.

---

## Points of Disagreement

### 1. Section 1.2: Data Item Prefixes Are Presented as Universal Convention

**Guideline quoted:**

> Use prefixes to indicate the storage section or logical grouping:
> `WS-` for WORKING-STORAGE, `LS-` for LOCAL-STORAGE, `LK-` for LINKAGE SECTION, `PT-` for constants, `T01-`/`T02-` for tables.

**Analysis:**

The `WS-` and `LK-` prefixes are genuinely widespread mainframe conventions. However, the guide presents all five prefixes (`WS-`, `LS-`, `LK-`, `PT-`, `T01-`) as if they are equally standard. `PT-` for constants and `T01-`/`T02-` for tables are shop-specific conventions, not universal. Presenting them in the same table without distinguishing their prevalence gives the false impression that all five are community norms. A reader adopting `PT-` for constants would find zero recognition of that prefix on other teams.

More importantly, the guide doesn't mention that this project's own codebase uses `PT-` for constants (e.g., `PT-MAX-AGE-MONTHS`, `PT-VERSION`, `PT-SHORT`). That is fine as a project-internal convention, but the style guide should distinguish "industry-wide conventions" from "conventions we chose for this project."

**Recommendation:**

Separate the prefix table into two tiers: widely-adopted prefixes (`WS-`, `LK-`, `LS-`) and project-local/shop conventions (`PT-`, `T01-`). State that the latter are reasonable choices but not universal.

---

### 2. Section 1.3: Numeric Paragraph Prefixes Presented Without Trade-offs

**Guideline quoted:**

> When using numeric prefixes for hierarchy, use 4-digit numbers incrementing by 100 or 1000 at each level

**Analysis:**

The guide presents numeric prefixes as purely beneficial without discussing the real trade-off: they impose a fixed hierarchy at write-time that becomes a maintenance burden. When a program evolves and you need to insert a major section between 2000 and 3000, you either renumber (touching every PERFORM call) or wedge in 2500 (breaking the clean increments). The verb-noun naming shown just above the numeric example is actually the more maintainable approach for most modern code, but the guide gives equal weight to both without contrasting them.

The guide also quietly switches between increments of 100 (`2100`, `2200`, `2300`) and 1000 (`1000`, `2000`, `3000`) without explaining the typical convention: top-level paragraphs increment by 1000, sub-paragraphs increment by 100 within their parent's range. This is implied by the example but never stated.

**Recommendation:**

Explicitly state the trade-off: numeric prefixes provide quick orientation in large programs but create renumbering overhead during maintenance. Note that verb-noun naming (without numeric prefixes) is the more common recommendation for new code, especially smaller programs. If numeric prefixes are used, explicitly state the convention: top-level increments by 1000, sub-levels increment by 100.

---

### 3. Section 2.2: "Free Format Is Recommended for New Code" Is Overly Broad

**Guideline quoted:**

> Free format is recommended for new code. It eliminates column-counting errors and improves readability.

**Analysis:**

This is stated as an unconditional recommendation, but the real answer is context-dependent. If the new code must interoperate with existing fixed-format copybooks, build systems configured for fixed format, or mainframe toolchains where free format is not well-supported (IBM Enterprise COBOL did not support free format until V6.3), then recommending free format creates integration friction.

For this project specifically -- GnuCOBOL-based, greenfield code, no mainframe dependencies -- free format is absolutely the right choice. The guide should say that, rather than making a blanket statement that could mislead someone maintaining mainframe COBOL.

**Recommendation:**

Qualify the recommendation: "For GnuCOBOL and other compilers that fully support it, free format is recommended for new code. In mainframe environments, check your compiler version and shop standards before switching."

---

### 4. Section 4.1: Level Increment by 5 Is Presented as Best Practice

**Guideline quoted:**

> **Best practice for subordinate levels:** Increment by 5 (01, 05, 10, 15, 20) to leave room for inserting intermediate levels later.

**Analysis:**

This is a holdover from the era when inserting a level required manual renumbering and card re-punching. With modern editors and version control, inserting a level between 02 and 03 is trivial -- you renumber and your diff shows the change clearly. The "leave room for insertion" rationale no longer holds significant weight.

The real reason to prefer larger increments (like 05) is visual clarity: `05` is more visually distinct from `01` than `02` is. But that argument applies only to the first subordinate level; once you get to `10`, `15`, `20`, the visual benefit diminishes and you are burning through your 49-level budget faster.

This project's own codebase uses `05` for the first subordinate level (e.g., the month-days table in `Types.cbl`), which is reasonable. But calling increment-by-5 a "best practice" overstates the case.

**Recommendation:**

Present both conventions neutrally. Note that increment-by-5 is traditional and still widely used, but increment-by-1 is equally valid in modern development. Highlight the actual benefit of wider increments (visual hierarchy) rather than the legacy rationale (leaving room for insertion).

---

### 5. Section 5.1: "Never Use PERFORM THRU" Is Overly Absolutist

**Guideline quoted:**

> Never use `PERFORM para-A THRU para-Z`

**Analysis:**

The guide says "Never" here, then in Section 7.4 explains in detail why PERFORM THRU is dangerous, which is all correct. However, the blanket "never" ignores the one legitimate use case: `PERFORM para-name THRU para-name-EXIT`, which is the established mainframe pattern for paragraphs with cleanup logic. In this pattern, the EXIT paragraph is specifically paired with its parent and contains only `EXIT.` -- the "someone inserts a paragraph in between" argument does not apply because the EXIT paragraph is by convention the final paragraph in the range and is never separated from its parent.

The guide itself shows the `2000-EXIT. EXIT.` pattern in section 1.3 without mentioning that this pattern is only meaningful with PERFORM THRU. This is an internal contradiction: the guide shows exit paragraphs and then forbids the only mechanism that uses them.

That said, for this project (using EXIT PARAGRAPH, which the guide correctly promotes), PERFORM THRU is indeed unnecessary. The guide should distinguish between "we don't use it in this project" and "it is always wrong."

**Recommendation:**

Soften to: "Avoid PERFORM THRU in new code. EXIT PARAGRAPH (COBOL 2002+) provides a cleaner alternative. In legacy codebases, `PERFORM para THRU para-EXIT` is an established pattern that is safe when the EXIT paragraph is kept adjacent to its parent and contains only `EXIT.`"

---

### 6. Section 5.5: Period Placement Convention Is Confusing

**Guideline quoted:**

> The trailing period on its own line (after a blank line or with the dot on a line by itself) is a common modern convention that makes the paragraph boundary visually clear.

And the example shows:

```cobol
VALIDATE-INPUT.
    IF WS-INPUT = SPACES
        MOVE "EMPTY" TO WS-ERROR-MSG
        PERFORM REPORT-ERROR
    END-IF
    .
```

**Analysis:**

The guide shows the period on a line by itself with 4 spaces of indentation, but the description says "after a blank line or with the dot on a line by itself" -- suggesting two different styles without picking one. Looking at the project's actual codebase (`SayableAge.cbl`), the period appears consistently on its own line, indented to statement level, sometimes preceded by a blank line and sometimes not. The guide should pick one convention and show it consistently rather than describing two variants.

Additionally, the indentation of the standalone period varies implicitly: the example shows it indented 4 spaces (statement level), but some shops put it at Area A (column 8 in fixed format) to align with the paragraph name. The guide doesn't address this.

**Recommendation:**

Pick one convention explicitly: "Place the terminating period on its own line, indented to match the paragraph body." Show one style consistently in all examples.

---

### 7. Section 6.5: FUNCTION LENGTH of FUNCTION TRIM Is Not the Right Idiom for "Length Excluding Trailing Spaces"

**Guideline quoted:**

> ```cobol
> *> Get length (excluding trailing spaces)
> COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-INPUT))
> ```

**Analysis:**

This is subtly wrong in a way that matters. `FUNCTION TRIM` without qualifiers trims both leading AND trailing spaces. So `FUNCTION LENGTH(FUNCTION TRIM(WS-INPUT))` gives you the length excluding both leading and trailing spaces, not just trailing spaces as the comment claims.

If the field contains `"  hello  "`, `FUNCTION TRIM` produces `"hello"` (length 5), not `"hello  "` stripped of trailing spaces only (which would be length 7). The correct idiom for "length excluding trailing spaces only" would be `FUNCTION LENGTH(FUNCTION TRIM(WS-INPUT TRAILING))`.

This is the kind of error that causes real bugs when someone follows the guide.

**Recommendation:**

Fix the comment and show both variants:

```cobol
*> Length excluding leading and trailing spaces
COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-INPUT))

*> Length excluding trailing spaces only
COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-INPUT TRAILING))
```

---

### 8. Section 9.6: String Template Replacement Example Is Incorrect

**Guideline quoted:**

The template replacement example using INSPECT TALLYING:

```cobol
INSPECT WS-TEMPLATE
    TALLYING WS-POS
    FOR CHARACTERS BEFORE INITIAL "{n}"
```

**Analysis:**

This example has a critical bug. INSPECT TALLYING *adds to* the tally variable (as the guide itself correctly warns in Section 6.3: "Always initialize the tally variable to zero before INSPECT TALLYING"). The example does not show initializing `WS-POS` to zero before the INSPECT. A reader copying this pattern verbatim will get wrong results on any invocation after the first.

Beyond the missing initialization, the example is fragile in another way: the reference modification arithmetic `WS-POS + 3` hardcodes the marker length as 3 (`{n}` is 3 characters). If someone changes the marker to `{name}`, the code silently produces wrong output. The project's own codebase handles this correctly with a dedicated `REPLACE-FIRST` paragraph that dynamically computes marker length, which is a better pattern to show in the guide.

**Recommendation:**

Either fix the example (add `MOVE 0 TO WS-POS` and parameterize the marker length) or replace it with a reference to the `REPLACE-FIRST` pattern that the project actually uses, which is more robust.

---

### 9. Section 10.4: MOVE CORRESPONDING Dismissal Is Too Strong

**Guideline quoted:**

> MOVE CORRESPONDING copies all identically-named elementary items between two group items. It is convenient but dangerous [...] Prefer explicit MOVEs.

**Analysis:**

The guide's three objections to MOVE CORRESPONDING are valid for loosely-related records with different structures, but MOVE CORRESPONDING is perfectly safe and maintainable when the source and target are structurally identical (e.g., copying a record to a backup area, or moving between identically-defined LINKAGE and WORKING-STORAGE records). In those cases, explicit MOVEs are pure ceremony -- they are harder to maintain (add a field, remember to add the MOVE) and more error-prone (forget a MOVE, get stale data).

The guide should distinguish between the dangerous use case (records with coincidentally similar names but different structures) and the safe use case (records with intentionally identical structure).

**Recommendation:**

Soften to: "Avoid MOVE CORRESPONDING between records with different structures. When the source and target are structurally identical, MOVE CORRESPONDING is appropriate and reduces the risk of forgetting a field when the record evolves."

---

### 10. Section 10.6: Discouraging Commas as Separators Is Correct but the Example Is Misleading

**Guideline quoted:**

> ```cobol
> *> Avoid:
> ADD A, B, C GIVING D.
>
> *> Prefer:
> ADD A B C GIVING D
> ```

**Analysis:**

The "avoid" example ends with a period (`.`) while the "prefer" example does not. This inconsistency could confuse readers into thinking the recommendation is also about removing periods. It is an editorial oversight, but in a section about syntactic details, precision matters.

**Recommendation:**

Make both examples consistent (either both with periods or both without).

---

### 11. Section 10.9: The "Constant" Pattern Uses a Data Item, Not a True Constant

**Guideline quoted:**

> ```cobol
> *> Good (constant in WORKING-STORAGE):
> 01  PT-MAX-AGE-MONTHS  PIC 9(4) VALUE 6000.
> ```

**Analysis:**

COBOL does not have true constants in the way most languages do. A `PIC 9(4) VALUE 6000` item can be modified at runtime by any MOVE or arithmetic statement. The guide calls this a "constant" without noting this limitation. A reader coming from another language might assume the compiler enforces immutability, which it does not.

COBOL 2002 introduced level-78 constants (`78 PT-MAX-AGE-MONTHS VALUE 6000.`) which are compile-time constants that cannot be modified. If targeting COBOL 2002+ (which the guide recommends via EXIT PARAGRAPH), the guide should mention level-78 as the actual constant mechanism.

**Recommendation:**

Add a note about the difference between a VALUE-initialized data item (mutable at runtime) and a level-78 constant (immutable, compile-time). Recommend level-78 for values that should never change.

---

## Missing Topics

### A. Error Handling and FILE STATUS

The guide mentions file I/O in examples (EOF processing, READ/WRITE) but never discusses FILE STATUS checking, which is one of the most critical patterns in production COBOL. Every file operation should check the file status field. Omitting this topic is a significant gap for a guide that positions itself as "comprehensive."

### B. Arithmetic Precision and Truncation

The guide covers PIC clauses but says nothing about the rules governing arithmetic intermediate results, size errors, and the ON SIZE ERROR clause. Truncation bugs are among the most common COBOL defects in production. At minimum, the guide should recommend using `ON SIZE ERROR` with COMPUTE/ADD/SUBTRACT/MULTIPLY/DIVIDE for any calculation where overflow is possible.

### C. INITIALIZE Statement

The guide never mentions `INITIALIZE`, which is the standard way to set a group item's subordinate fields to their default values (spaces for alphanumeric, zeros for numeric). This is more idiomatic and less error-prone than moving spaces/zeros to individual fields, and is the standard way to clear a record before populating it.

### D. Encoding and Character Set Considerations

For a project that handles 110 locales including non-Latin scripts, the guide should address how GnuCOBOL handles UTF-8 data in PIC X fields. COBOL's `PIC X(n)` counts bytes, not characters, so a UTF-8 multibyte character occupies more than one position. This directly affects field sizing, reference modification, and FUNCTION LENGTH. The project's locale data uses UTF-8 strings (half-markers like "1/2" or Unicode characters), so this is a practical concern, not a theoretical one.

### E. COMP/BINARY vs COMP-3 Guidance Is Mainframe-Centric

Section 4.2 recommends `COMP-3` (packed decimal) for "efficiency on mainframes." For GnuCOBOL targeting x86/ARM, COMP-3 has no performance advantage -- in fact, `COMP`/`BINARY` is faster because it maps to native integer operations. The guide should note that COMP-3 is a mainframe optimization and that `COMP`/`BINARY` is the better choice for GnuCOBOL.

---

## What the Guide Gets Right

The guide is solid in several areas that deserve acknowledgment:

- **88-level condition names (Sections 1.4 and 4.4)** are explained thoroughly with excellent examples. The "prefer 88-levels over literal comparisons" advice is spot-on.
- **Scope terminators (Sections 5.4 and 10.8)** are covered emphatically and correctly. This is the single most important structural recommendation for COBOL code quality.
- **EXIT PARAGRAPH (Section 7.3)** is correctly identified as the modern replacement for GO TO in guard-clause patterns, with a good example.
- **ALTER avoidance (Section 10.1)** is correctly presented as having "no valid modern use case."
- **NEXT SENTENCE vs CONTINUE (Section 10.3)** is explained clearly with a correct demonstration of the subtle scoping bug.
- **Top-down structure (Section 7.5)** and the inverted-tree diagram provide an excellent mental model for program organization.
- **GnuCOBOL compiler flags (Section 11.1)** are well-organized and the recommended development/production command lines are practical and correct.
- **REDEFINES for table initialization (Section 9.4)** is a genuinely useful pattern that is hard to discover without guidance.
- **The sources section (Section 12)** is unusually thorough and well-categorized for a style guide.
