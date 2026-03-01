<?php

declare(strict_types=1);

namespace ParentTime;

use Closure;

/** Locale definition for age formatting. */
final class AgeLocale
{
    /**
     * @param Closure(int): PluralCategory $plural
     * @param (Closure(int): string)|null $formatNumber
     * @param (Closure(int, string): string)|null $formatUnit
     */
    public function __construct(
        public readonly string $code,
        public readonly Closure $plural,
        public readonly Units $units,
        public readonly string $half,
        public readonly string $delimiter,
        public readonly string $justBorn,
        public readonly Stages $stages,
        public readonly ?CompactnessOverride $short = null,
        public readonly ?CompactnessOverride $compact = null,
        public readonly ?Closure $formatNumber = null,
        public readonly ?Closure $formatUnit = null,
    ) {}
}
