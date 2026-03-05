<?php

declare(strict_types=1);

namespace SayableTime;

use SayableTime\Locales\Locales;

function formatTime(?string $input): ?string
{
    static $default = null;
    $default ??= new SayableTime(Locales::EN());
    return $default->formatTime($input);
}
