<?php

declare(strict_types=1);

namespace SayableDuration;

/** Optional overrides for short/compact display modes. */
final class CompactnessOverride
{
    /**
     * @param (array<string, string>|string)|null $second
     * @param (array<string, string>|string)|null $minute
     * @param (array<string, string>|string)|null $hour
     * @param (array<string, string>|string)|null $day
     * @param (array<string, string>|string)|null $week
     * @param (array<string, string>|string)|null $month
     * @param (array<string, string>|string)|null $year
     */
    public function __construct(
        public readonly string|array|null $second = null,
        public readonly string|array|null $minute = null,
        public readonly string|array|null $hour = null,
        public readonly string|array|null $day = null,
        public readonly string|array|null $week = null,
        public readonly string|array|null $month = null,
        public readonly string|array|null $year = null,
        public readonly ?string $half = null,
        public readonly ?string $delimiter = null,
        public readonly ?string $ago = null,
        public readonly ?string $inFuture = null,
    ) {}
}
