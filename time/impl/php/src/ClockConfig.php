<?php

declare(strict_types=1);

namespace SayableTime;

/** Natural language clock reading configuration. */
final class ClockConfig
{
    /**
     * @param list<string> $hours 12 hour names
     * @param array<int, string> $patterns minute patterns
     */
    public function __construct(
        public readonly array $hours,
        public readonly string $midnight,
        public readonly string $noon,
        public readonly array $patterns,
    ) {}
}
