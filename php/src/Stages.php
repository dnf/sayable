<?php

declare(strict_types=1);

namespace ParentTime;

/** Developmental stage labels. */
final class Stages
{
    public function __construct(
        public readonly StageLabel $newborn,
        public readonly StageLabel $infant,
        public readonly StageLabel $toddler,
        public readonly StageLabel $child,
        public readonly StageLabel $teenager,
        public readonly StageLabel $adult,
    ) {}
}
