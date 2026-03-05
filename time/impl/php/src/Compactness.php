<?php

declare(strict_types=1);

namespace SayableTime;

/** Compactness level for time formatting output. */
enum Compactness
{
    case Normal;
    case Short;
    case Compact;
}
