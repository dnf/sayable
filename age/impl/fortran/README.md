# sayable-age -- Fortran

Human-friendly age formatting — how parents actually talk about little ones.

```fortran
use sayableage
use sayableage_locales

type(pt_locale), pointer :: en
en => pt_get_locale('en')
print *, trim(pt_format_age(en, PT_NORMAL, '2025-06-01', '2025-06-15'))
! "2 weeks"
```

## Building

CMake build with Modern Fortran (2008+) -- no external dependencies.

```bash
cd src/fortran
cmake -B build
cmake --build build
```

Requires a Fortran 2008-compatible compiler (gfortran 4.8+).

## Usage

```fortran
use sayableage
use sayableage_locales
use sayableage_types

type(pt_locale), pointer :: en
character(len=PT_MAX_STR_LEN) :: result

en => pt_get_locale('en')

result = pt_format_age(en, PT_NORMAL, '2025-01-15', '2025-07-15')
print *, trim(result)  ! "6 months"

result = pt_format_stage(en, '2025-01-15', '2025-06-15')
print *, trim(result)  ! "Infant"
```

## Internationalization

```fortran
type(pt_locale), pointer :: ja
ja => pt_get_locale('ja')
result = pt_format_age(ja, PT_NORMAL, '2025-01-01', '2025-07-15')
print *, trim(result)  ! "6ヶ月"
```

110 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

```fortran
function pt_format_age(locale, compactness, dob, as_of) result(res)
  type(pt_locale), intent(in), target :: locale
  integer, intent(in) :: compactness     ! PT_NORMAL, PT_SHORT, or PT_COMPACT
  character(len=*), intent(in) :: dob    ! YYYY-MM-DD
  character(len=*), intent(in) :: as_of  ! YYYY-MM-DD
  character(len=PT_MAX_STR_LEN) :: res

function pt_format_stage(locale, dob, as_of, gender) result(res)
  type(pt_locale), intent(in) :: locale
  character(len=*), intent(in) :: dob, as_of
  character(len=*), intent(in), optional :: gender  ! "m" or "f"
  character(len=PT_MAX_STR_LEN) :: res

function pt_get_locale(code) result(loc)
  character(len=*), intent(in) :: code
  type(pt_locale), pointer :: loc  ! null if not found
```

**Parameters:**

- `dob` -- `YYYY-MM-DD` string.
- `as_of` -- Reference date (`YYYY-MM-DD`).

**Returns:** `pt_format_age` and `pt_format_stage` return fixed-length strings; use `trim()` to get the meaningful content. `pt_get_locale` returns a pointer, or null if the code is not found.

## Development

```bash
cmake -B build && cmake --build build
ctest --test-dir build --output-on-failure   # Run tests
```

## License

[MIT](../../LICENSE.md)
