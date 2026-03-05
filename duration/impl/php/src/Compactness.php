<?php

declare(strict_types=1);

namespace SayableDuration;

/** Compactness level for duration formatting output. */
enum Compactness
{
    case Normal;
    case Short;
    case Compact;
}
