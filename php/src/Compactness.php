<?php

declare(strict_types=1);

namespace ParentTime;

/** Compactness level for age formatting output. */
enum Compactness
{
    case Normal;
    case Short;
    case Compact;
}
