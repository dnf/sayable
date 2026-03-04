<?php

declare(strict_types=1);

namespace SayableAge;

/** Unit form definitions for all four time units. */
final class Units
{
    /**
     * @param array<string, string>|string $day
     * @param array<string, string>|string $week
     * @param array<string, string>|string $month
     * @param array<string, string>|string $year
     */
    public function __construct(
        public readonly string|array $day,
        public readonly string|array $week,
        public readonly string|array $month,
        public readonly string|array $year,
    ) {}
}
