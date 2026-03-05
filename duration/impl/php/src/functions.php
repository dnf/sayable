<?php

declare(strict_types=1);

namespace SayableDuration;

use SayableDuration\Locales\Locales;

function formatDuration(int $seconds): ?string
{
    static $default = null;
    $default ??= new SayableDuration(Locales::EN());
    return $default->formatDuration($seconds);
}

function formatDurationIso(string $start, string $end): ?string
{
    static $default = null;
    $default ??= new SayableDuration(Locales::EN());
    return $default->formatDurationIso($start, $end);
}

function formatSince(?string $start, ?string $asOf): ?string
{
    static $default = null;
    $default ??= new SayableDuration(Locales::EN());
    return $default->formatSince($start, $asOf);
}

function formatUntil(?string $target, ?string $asOf): ?string
{
    static $default = null;
    $default ??= new SayableDuration(Locales::EN());
    return $default->formatUntil($target, $asOf);
}
