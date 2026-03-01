<?php

declare(strict_types=1);

namespace ParentTime;

/** Unit form definitions for all four time units. */
final readonly class Units
{
    /**
     * @param array<string, string>|string $day
     * @param array<string, string>|string $week
     * @param array<string, string>|string $month
     * @param array<string, string>|string $year
     */
    public function __construct(
        public string|array $day,
        public string|array $week,
        public string|array $month,
        public string|array $year,
    ) {}
}
