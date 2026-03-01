<?php

declare(strict_types=1);

namespace ParentTime;

use Closure;

/** Locale definition for age formatting. */
final readonly class AgeLocale
{
    /**
     * @param Closure(int): PluralCategory $plural
     * @param (Closure(int): string)|null $formatNumber
     * @param (Closure(int, string): string)|null $formatUnit
     */
    public function __construct(
        public string $code,
        public Closure $plural,
        public Units $units,
        public string $half,
        public string $delimiter,
        public string $justBorn,
        public Stages $stages,
        public ?CompactnessOverride $short = null,
        public ?CompactnessOverride $compact = null,
        public ?Closure $formatNumber = null,
        public ?Closure $formatUnit = null,
    ) {}
}
