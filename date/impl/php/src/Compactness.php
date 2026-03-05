<?php

declare(strict_types=1);

namespace SayableDate;

/** Compactness level for date formatting output. */
enum Compactness
{
    case Normal;
    case Short;
    case Compact;
}
