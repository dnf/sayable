<?php

declare(strict_types=1);

namespace ParentTime;

/** Developmental stage labels. */
final readonly class Stages
{
    public function __construct(
        public StageLabel $newborn,
        public StageLabel $infant,
        public StageLabel $toddler,
        public StageLabel $child,
        public StageLabel $teenager,
        public StageLabel $adult,
    ) {}
}
