#pragma once

namespace sayableage {
namespace testing {

/// Override the "today" date for testing.
/// Call set_today(y, m, d) to freeze time.
/// Call clear_today() to restore the system clock.
void set_today(int year, int month, int day);
void clear_today();

} // namespace testing
} // namespace sayableage
