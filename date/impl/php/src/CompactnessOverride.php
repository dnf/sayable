<?php

declare(strict_types=1);

namespace SayableDate;

/** Optional overrides for short/compact display modes. */
final class CompactnessOverride
{
    /**
     * @param list<string>|null $months
     * @param list<string>|null $monthsInDate
     * @param list<string>|null $weekdays
     * @param array<string, string>|null $dayFormatExceptions
     */
    public function __construct(
        public readonly ?array $months = null,
        public readonly ?array $monthsInDate = null,
        public readonly ?array $weekdays = null,
        public readonly ?string $dayFormat = null,
        public readonly ?array $dayFormatExceptions = null,
        public readonly ?string $datePattern = null,
        public readonly ?string $datePatternWithYear = null,
        public readonly ?string $today = null,
        public readonly ?string $tomorrow = null,
        public readonly ?string $yesterday = null,
    ) {}
}
