# parent-time — Dart

A thoughtful time formatting library that reflects how we think about little ones.

```dart
import 'package:parent_time/parent_time.dart';

final age = formatAge('2025-06-01', '2025-06-15');
print(age);  // "2 weeks"
```

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  parent_time:
    path: ../parent-time/src/dart  # or publish to pub.dev
```

Requires Dart 3.0+. Zero external dependencies.

## Usage

```dart
import 'package:parent_time/parent_time.dart';

void main() {
  // Top-level functions — English default
  final age = formatAge('2025-01-15', '2025-07-15');
  print(age);  // "6 months"

  final stage = formatStage('2025-01-15', '2025-06-15');
  print(stage);  // "Infant"

  // Returns null for empty/future dates or ages exceeding 500 years
  print(formatAge(''));  // null

  // Class-based with locale
  final pt = ParentTime(getLocale('en')!);
  print(pt.formatAge('2022-06-15', '2025-12-15'));  // "3½ years"
  print(pt.formatStage('2022-06-15', '2025-06-15'));  // "Child"
}
```

## Internationalization

```dart
final pt = ParentTime(getLocale('ja')!);
final age = pt.formatAge('2025-01-01', '2025-07-15');
print(age);  // "6ヶ月"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```dart
final normal  = ParentTime(getLocale('en')!);                        // "3 months"
final short   = ParentTime(getLocale('en')!, Compactness.short);     // "3 mo"
final compact = ParentTime(getLocale('en')!, Compactness.compact);   // "3m"
```

## API

```dart
// Class — locale set once at construction
class ParentTime {
  factory ParentTime(AgeLocale locale, [Compactness compactness]);
  String? formatAge(String dateOfBirth, [String? asOf]);
  String? formatStage(String dateOfBirth, [String? asOf, String? gender]);
}

// Top-level functions — English default
String? formatAge(String dateOfBirth, [String? asOf]);
String? formatStage(String dateOfBirth, [String? asOf, String? gender]);

// Locale lookup
AgeLocale? getLocale(String code);
```

**Parameters:**

- `dateOfBirth` — `YYYY-MM-DD` string. Returns `null` for empty strings.
- `asOf` — Optional reference date. Defaults to today.

**Returns:** `String?` (nullable string), or `null` if input is missing, DOB is in the future, or age exceeds 500 years.

## Development

```bash
dart pub get           # Install dependencies
dart test              # Run tests
dart analyze           # Static analysis
```

## License

[MIT](../../LICENSE.md)
