# Input formats

Every implementation must accept exactly the inputs described here and return **no value** (null / `None` / `nil` / an absent optional; CLI exit 1) for everything else. Being stricter or more lenient than this is a bug, because the implementations would no longer agree. The canonical tests pin each rule: age section 33, date 13–16, time 10, duration 19–20.

Parsing is strict on purpose. A lenient parser accepts input that another language rejects, and a nonsense date that still produces a confident answer is worse than no answer.

## Dates

`YYYY-MM-DD`: exactly ten characters, with ASCII digits and dashes at positions 4 and 7.

- The month is `01`–`12`, and the day must exist in that month (Gregorian calendar, leap years by the 4/100/400 rule). `2025-02-30`, `2025-13-01`, `2025-06-00` and `2023-02-29` are invalid; `2024-02-29` is valid.
- Every four-digit year is accepted, including `0000` (proleptic Gregorian). The age library's 500-year limit rejects very old dates separately.
- Unpadded forms (`2025-6-1`) and surrounding whitespace (`" 2025-06-01"`) are invalid.
- **age** (`dateOfBirth`, `asOf`): the input must be the date alone. `2025-06-15T10:00:00` is invalid.
- **date** (`format_date`, `format_date_with_year`, `format_relative`): the date may be followed by `T` and anything else, as in an ISO datetime. Only the first ten characters are read, and they must be a valid date.

## Clock times (time)

`H:MM` or `HH:MM`, optionally followed by `:SS`, an optional `.` plus one or more digits, and an optional zone suffix `Z` or `±HH:MM`.

- Hour `0`–`23` (one or two digits), minute `00`–`59` (always two digits), second `00`–`59`.
- Seconds, fraction and zone are validated but don't change the result; the zone is **not** applied.
- An ISO datetime `YYYY-MM-DDT<clock time>` is accepted when its date part is valid by the rules above.
- `24:00`, `9:5`, `" 9:30"` and `"9:30 "` are invalid.

## Timestamps (duration)

`YYYY-MM-DDTHH:MM`, then optional `:SS`, an optional `.` plus digits, and an optional zone suffix `Z` or `±HH:MM`. The date part follows the date rules above, and the clock part follows the clock-time rules.

- Minutes are required: `2025-01-15T10` is invalid, `2025-01-15T10:00` is valid.
- The zone suffix is accepted but not applied, so both timestamps are compared as written.

## Durations: the 500-year ceiling

A duration longer than **6000 months (500 years)** has no value. This is the same ceiling as sayable-age. Months are counted the way the formatter already counts them: whole days divided by 30.44, rounded.

- `format_duration(15778800000)` (500 Julian years) is `500 years`; `format_duration(15800000000)` has no value.
- The ceiling applies to `format_duration` in both seconds and timestamp mode, and to `format_since` and `format_until`.
- Durations must be computed without overflow up to the ceiling. Use 64-bit arithmetic, or check the range before converting, in languages with 32-bit integers.

## License

[MIT](../LICENSE.md)
