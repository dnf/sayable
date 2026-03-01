<?php

declare(strict_types=1);

namespace ParentTime;

/** A stage label with optional feminine form. */
final class StageLabel
{
    public function __construct(
        public readonly string $label,
        public readonly ?string $f = null,
    ) {}

    /** Resolve the label for the given gender. */
    public function resolve(?string $gender = null): string
    {
        if ($this->f !== null && $gender === 'f') {
            return $this->f;
        }

        return $this->label;
    }
}
