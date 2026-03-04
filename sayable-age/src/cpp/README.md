# sayable-age — C++

A thoughtful time formatting library that reflects how we think about little ones.

```cpp
#include <sayableage/sayableage.hpp>
#include <iostream>

auto age = sayableage::format_age("2025-06-01", "2025-06-15");
std::cout << *age << std::endl;  // "2 weeks"
```

## Requirements

- C++17 or later
- CMake 3.14+
- Zero external dependencies

## Building

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

## Usage

```cpp
#include <sayableage/sayableage.hpp>
#include <sayableage/locales.hpp>
#include <iostream>

int main() {
    // Free functions — English default
    auto age = sayableage::format_age("2025-06-15", "2025-06-15");
    if (age) std::cout << *age << std::endl;  // "Newborn"

    auto age2 = sayableage::format_age("2025-06-01", "2025-06-15");
    if (age2) std::cout << *age2 << std::endl;  // "2 weeks"

    auto stage = sayableage::format_stage("2025-01-15", "2025-06-15");
    if (stage) std::cout << *stage << std::endl;  // "Infant"

    // Returns std::nullopt for empty/future dates or ages exceeding 500 years
    auto nothing = sayableage::format_age("");  // std::nullopt

    // Class-based with locale
    sayableage::SayableAge pt(sayableage::locales::EN);
    auto age3 = pt.format_age("2022-06-15", "2025-12-15");
    if (age3) std::cout << *age3 << std::endl;  // "3½ years"

    return 0;
}
```

## Internationalization

```cpp
#include <sayableage/sayableage.hpp>
#include <sayableage/locales.hpp>

sayableage::SayableAge pt(sayableage::locales::JA);
auto age = pt.format_age("2025-01-01", "2025-07-15");
// *age == "6ヶ月"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```cpp
sayableage::SayableAge normal(sayableage::locales::EN);                              // "3 months"
sayableage::SayableAge compact(sayableage::locales::EN, sayableage::Compactness::Short);   // "3 mo"
sayableage::SayableAge tiny(sayableage::locales::EN, sayableage::Compactness::Compact);    // "3m"
```

## API

```cpp
namespace sayableage {

class SayableAge {
public:
    explicit SayableAge(const AgeLocale& locale,
                        Compactness compactness = Compactness::Normal);

    std::optional<std::string> format_age(const std::string& date_of_birth,
                                          const std::string& as_of = "") const;

    std::optional<std::string> format_stage(const std::string& date_of_birth,
                                            const std::string& as_of = "") const;
};

// Free functions — English default
std::optional<std::string> format_age(const std::string& date_of_birth,
                                      const std::string& as_of = "");

std::optional<std::string> format_stage(const std::string& date_of_birth,
                                        const std::string& as_of = "");

} // namespace sayableage
```

**Parameters:**

- `date_of_birth` — `YYYY-MM-DD` string. Returns `std::nullopt` for empty strings.
- `as_of` — Reference date as `YYYY-MM-DD`. Empty string defaults to today.

**Returns:** `std::optional<std::string>` — the formatted string, or `std::nullopt` if input is invalid, DOB is in the future, or age exceeds 500 years.

## Development

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build
ctest --test-dir build --output-on-failure
```

## Code quality

- 16 compiler warning flags + `-Werror`
- clang-tidy with 7 check categories and naming conventions
- `CMAKE_CXX_EXTENSIONS OFF` for portable C++17
- See [code quality docs](../../docs/code-quality-compiled.md#c) for details

## License

[MIT](../../LICENSE.md)
