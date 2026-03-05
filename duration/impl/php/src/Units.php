<?php

declare(strict_types=1);

namespace SayableDuration;

/** Unit form definitions for all seven time units. */
final class Units
{
    /**
     * @param array<string, string>|string $second
     * @param array<string, string>|string $minute
     * @param array<string, string>|string $hour
     * @param array<string, string>|string $day
     * @param array<string, string>|string $week
     * @param array<string, string>|string $month
     * @param array<string, string>|string $year
     */
    public function __construct(
        public readonly string|array $second,
        public readonly string|array $minute,
        public readonly string|array $hour,
        public readonly string|array $day,
        public readonly string|array $week,
        public readonly string|array $month,
        public readonly string|array $year,
    ) {}
}
