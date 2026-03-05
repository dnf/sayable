<?php

declare(strict_types=1);

namespace SayableTime;

/** Locale definition for time formatting. */
final class TimeLocale
{
    public function __construct(
        public readonly string $code,
        public readonly ClockConfig $clock,
        public readonly ?CompactnessOverride $short = null,
        public readonly ?CompactnessOverride $compact = null,
    ) {}
}
