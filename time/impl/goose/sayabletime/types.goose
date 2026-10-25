// sayable-time Goose implementation — types.

namespace sayabletime;

enum Compactness { Normal, Short, Compact }

// Spoken clock: twelve hour names (index 0 is twelve o'clock) and one
// pattern per five-minute bucket, with {h} and {next_h} placeholders.
struct ClockConfig {
    hours: (const u8[:])[12],
    midnight: const u8[:],
    noon: const u8[:],
    patterns: (const u8[:])[12],
}

// Digital clock for short and compact modes. `format` uses {h}, {mm} and,
// on a 12-hour clock, {ampm}.
struct ShortClockConfig {
    use_24h: bool = true,
    format: const u8[:] = "{h}:{mm}",
    am_pm: (const u8[:])[2] = ["AM", "PM"],
}

// A short or compact override. has_clock keeps "absent" distinct from a
// default clock: without one, the mode falls back to the spoken clock.
struct CompactnessOverride {
    has_clock: bool = false,
    clock: ShortClockConfig = ShortClockConfig { .. },
}

struct TimeLocale {
    code: const u8[:],
    clock: ClockConfig,
    short_override: CompactnessOverride = CompactnessOverride { .. },
    compact_override: CompactnessOverride = CompactnessOverride { .. },
}
