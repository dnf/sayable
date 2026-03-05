<?php

declare(strict_types=1);

namespace SayableTime;

/** Digital clock display configuration for short/compact modes. */
final class ShortClockConfig
{
    /**
     * @param array{string, string}|null $amPm
     */
    public function __construct(
        public readonly bool $use24h,
        public readonly string $format,
        public readonly ?array $amPm = null,
    ) {}
}
