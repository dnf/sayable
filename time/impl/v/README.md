# sayable-time — V

Human-friendly clock time formatting — tells time the way people talk.

```v
import locales

fn main() {
    st := locales.new_sayable_time(locales.get_time_locale('en')!, .normal)
    println(st.format_time('14:15') or { '' })  // "a quarter past two"
}
```

## Installation

Copy the V source files into your project. Requires V 0.4+. Zero external dependencies.

## Usage

```v
import locales

fn main() {
    en := locales.get_time_locale('en')!

    // Normal compactness (spoken time)
    st := locales.new_sayable_time(en, .normal)
    println(st.format_time('00:00') or { '' })   // "midnight"
    println(st.format_time('12:00') or { '' })   // "noon"
    println(st.format_time('15:00') or { '' })   // "three o'clock"
    println(st.format_time('14:15') or { '' })   // "a quarter past two"
    println(st.format_time('09:30') or { '' })   // "half past nine"
    println(st.format_time('10:45') or { '' })   // "a quarter to eleven"

    // Short compactness (digital with AM/PM)
    st_short := locales.new_sayable_time(en, .short)
    println(st_short.format_time('14:15') or { '' })  // "2:15 PM"

    // Compact
    st_compact := locales.new_sayable_time(en, .compact)
    println(st_compact.format_time('14:15') or { '' })  // "2:15p"
}
```

## Internationalization

```v
ja := locales.get_time_locale('ja')!
st := locales.new_sayable_time(ja, .normal)
println(st.format_time('15:30') or { '' })  // "三時半"
```

## API

```v
fn new_sayable_time(locale &TimeLocale, compactness Compactness) SayableTime
fn (st &SayableTime) format_time(input_str string) ?string
fn get_time_locale(code string) ?TimeLocale
```

**Parameters:**

- `input_str` — Time as `HH:MM` or ISO datetime string.

**Returns:** `?string` — optional string. Returns `none` if input is missing or invalid.

## Development

```bash
v test .
```

## License

[MIT](../../LICENSE.md)
