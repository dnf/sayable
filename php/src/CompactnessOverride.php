<?php

declare(strict_types=1);

namespace ParentTime;

/** Optional overrides for short/compact display modes. */
final readonly class CompactnessOverride
{
    /**
     * @param (array<string, string>|string)|null $day
     * @param (array<string, string>|string)|null $week
     * @param (array<string, string>|string)|null $month
     * @param (array<string, string>|string)|null $year
     */
    public function __construct(
        public string|array|null $day = null,
        public string|array|null $week = null,
        public string|array|null $month = null,
        public string|array|null $year = null,
        public ?string $half = null,
        public ?string $delimiter = null,
        public ?string $justBorn = null,
    ) {}
}
