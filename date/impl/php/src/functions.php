<?php

declare(strict_types=1);

namespace SayableDate;

use SayableDate\Locales\Locales;

function formatDate(?string $date): ?string
{
    static $default = null;
    $default ??= new SayableDate(Locales::EN());
    return $default->formatDate($date);
}

function formatDateWithYear(?string $date): ?string
{
    static $default = null;
    $default ??= new SayableDate(Locales::EN());
    return $default->formatDateWithYear($date);
}

function formatRelative(?string $date, ?string $asOf): ?string
{
    static $default = null;
    $default ??= new SayableDate(Locales::EN());
    return $default->formatRelative($date, $asOf);
}
