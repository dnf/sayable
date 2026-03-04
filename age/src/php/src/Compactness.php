<?php

declare(strict_types=1);

namespace SayableAge;

/** Compactness level for age formatting output. */
enum Compactness
{
    case Normal;
    case Short;
    case Compact;
}
