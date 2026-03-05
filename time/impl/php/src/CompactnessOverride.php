<?php

declare(strict_types=1);

namespace SayableTime;

/** Optional overrides for short/compact display modes. */
final class CompactnessOverride
{
    public function __construct(
        public readonly ?ShortClockConfig $clock = null,
    ) {}
}
