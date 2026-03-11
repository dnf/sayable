# COBOL Style Guide

A comprehensive guide to idiomatic COBOL coding style and best practices, intended for
auditing COBOL implementations. Covers GnuCOBOL and modern COBOL standards (COBOL-85,
COBOL 2002/2014/2023).

---

## Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Code Formatting](#2-code-formatting)
3. [Division and Section Organization](#3-division-and-section-organization)
4. [Data Description](#4-data-description)
5. [Control Flow](#5-control-flow)
6. [String Handling](#6-string-handling)
7. [Structured Programming](#7-structured-programming)
8. [Copybooks and Modularity](#8-copybooks-and-modularity)
9. [Common Idioms and Patterns](#9-common-idioms-and-patterns)
10. [Things to Avoid](#10-things-to-avoid)
11. [Tooling](#11-tooling)
12. [Sources](#12-sources)

---

## 1. Naming Conventions

COBOL names are limited to 30 characters (31 in some compilers), use uppercase letters,
digits, and hyphens. The hyphen acts as a word separator. No underscores, no leading or
trailing hyphens, no consecutive hyphens.

### 1.1 General Principles

- **Use descriptive, meaningful names.** The name should communicate purpose without
  needing a comment. `GROSS-SALARY-AMOUNT` over `AMT1`.
- **Use COBOL-CASE (uppercase with hyphens).** This is the universal convention:
  `CUSTOMER-ACCOUNT-NUMBER`, `TOTAL-INVOICE-AMOUNT`.
- **Be consistent with abbreviations.** If you abbreviate "number" as `NUM`, use `NUM`
  everywhere, never mix with `NBR` or `NO`.
- **Avoid single-character or generic names.** `I`, `X`, `TEMP`, `FLAG` tell the reader
  nothing. Use `MONTH-INDEX`, `SEARCH-KEY`, `INPUT-VALID`.

### 1.2 Data Items

Use prefixes to indicate the storage section or logical grouping:

| Prefix | Meaning | Example |
|--------|---------|---------|
| `WS-` | WORKING-STORAGE item | `WS-EMPLOYEE-NAME` |
| `LS-` | LOCAL-STORAGE item | `LS-TEMP-COUNTER` |
| `LK-` | LINKAGE SECTION item | `LK-INPUT-RECORD` |
| `PT-` | Constant / parameter | `PT-MAX-RETRIES` |
| `T01-`, `T02-` | Table / array entries | `T01-PRODUCT-CODE` |

Use suffixes to clarify role:

| Suffix | Meaning | Example |
|--------|---------|---------|
| `-COUNT`, `-CTR` | Counter | `RECORD-COUNT` |
| `-TOTAL`, `-AMT` | Accumulated amount | `INVOICE-TOTAL` |
| `-FLAG`, `-SW` | Boolean flag (use 88-levels instead when possible) | `EOF-FLAG` |
| `-TABLE` | Table parent | `PRODUCT-TABLE` |
| `-INDEX`, `-IDX` | Index variable | `SEARCH-INDEX` |

### 1.3 Paragraphs and Sections

Name paragraphs as verb-noun pairs describing the action performed:

```cobol
PROCESS-CUSTOMER-RECORD.
CALCULATE-MONTHLY-TOTALS.
VALIDATE-INPUT-DATE.
WRITE-DETAIL-LINE.
```

When using numeric prefixes for hierarchy, use 4-digit numbers incrementing by 100 or
1000 at each level:

```cobol
0000-MAIN-CONTROL.
1000-INITIALIZE.
2000-PROCESS-RECORDS.
2100-READ-NEXT-RECORD.
2200-VALIDATE-RECORD.
2300-UPDATE-DATABASE.
3000-FINALIZE.
9000-ERROR-HANDLER.
```

Exit paragraphs should be named consistently:

```cobol
2000-PROCESS-RECORDS.
    ...
2000-EXIT.
    EXIT.
```

### 1.4 Condition Names (88-Levels)

Use descriptive state names that read naturally in an IF statement:

```cobol
05  WS-FILE-STATUS          PIC X(2).
    88 FILE-OPENED-OK        VALUE "00".
    88 FILE-AT-END            VALUE "10".
    88 FILE-NOT-FOUND         VALUE "35".

05  WS-RECORD-TYPE           PIC X(1).
    88 RECORD-IS-HEADER       VALUE "H".
    88 RECORD-IS-DETAIL       VALUE "D".
    88 RECORD-IS-TRAILER      VALUE "T".
```

This allows code to read like prose:

```cobol
IF FILE-AT-END
    PERFORM 3000-FINALIZE
END-IF
```

### 1.5 Copybooks

Name copybooks to reflect their content and scope. Common conventions:

- `CUST-RECORD` -- customer record layout
- `WS-DATE-FIELDS` -- date working storage fields
- `COMMON-CONSTANTS` -- shared constants

### 1.6 Programs

Use short, descriptive program IDs that indicate the program's function:

```cobol
PROGRAM-ID. CUSTMAINT.   *> Customer maintenance
PROGRAM-ID. INVPROCESS.  *> Invoice processing
```

---

## 2. Code Formatting

### 2.1 Fixed Format (Traditional)

Fixed format is the classic COBOL layout inherited from punch cards. It remains the
default for GnuCOBOL and most mainframe compilers.

| Columns | Name | Purpose |
|---------|------|---------|
| 1-6 | Sequence area | Line numbers (optional, ignored by compiler) |
| 7 | Indicator area | `*` = comment, `-` = continuation, `D` = debug |
| 8-11 | Area A | Division/section/paragraph headers, 01/77 levels |
| 12-72 | Area B | Statements, clauses, continuation of Area A items |
| 73-80 | Identification area | Ignored by compiler |

**Area A items** (must begin in columns 8-11):
- Division headers
- Section headers
- Paragraph names
- Level 01 and 77 data items
- FD and SD entries

**Area B items** (must begin in column 12 or beyond):
- Statements and verbs
- Subordinate data items (levels 02-49, 66, 88)
- Continuation of clauses

### 2.2 Free Format (Modern)

Free format removes column restrictions. Code can start at column 1. Enable with
`-free` on GnuCOBOL or with the directive:

```cobol
>>SOURCE FORMAT IS FREE
```

In free format:
- No sequence number area or identification area
- Comments start with `*>` anywhere on the line
- No column-7 indicator (use `*>` for comments instead of `*`)
- Statements can start at any column
- Lines can extend to 256 characters (compiler-dependent)

Free format is recommended for new code. It eliminates column-counting errors and
improves readability.

### 2.3 Indentation

Use consistent indentation of 4 spaces per nesting level. Never use tabs.

```cobol
IF WS-ACCOUNT-ACTIVE
    IF WS-BALANCE > 0
        PERFORM PROCESS-PAYMENT
    ELSE
        PERFORM SEND-REMINDER
    END-IF
ELSE
    PERFORM CLOSE-ACCOUNT
END-IF
```

### 2.4 Data Description Alignment

Align PIC clauses, VALUE clauses, and structural keywords in columns to create
scannable layouts:

```cobol
01  WS-CUSTOMER-RECORD.
    05  WS-CUST-ID              PIC 9(8).
    05  WS-CUST-NAME            PIC X(40).
    05  WS-CUST-BALANCE         PIC S9(7)V99   COMP-3.
    05  WS-CUST-STATUS          PIC X(1).
        88 CUST-ACTIVE           VALUE "A".
        88 CUST-INACTIVE         VALUE "I".
        88 CUST-SUSPENDED        VALUE "S".
    05  WS-CUST-OPEN-DATE       PIC 9(8).
```

Rules:
- Level 01 items start at the margin (column 8 in fixed format)
- Indent subordinate levels by 4 spaces per level
- Align PIC clauses in a single column (column 33 or 40 are common choices)
- Place VALUE clauses on the same line if they fit; otherwise break to the next line
- Place each 88-level under its parent, indented one additional level

### 2.5 Statement Layout

One statement per line. Separate logical groups with blank lines:

```cobol
MOVE WS-INPUT-DATE TO WS-WORK-DATE
PERFORM VALIDATE-DATE

IF DATE-IS-VALID
    MOVE WS-WORK-DATE TO WS-OUTPUT-DATE
    PERFORM WRITE-RECORD
END-IF
```

For long statements, break at natural boundaries and indent continuation lines:

```cobol
COMPUTE WS-TOTAL-AMOUNT =
    WS-BASE-PRICE
    + WS-TAX-AMOUNT
    - WS-DISCOUNT-AMOUNT
```

### 2.6 Blank Lines and Comments

- Insert a blank line before each paragraph name
- Insert blank lines between logical groups of statements within a paragraph
- Use comment blocks before paragraphs to explain non-obvious purpose:

```cobol
*> Calculate the Julian Day Number using the proleptic
*> Gregorian calendar algorithm. Inputs must be validated
*> before calling.
CALC-JULIAN-DAY.
    ...
```

---

## 3. Division and Section Organization

Every COBOL program has four divisions, always in this order:

### 3.1 IDENTIFICATION DIVISION

Contains the program name and optional metadata:

```cobol
IDENTIFICATION DIVISION.
PROGRAM-ID. SAYABLEAGE.
```

In modern COBOL the only required entry is PROGRAM-ID. Older standards also supported
AUTHOR, DATE-WRITTEN, DATE-COMPILED, INSTALLATION, and SECURITY, but these are
considered obsolete. Use comments instead if you need this metadata:

```cobol
IDENTIFICATION DIVISION.
PROGRAM-ID. SAYABLEAGE.
*> Author: Sayable Project
*> Purpose: Format ages the way humans speak
```

### 3.2 ENVIRONMENT DIVISION

Describes the computing environment. Contains two sections:

- **CONFIGURATION SECTION** -- SOURCE-COMPUTER, OBJECT-COMPUTER, SPECIAL-NAMES
- **INPUT-OUTPUT SECTION** -- FILE-CONTROL, I-O-CONTROL

For programs that do not use files (pure computation), this division can be minimal or
omitted entirely in GnuCOBOL free format.

```cobol
ENVIRONMENT DIVISION.
CONFIGURATION SECTION.
REPOSITORY.
    FUNCTION ALL INTRINSIC.
```

The `FUNCTION ALL INTRINSIC` clause allows calling intrinsic functions without the
`FUNCTION` keyword prefix, which reduces verbosity.

### 3.3 DATA DIVISION

Contains all data definitions, organized into sections:

```
DATA DIVISION.
  FILE SECTION.           -- Record descriptions for files
  WORKING-STORAGE SECTION.  -- Persistent program data
  LOCAL-STORAGE SECTION.    -- Per-invocation data (reinitialized each CALL)
  LINKAGE SECTION.          -- Parameters passed from callers
```

Organize WORKING-STORAGE logically:

1. Constants and parameters first
2. Input/output areas
3. Working variables grouped by function
4. Tables and arrays
5. Temporary/scratch variables last

### 3.4 PROCEDURE DIVISION

Contains the executable logic. Organize as:

1. Main control paragraph at the top
2. Major processing paragraphs in logical order
3. Utility/helper paragraphs at the bottom
4. Error handling paragraphs last

```cobol
PROCEDURE DIVISION.
0000-MAIN.
    PERFORM 1000-INITIALIZE
    PERFORM 2000-PROCESS UNTIL END-OF-INPUT
    PERFORM 3000-FINALIZE
    STOP RUN
    .

1000-INITIALIZE.
    ...

2000-PROCESS.
    ...

3000-FINALIZE.
    ...

9000-ABORT.
    ...
```

---

## 4. Data Description

### 4.1 Level Numbers

| Level | Purpose |
|-------|---------|
| 01 | Record or independent item |
| 02-49 | Subordinate items within a record |
| 66 | RENAMES clause (aliasing; rarely used) |
| 77 | Independent elementary items (avoid; use 01 instead) |
| 88 | Condition names |

**Best practice for subordinate levels:** Increment by 5 (01, 05, 10, 15, 20) to leave
room for inserting intermediate levels later. Alternatively, some shops increment by 1
(01, 02, 03) for compactness.

### 4.2 PICTURE Clauses

| Symbol | Meaning | Example |
|--------|---------|---------|
| `9` | Numeric digit | `PIC 9(4)` -- 4-digit integer |
| `X` | Alphanumeric character | `PIC X(30)` -- 30-character string |
| `A` | Alphabetic only | `PIC A(20)` -- 20 letters |
| `S` | Sign (leading) | `PIC S9(5)` -- signed 5-digit |
| `V` | Implied decimal point | `PIC S9(5)V99` -- 5.2 decimal |
| `Z` | Zero-suppressed digit | `PIC Z(4)9` -- suppress leading zeros |
| `P` | Scaling position | `PIC 9PP` -- multiply by 100 |

**Numeric best practices:**
- Declare numeric items as signed (`S`) unless you know the value is never negative
- Use odd-length packed decimal (`COMP-3`) for efficiency on mainframes:
  `PIC S9(7) COMP-3`
- Use `COMP` / `BINARY` for subscripts and counters for performance
- Always specify `V` for decimal positions explicitly

**Alphanumeric best practices:**
- Size fields to their maximum expected content
- Use `PIC X(n)` rather than `PIC A(n)` unless strict alphabetic validation is needed

### 4.3 WORKING-STORAGE vs LOCAL-STORAGE

| Feature | WORKING-STORAGE | LOCAL-STORAGE |
|---------|----------------|---------------|
| Initialization | Once, at program load | Every CALL invocation |
| Persistence | Values persist between CALLs | Values reset each CALL |
| Use case | Main program state, constants | Recursive/reentrant subprograms |

For programs that are not called as subprograms, WORKING-STORAGE is the standard choice.
Use LOCAL-STORAGE when building reentrant or recursive subprograms where you need fresh
state on each invocation.

### 4.4 88-Level Condition Names

88-level items are one of COBOL's most powerful self-documenting features. They attach
meaningful names to data values, making IF statements read like English.

**Rules:**
- No PICTURE clause on the 88-level itself (it inherits from its parent)
- Define all related condition names immediately after their parent item
- Use SET to change condition values:

```cobol
05  WS-PROCESS-STATE         PIC X(1).
    88 PROCESS-INITIALIZING   VALUE "I".
    88 PROCESS-RUNNING        VALUE "R".
    88 PROCESS-COMPLETE       VALUE "C".
    88 PROCESS-FAILED         VALUE "F".

*> Setting a condition:
SET PROCESS-RUNNING TO TRUE

*> Testing a condition:
IF PROCESS-COMPLETE
    PERFORM CLEANUP-ROUTINE
END-IF
```

**Prefer 88-levels over literal comparisons:**

```cobol
*> Poor:
IF WS-STATUS-CODE = "A"

*> Better:
IF ACCOUNT-IS-ACTIVE
```

The 88-level approach is resilient to value changes (update the VALUE clause in one
place) and makes code self-documenting.

### 4.5 Tables and Arrays

```cobol
01  WS-MONTH-DAYS-TABLE.
    05  FILLER PIC 9(2) VALUE 31.
    05  FILLER PIC 9(2) VALUE 28.
    05  FILLER PIC 9(2) VALUE 31.
    05  FILLER PIC 9(2) VALUE 30.
    05  FILLER PIC 9(2) VALUE 31.
    05  FILLER PIC 9(2) VALUE 30.
    05  FILLER PIC 9(2) VALUE 31.
    05  FILLER PIC 9(2) VALUE 31.
    05  FILLER PIC 9(2) VALUE 30.
    05  FILLER PIC 9(2) VALUE 31.
    05  FILLER PIC 9(2) VALUE 30.
    05  FILLER PIC 9(2) VALUE 31.
01  WS-MONTH-DAYS-ARRAY REDEFINES WS-MONTH-DAYS-TABLE.
    05  WS-MONTH-DAYS PIC 9(2) OCCURS 12.
```

**Table best practices:**
- Define table maximum size with a constant, not a magic number
- Use INDEXED BY for SEARCH operations
- Declare subscripts as `COMP` or `BINARY` for performance
- Use REDEFINES to initialize tables with literal values (as shown above)

---

## 5. Control Flow

### 5.1 PERFORM

PERFORM is the primary control flow mechanism in structured COBOL. It is the equivalent
of a function/procedure call.

```cobol
*> Simple call:
PERFORM VALIDATE-INPUT

*> Inline loop:
PERFORM UNTIL END-OF-FILE
    READ INPUT-FILE
        AT END SET END-OF-FILE TO TRUE
        NOT AT END PERFORM PROCESS-RECORD
    END-READ
END-PERFORM

*> Counting loop:
PERFORM VARYING WS-I FROM 1 BY 1
    UNTIL WS-I > WS-TABLE-SIZE
    PERFORM PROCESS-TABLE-ENTRY
END-PERFORM
```

**PERFORM best practices:**
- Use `PERFORM paragraph-name`, not `PERFORM section-name` (unless using sections
  with EXIT paragraphs for structured scope)
- Never use `PERFORM para-A THRU para-Z` (see [Section 7](#7-structured-programming))
- Use `PERFORM VARYING` instead of manually incrementing counters
- Prefer inline PERFORM for short loops (under 5 statements); use out-of-line
  PERFORM for anything longer

### 5.2 IF / ELSE

Always use `END-IF` as a scope terminator. Never rely on periods to terminate IF
blocks.

```cobol
IF WS-AMOUNT > WS-CREDIT-LIMIT
    MOVE "OVER LIMIT" TO WS-STATUS-MESSAGE
    PERFORM NOTIFY-MANAGER
ELSE
    PERFORM PROCESS-TRANSACTION
END-IF
```

**Nested IF guidelines:**
- Maximum 3 levels of nesting. Beyond that, extract logic into separate paragraphs
  or use EVALUATE
- Align ELSE with its matching IF
- Indent the body of each IF/ELSE by 4 spaces

```cobol
IF CONDITION-A
    IF CONDITION-B
        PERFORM ACTION-AB
    ELSE
        PERFORM ACTION-A-NOT-B
    END-IF
ELSE
    PERFORM ACTION-NOT-A
END-IF
```

### 5.3 EVALUATE (Case/Switch)

EVALUATE is COBOL's structured multi-way branch. Prefer it over nested IFs when
testing multiple values of the same item.

```cobol
EVALUATE WS-TRANSACTION-TYPE
    WHEN "D"  PERFORM PROCESS-DEPOSIT
    WHEN "W"  PERFORM PROCESS-WITHDRAWAL
    WHEN "T"  PERFORM PROCESS-TRANSFER
    WHEN OTHER PERFORM HANDLE-UNKNOWN-TYPE
END-EVALUATE
```

EVALUATE TRUE is idiomatic for testing multiple unrelated conditions:

```cobol
EVALUATE TRUE
    WHEN WS-MONTHS < 2
        MOVE "newborn" TO WS-STAGE
    WHEN WS-MONTHS < 12
        MOVE "infant" TO WS-STAGE
    WHEN WS-MONTHS < 36
        MOVE "toddler" TO WS-STAGE
    WHEN OTHER
        MOVE "child" TO WS-STAGE
END-EVALUATE
```

### 5.4 Scope Terminators

Always use explicit scope terminators for compound statements:

| Statement | Terminator |
|-----------|-----------|
| `IF` | `END-IF` |
| `EVALUATE` | `END-EVALUATE` |
| `PERFORM` | `END-PERFORM` |
| `READ` | `END-READ` |
| `WRITE` | `END-WRITE` |
| `STRING` | `END-STRING` |
| `UNSTRING` | `END-UNSTRING` |
| `SEARCH` | `END-SEARCH` |
| `COMPUTE` | `END-COMPUTE` |
| `ADD` | `END-ADD` |
| `SUBTRACT` | `END-SUBTRACT` |
| `MULTIPLY` | `END-MULTIPLY` |
| `DIVIDE` | `END-DIVIDE` |
| `CALL` | `END-CALL` |
| `ACCEPT` | `END-ACCEPT` |
| `DISPLAY` | `END-DISPLAY` |

Explicit scope terminators prevent the "dangling ELSE" problem and make code
structure unambiguous. They are required for nested compound statements.

### 5.5 Periods

In the PROCEDURE DIVISION, place exactly one period at the end of each paragraph.
Do not use periods mid-paragraph to terminate statements -- use scope terminators
instead.

```cobol
*> Good: one period at end
VALIDATE-INPUT.
    IF WS-INPUT = SPACES
        MOVE "EMPTY" TO WS-ERROR-MSG
        PERFORM REPORT-ERROR
    END-IF
    .

*> Bad: period terminates the IF mid-paragraph
VALIDATE-INPUT.
    IF WS-INPUT = SPACES
        MOVE "EMPTY" TO WS-ERROR-MSG.
    PERFORM REPORT-ERROR.
```

The trailing period on its own line (after a blank line or with the dot on a line by
itself) is a common modern convention that makes the paragraph boundary visually clear.

---

## 6. String Handling

### 6.1 STRING (Concatenation)

STRING concatenates multiple source fields into a target field.

```cobol
STRING
    WS-FIRST-NAME DELIMITED BY SPACE
    " "            DELIMITED BY SIZE
    WS-LAST-NAME   DELIMITED BY SPACE
    INTO WS-FULL-NAME
END-STRING
```

**DELIMITED BY options:**
- `SIZE` -- use the entire field including trailing spaces
- `SPACE` / `SPACES` -- stop at the first space
- A literal or identifier -- stop at that character/string

**Best practices:**
- Always include `END-STRING`
- Use `ON OVERFLOW` to catch truncation
- Initialize the target field before STRING to clear previous content:

```cobol
MOVE SPACES TO WS-FULL-NAME
STRING ... INTO WS-FULL-NAME END-STRING
```

### 6.2 UNSTRING (Splitting)

UNSTRING parses a source field into multiple targets based on delimiters.

```cobol
UNSTRING WS-CSV-LINE
    DELIMITED BY ","
    INTO WS-FIELD-1
         WS-FIELD-2
         WS-FIELD-3
    TALLYING IN WS-FIELD-COUNT
END-UNSTRING
```

**Useful clauses:**
- `DELIMITER IN` -- captures which delimiter was found
- `WITH POINTER` -- tracks position for progressive parsing
- `TALLYING IN` -- counts fields processed
- `ON OVERFLOW` -- handles more fields than targets

### 6.3 INSPECT (Counting and Replacing)

INSPECT performs character-level operations within a single field.

```cobol
*> Count occurrences
MOVE 0 TO WS-COMMA-COUNT
INSPECT WS-INPUT-LINE
    TALLYING WS-COMMA-COUNT FOR ALL ","

*> Replace characters
INSPECT WS-DATA-FIELD
    REPLACING ALL ";" BY ","

*> Convert case (uppercase to lowercase)
INSPECT WS-TEXT
    CONVERTING "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    TO         "abcdefghijklmnopqrstuvwxyz"
```

**Scope modifiers:** `ALL`, `LEADING`, `FIRST`, `BEFORE INITIAL`, `AFTER INITIAL`.

**Critical:** Always initialize the tally variable to zero before INSPECT TALLYING.
INSPECT TALLYING *adds to* the tally variable; it does not reset it.

### 6.4 Reference Modification

Reference modification extracts a substring using `(start:length)` syntax with
1-based positions:

```cobol
*> Extract characters 6-7 from a date string
MOVE WS-DATE-STR(6:2) TO WS-MONTH-STR

*> Extract from position to end (omit length)
MOVE WS-INPUT(5:) TO WS-REMAINDER
```

**Best practices:**
- Ensure start position and length are within bounds; out-of-bounds causes undefined
  behavior
- Use FUNCTION LENGTH to dynamically determine field sizes
- Prefer reference modification over UNSTRING for fixed-format fields (known positions)
- For variable-format fields, prefer UNSTRING or INSPECT

### 6.5 Intrinsic Functions for Strings

```cobol
*> Trim whitespace
MOVE FUNCTION TRIM(WS-INPUT) TO WS-CLEANED

*> Get length (excluding trailing spaces)
COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-INPUT))

*> Case conversion
MOVE FUNCTION UPPER-CASE(WS-INPUT) TO WS-UPPER
MOVE FUNCTION LOWER-CASE(WS-INPUT) TO WS-LOWER

*> Reverse
MOVE FUNCTION REVERSE(WS-INPUT) TO WS-REVERSED
```

---

## 7. Structured Programming

### 7.1 Core Principles

Structured COBOL follows three constructs:

1. **Sequence** -- statements executed in order
2. **Selection** -- IF/ELSE, EVALUATE
3. **Iteration** -- PERFORM UNTIL, PERFORM VARYING

Every other control flow pattern can be expressed with these three. GO TO and ALTER
are unnecessary.

### 7.2 Paragraph Design

Each paragraph should:

- **Do one thing.** Single responsibility. If you need a comment to explain what a
  paragraph does, consider whether it should be two paragraphs with descriptive names.
- **Have a single entry point.** The paragraph name is the only way in.
- **Have a single exit point.** The last statement falls through to the paragraph's
  terminating period. Use EXIT PARAGRAPH for early returns.
- **Be short.** Aim for 20-50 lines. If a paragraph exceeds one screen (~60 lines),
  split it.
- **Communicate via well-named data items.** Input and output fields should have names
  that make the data flow obvious.

### 7.3 EXIT PARAGRAPH

`EXIT PARAGRAPH` (COBOL 2002+, supported by GnuCOBOL) provides clean early return
without GO TO:

```cobol
FORMAT-AGE.
    IF FUNCTION TRIM(WS-DOB) = SPACES
        EXIT PARAGRAPH
    END-IF
    PERFORM PARSE-DATE
    IF WS-PARSE-OK = 0
        EXIT PARAGRAPH
    END-IF
    PERFORM CALCULATE-AGE
    .
```

This is the preferred alternative to GO TO for guard-clause patterns.

### 7.4 Avoid PERFORM THRU

`PERFORM para-A THRU para-Z` executes all paragraphs from A through Z in sequence.
This is dangerous because:

- Adding a new paragraph between A and Z silently changes behavior
- The coupling is invisible -- you cannot see from para-B that it is part of a
  PERFORM range
- It defeats the purpose of named paragraphs as logical units

```cobol
*> Bad: fragile, invisible coupling
PERFORM 1000-INIT THRU 1000-EXIT

*> Good: explicit, single target
PERFORM 1000-INIT
```

If you need a multi-step sequence, make it a single paragraph that PERFORMs the steps:

```cobol
1000-INIT.
    PERFORM 1100-OPEN-FILES
    PERFORM 1200-LOAD-TABLES
    PERFORM 1300-SET-DEFAULTS
    .
```

### 7.5 Top-Down Structure

Organize programs as an inverted tree:

```
0000-MAIN
    |-- 1000-INITIALIZE
    |-- 2000-PROCESS
    |       |-- 2100-READ-RECORD
    |       |-- 2200-VALIDATE
    |       |-- 2300-TRANSFORM
    |       |-- 2400-WRITE-OUTPUT
    |-- 3000-FINALIZE
```

The main control paragraph reads like a table of contents. Lower-level paragraphs
handle progressively finer details. A reader can understand the program's overall
flow from the first 5-10 lines.

---

## 8. Copybooks and Modularity

### 8.1 COPY Statement

COPY includes the contents of an external file (copybook) at compile time:

```cobol
WORKING-STORAGE SECTION.
COPY "WS-CUSTOMER-RECORD.cpy".
COPY "WS-COMMON-CONSTANTS.cpy".
```

Copybooks are used for:
- **Shared record layouts** -- ensuring identical structure across programs
- **Common constants and working-storage groups** -- DRY principle
- **Shared procedure paragraphs** -- reusable logic

### 8.2 COPY REPLACING

REPLACING customizes a copybook when it is included, without modifying the original:

```cobol
COPY "RECORD-LAYOUT.cpy"
    REPLACING ==PREFIX== BY ==CUST==.
```

If the copybook contains:
```cobol
05  PREFIX-ID       PIC 9(8).
05  PREFIX-NAME     PIC X(40).
```

The result after REPLACING is:
```cobol
05  CUST-ID         PIC 9(8).
05  CUST-NAME       PIC X(40).
```

Use `==pseudo-text==` delimiters for multi-word replacements.

**Best practices:**
- Design copybooks with replaceable prefixes from the start
- Nested COPY with REPLACING is not allowed (COBOL 2002)
- Keep copybooks focused: one record layout or one logical group per copybook
- Version-control copybooks with the same rigor as source code

### 8.3 Modularity via Subprograms

For larger systems, separate reusable logic into called subprograms:

```cobol
*> Caller:
CALL "DATECALC" USING LK-INPUT-DATE LK-OUTPUT-JULIAN
END-CALL

*> Subprogram:
IDENTIFICATION DIVISION.
PROGRAM-ID. DATECALC.
DATA DIVISION.
LINKAGE SECTION.
01  LK-INPUT-DATE    PIC X(10).
01  LK-OUTPUT-JULIAN PIC S9(12).
PROCEDURE DIVISION USING LK-INPUT-DATE LK-OUTPUT-JULIAN.
    ...
    GOBACK
    .
```

**Subprogram guidelines:**
- Use GOBACK (not STOP RUN) to return to caller
- Define the interface in the LINKAGE SECTION
- Use LOCAL-STORAGE if the subprogram may be called recursively
- Pass data BY REFERENCE (default) or BY CONTENT (caller's copy is protected)

---

## 9. Common Idioms and Patterns

### 9.1 Guard Clauses with EXIT PARAGRAPH

Validate preconditions at the top of a paragraph and exit early on failure:

```cobol
PROCESS-RECORD.
    IF WS-INPUT = SPACES
        EXIT PARAGRAPH
    END-IF
    IF WS-RECORD-TYPE NOT = "D"
        EXIT PARAGRAPH
    END-IF
    *> Main processing follows
    ...
    .
```

### 9.2 Inline PERFORM for Counted Loops

```cobol
PERFORM VARYING WS-I FROM 1 BY 1
    UNTIL WS-I > 6
    MOVE WS-SRC-FORM(WS-I) TO WS-DST-FORM(WS-I)
END-PERFORM
```

### 9.3 EVALUATE TRUE for Multi-Condition Dispatch

```cobol
EVALUATE TRUE
    WHEN WS-AGE-MONTHS < 2
        PERFORM HANDLE-NEWBORN
    WHEN WS-AGE-MONTHS < 12
        PERFORM HANDLE-INFANT
    WHEN WS-AGE-MONTHS < 36
        PERFORM HANDLE-TODDLER
    WHEN OTHER
        PERFORM HANDLE-CHILD
END-EVALUATE
```

### 9.4 REDEFINES for Table Initialization

```cobol
01  WS-DAYS-TABLE-INIT.
    05  FILLER PIC 9(2) VALUE 31.
    05  FILLER PIC 9(2) VALUE 28.
    *> ... remaining months
01  WS-DAYS-TABLE REDEFINES WS-DAYS-TABLE-INIT.
    05  WS-DAYS PIC 9(2) OCCURS 12.
```

### 9.5 End-of-File Processing

Use an 88-level condition instead of a flag variable:

```cobol
01  WS-EOF-SWITCH           PIC X(1) VALUE "N".
    88 END-OF-FILE            VALUE "Y".
    88 NOT-END-OF-FILE        VALUE "N".

PERFORM UNTIL END-OF-FILE
    READ INPUT-FILE
        AT END SET END-OF-FILE TO TRUE
        NOT AT END PERFORM PROCESS-RECORD
    END-READ
END-PERFORM
```

### 9.6 String Template Replacement

A common pattern for template expansion (replacing `{n}` in a format string):

```cobol
INSPECT WS-TEMPLATE
    TALLYING WS-POS
    FOR CHARACTERS BEFORE INITIAL "{n}"

*> Build result: prefix + value + suffix
STRING
    WS-TEMPLATE(1:WS-POS)
    FUNCTION TRIM(WS-VALUE)
    WS-TEMPLATE(WS-POS + 3:
        WS-TEMPLATE-LEN - WS-POS - 3 + 1)
    DELIMITED BY SIZE
    INTO WS-RESULT
END-STRING
```

### 9.7 Numeric to String Conversion

Use an edited PICTURE for formatting, then TRIM:

```cobol
01  WS-NUM-INPUT       PIC 9(8).
01  WS-NUM-EDITED      PIC Z(7)9.
01  WS-NUM-STRING      PIC X(12).

MOVE WS-NUM-INPUT TO WS-NUM-EDITED
MOVE FUNCTION TRIM(WS-NUM-EDITED) TO WS-NUM-STRING
```

---

## 10. Things to Avoid

### 10.1 ALTER Statement

ALTER dynamically changes the target of a GO TO statement at runtime. It was deleted
from the COBOL 2002 standard.

```cobol
*> NEVER do this:
ALTER DISPATCH-PARA TO PROCEED TO NEW-TARGET
```

ALTER makes programs unpredictable. The GO TO target shown in the source listing is
not necessarily the target at runtime. Debugging ALTER-using code is, in the words of
one veteran, "a very frustrating experience." There is no valid modern use case.

### 10.2 GO TO Spaghetti

Unrestricted GO TO creates unstructured "spaghetti code" where control flow is
impossible to follow.

```cobol
*> Bad: arbitrary jumps create unreadable flow
    GO TO STEP-3
STEP-1.
    GO TO STEP-5
STEP-2.
    GO TO STEP-1
```

If GO TO is used at all, restrict it to:
- Forward branches to an exit point within the same paragraph/section
- Never backward branches (these are loops; use PERFORM instead)
- Never branches between sections

In modern COBOL, GO TO is almost never necessary. EXIT PARAGRAPH, PERFORM, EVALUATE,
and IF/END-IF cover all structured control flow needs.

### 10.3 NEXT SENTENCE

NEXT SENTENCE transfers control to the statement after the next period (`.`). This
is a holdover from pre-COBOL-85 code and is classified as archaic in COBOL 2023.

```cobol
*> Bad: NEXT SENTENCE goes to after the period, which may
*> skip code you didn't intend to skip
IF WS-X = 0
    NEXT SENTENCE
ELSE
    PERFORM PROCESS-X
END-IF
PERFORM ALWAYS-RUN-THIS.   *> <-- NEXT SENTENCE jumps HERE,
                            *>     past END-IF
```

**Use CONTINUE instead:**

```cobol
IF WS-X = 0
    CONTINUE
ELSE
    PERFORM PROCESS-X
END-IF
```

CONTINUE is a no-op that respects scope terminators. NEXT SENTENCE ignores them and
jumps to the next period, which leads to subtle bugs when scope terminators are added
or removed.

### 10.4 MOVE CORRESPONDING

MOVE CORRESPONDING copies all identically-named elementary items between two group
items. It is convenient but dangerous:

- If a field is added to one group but not the other, it silently does nothing
- Debugging is difficult because you cannot see which fields were moved
- If a field name matches accidentally, wrong data is moved

```cobol
*> Avoid:
MOVE CORRESPONDING WS-INPUT-REC TO WS-OUTPUT-REC

*> Prefer explicit MOVEs:
MOVE WS-INPUT-ID     TO WS-OUTPUT-ID
MOVE WS-INPUT-NAME   TO WS-OUTPUT-NAME
MOVE WS-INPUT-AMOUNT TO WS-OUTPUT-AMOUNT
```

### 10.5 Deeply Nested IFs

Limit nesting to 3 levels. Beyond that, the logic becomes unreadable and error-prone.
Extract nested conditions into separate paragraphs or use EVALUATE.

### 10.6 Commas and Semicolons as Separators

COBOL allows commas and semicolons as optional separators between statement elements.
They have no syntactic effect and reduce readability:

```cobol
*> Avoid:
ADD A, B, C GIVING D.

*> Prefer:
ADD A B C GIVING D
```

### 10.7 Level 77

Level 77 items are functionally identical to level 01 elementary items. They are
classified as obsolete. Use level 01 instead for consistency.

### 10.8 Implicit Scope Termination

Never rely on a period to terminate a compound statement. Always use explicit scope
terminators (END-IF, END-PERFORM, END-EVALUATE, etc.).

```cobol
*> Dangerous: period terminates both the IF and the PERFORM
PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
    IF WS-TABLE(WS-I) = SPACES
        MOVE "EMPTY" TO WS-STATUS.    *> <-- terminates BOTH

*> Safe: explicit terminators
PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
    IF WS-TABLE(WS-I) = SPACES
        MOVE "EMPTY" TO WS-STATUS
    END-IF
END-PERFORM
```

### 10.9 Hardcoded Literals in Procedure Division

Move magic numbers and strings to named constants in WORKING-STORAGE:

```cobol
*> Bad:
IF WS-MONTHS > 6000

*> Good (constant in WORKING-STORAGE):
01  PT-MAX-AGE-MONTHS  PIC 9(4) VALUE 6000.
...
IF WS-MONTHS > PT-MAX-AGE-MONTHS
```

---

## 11. Tooling

### 11.1 GnuCOBOL Compiler (cobc)

[GnuCOBOL](https://gnucobol.sourceforge.io/) is the primary open-source COBOL compiler.
It translates COBOL to C and then compiles with GCC/Clang.

**Essential compiler flags:**

| Flag | Purpose |
|------|---------|
| `-free` | Enable free-format source |
| `-x` | Build executable (with main) |
| `-m` | Build dynamically loadable module |
| `-Wall` | Enable most warnings |
| `-Wextra` | Enable additional warnings |
| `-Wobsolete` | Warn on obsolete features (ALTER, NEXT SENTENCE, etc.) |
| `-Warchaic` | Warn on archaic features |
| `-Wtruncate` | Warn on potential field truncation |
| `-Wimplicit-define` | Warn when data items are implicitly defined |
| `-Wunreachable` | Warn on unreachable code |
| `-Wterminator` | Warn on missing scope terminators |
| `-Wstrict-typing` | Enforce stricter type checking |

**Dialect selection:**

| Flag | Dialect |
|------|---------|
| `-std=cobol85` | COBOL-85 strict |
| `-std=cobol2002` | COBOL 2002 |
| `-std=cobol2014` | COBOL 2014 |
| `-std=default` | GnuCOBOL default (relaxed) |
| `-std=ibm` | IBM COBOL compatibility |
| `-std=mf` | Micro Focus compatibility |

**Debugging flags:**

| Flag | Purpose |
|------|---------|
| `--debug` / `-d` | Enable all runtime error checking |
| `-g` | Generate C-level debug info |
| `-ftrace` | Trace procedure execution |
| `-fstack-check` | Validate PERFORM stack |
| `-fec=all` | Enable all exception checks |

**Recommended development compilation:**

```sh
cobc -free -x -Wall -Wextra -Wobsolete -Warchaic -Wtruncate \
     -Wimplicit-define -Wunreachable -Wterminator \
     --debug -g program.cbl
```

**Recommended production compilation:**

```sh
cobc -free -x -O2 -Wall -Wextra program.cbl
```

### 11.2 Static Analysis

**Open-source / free tools:**
- [SonarQube](https://sonarqube.org) -- supports COBOL analysis with rules for code
  smells, bugs, and security vulnerabilities. Has specific rules like "ALTER should
  not be used," "GO TO should not be used," and scope terminator checks.
- [COBOL-SPA](https://github.com/vzxwco/cobol-spa) -- static program analysis for
  dependency and structure analysis.

**Commercial tools:**
- [Micro Focus COBOL Analyzer](https://www.microfocus.com/) -- enterprise-grade
  analysis for mainframe and distributed COBOL
- [CAST Highlight](https://www.castsoftware.com/products/highlight) -- cloud-based
  code analysis with COBOL support
- [Fortify Static Code Analyzer](https://www.microfocus.com/en-us/cyberres/application-security/static-code-analyzer) --
  security-focused analysis supporting COBOL
- [Understand by SciTools](https://www.scitools.com) -- code visualization, metrics,
  and standards testing

### 11.3 Testing Frameworks

- [COBOL Check](https://github.com/openmainframeproject/cobol-check) -- unit testing
  framework from the Open Mainframe Project. Uses a DSL that mirrors COBOL syntax.
  Works with GnuCOBOL and mainframe compilers.
- [GCBLUnit](https://github.com/OlegKunitsyn/gcblunit) -- lightweight unit testing
  for GnuCOBOL, installable via COBOL Package Manager.

### 11.4 Format Switching Within Source

You can mix fixed and free format in a single compilation unit using CDF directives:

```cobol
>>SOURCE FORMAT IS FREE
*> Free-format code here

>>SOURCE FORMAT IS FIXED
      *> Fixed-format code here
```

This is useful when including fixed-format copybooks in a free-format program.

---

## 12. Sources

### Standards and Official Documentation
- [GnuCOBOL Manual](https://gnucobol.sourceforge.io/doc/gnucobol.html)
- [GnuCOBOL Programmer's Guide](https://gnucobol.sourceforge.io/HTML/gnucobpg.html)
- [GnuCOBOL FAQ and How To](https://gnucobol.sourceforge.io/faq/index.html)
- [COBOL Fundamentals - GnuCOBOL Documentation](https://superbol.eu/gnucobol/gnucobpg/chapter2.html)
- [cobc Man Page (GnuCOBOL 3.2)](https://www.mankier.com/1/cobc)
- [ISO/IEC 1989:2014 COBOL Standard](https://www.iso.org/standard/51416.html)

### Coding Standards and Best Practices
- [Tony Marston's COBOL Programming Standards](https://www.tonymarston.net/cobol/cobolstandards.html)
- [MainframeMaster COBOL Coding Standards](https://www.mainframemaster.com/tutorials/cobol/coding-standards)
- [Broadcom/CA COBOL Coding Standards](https://techdocs.broadcom.com/us/en/ca-enterprise-software/it-operations-management/ca-2e/8-7/Standards/coding-standards-for-database-files/coding-standards-for-cobol-programs.html)
- [CU System COBOL Guidelines](https://www.cusys.edu/pubs/cobgdln.html)
- [ITCodeScanner COBOL Coding Standards](https://itcodescanner.com/tutorials/cobol/cobol-coding-standards)
- [zMainframes COBOL Programming Standards](https://zmainframes.com/zlog/cobol-programming-standards-ensuring-efficiency-and-maintainability/)

### Language References
- [MainframeMaster COBOL String Operations](https://www.mainframemaster.com/tutorials/cobol/quick-reference/string)
- [MainframeMaster Conditional Variables (88-Level)](https://www.mainframemaster.com/tutorials/cobol/conditional-variables)
- [MainframeMaster Procedure Branching](https://www.mainframemaster.com/tutorials/cobol/procedure-branching)
- [IBM Naming Conventions](https://www.ibm.com/docs/en/rbd/9.6.0?topic=scope-naming-conventions)

### Static Analysis and Tooling
- [COBOL Static Analysis Tools Directory](https://analysis-tools.dev/tag/cobol)
- [SonarSource COBOL Rules - ALTER](https://rules.sonarsource.com/cobol/rspec-1555/)
- [COBOL Check (Open Mainframe Project)](https://www.living-mainframe.de/2025/03/25/modernizing-cobol-testing-with-cobol-check/)
- [GCBLUnit on GitHub](https://github.com/OlegKunitsyn/gcblunit)

### History and Context
- [COBOL on Wikipedia](https://en.wikipedia.org/wiki/COBOL)
- [GnuCOBOL on Wikipedia](https://en.wikipedia.org/wiki/GnuCOBOL)
- [Structured Programming in COBOL (ACM)](https://dl.acm.org/doi/10.1145/359367.359368)
