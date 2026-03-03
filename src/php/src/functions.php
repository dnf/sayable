<?php

declare(strict_types=1);

namespace ParentTime;

use ParentTime\Locales\Locales;

/**
 * Human-friendly age string using the default English locale (normal compactness).
 *
 * @param string|null $dateOfBirth YYYY-MM-DD date string
 * @param string|null $asOf YYYY-MM-DD reference date (defaults to today)
 */
function formatAge(?string $dateOfBirth, ?string $asOf = null): ?string
{
    static $default = null;
    $default ??= new ParentTime(Locales::EN());
    return $default->formatAge($dateOfBirth, $asOf);
}

/**
 * Developmental stage label using the default English locale.
 *
 * @param string|null $dateOfBirth YYYY-MM-DD date string
 * @param string|null $asOf YYYY-MM-DD reference date (defaults to today)
 * @param string|null $gender 'f' for feminine, null for default/masculine
 */
function formatStage(?string $dateOfBirth, ?string $asOf = null, ?string $gender = null): ?string
{
    static $default = null;
    $default ??= new ParentTime(Locales::EN());
    return $default->formatStage($dateOfBirth, $asOf, $gender);
}
