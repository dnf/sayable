<?php

declare(strict_types=1);

namespace SayableDuration;

/** CLDR-inspired plural categories. */
enum PluralCategory: string
{
    case Zero = 'zero';
    case One = 'one';
    case Two = 'two';
    case Few = 'few';
    case Many = 'many';
    case Other = 'other';
}
