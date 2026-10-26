<?php

declare(strict_types=1);

namespace SayableDate;

/** Locale definition for date formatting. */
final class DateLocale
{
    /**
     * @param list<string> $months 12 month names
     * @param list<string> $weekdays 7 weekday names (0=Sunday)
     * @param array<int|string, string> $dayFormatExceptions
     * @param list<string>|null $monthsInDate
     */
    public function __construct(
        public readonly string $code,
        public readonly array $months,
        public readonly array $weekdays,
        public readonly string $dayFormat,
        public readonly array $dayFormatExceptions = [],
        public readonly string $datePattern = '{day} {month}',
        public readonly string $datePatternWithYear = '{day} {month} {year}',
        public readonly string $today = 'today',
        public readonly string $tomorrow = 'tomorrow',
        public readonly string $yesterday = 'yesterday',
        public readonly ?string $dayAfterTomorrow = null,
        public readonly ?string $dayBeforeYesterday = null,
        public readonly ?string $thisWeekday = null,
        public readonly ?string $nextWeekday = null,
        public readonly ?string $lastWeekday = null,
        public readonly ?array $monthsInDate = null,
        public readonly ?CompactnessOverride $short = null,
        public readonly ?CompactnessOverride $compact = null,
    ) {}
}
