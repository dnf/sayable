<?php

declare(strict_types=1);

namespace SayableTime;

/** Locale-aware clock time formatter. */
final class SayableTime
{
    public const VERSION = '0.5.0';

    private readonly ?ShortClockConfig $shortClock;

    public function __construct(
        private readonly TimeLocale $locale,
        Compactness $compactness = Compactness::Normal,
    ) {
        $ovr = match ($compactness) {
            Compactness::Short => $locale->short,
            Compactness::Compact => $locale->compact,
            Compactness::Normal => null,
        };
        $this->shortClock = $ovr?->clock;
    }

    public function formatTime(?string $input): ?string
    {
        if ($input === null || $input === '') {
            return null;
        }
        $parsed = self::parseTime($input);
        if ($parsed === null) {
            return null;
        }
        [$hour, $minute] = $parsed;

        if ($this->shortClock !== null) {
            return $this->formatDigital($hour, $minute);
        }
        return $this->formatNatural($hour, $minute);
    }

    private function formatNatural(int $hour, int $minute): string
    {
        $clock = $this->locale->clock;
        $rounded = self::roundTo5($minute);
        $h = $hour;
        if ($rounded === 60) {
            $rounded = 0;
            $h = ($h + 1) % 24;
        }
        if ($rounded === 0) {
            if ($h === 0) {
                return $clock->midnight;
            }
            if ($h === 12) {
                return $clock->noon;
            }
        }
        $h12 = $h % 12;
        $nextH12 = ($h + 1) % 12;
        $hName = $clock->hours[$h12];
        $nextHName = $clock->hours[$nextH12];
        $pattern = $clock->patterns[$rounded] ?? $clock->patterns[0] ?? '{h}';
        return \str_replace(['{h}', '{next_h}'], [$hName, $nextHName], $pattern);
    }

    private function formatDigital(int $hour, int $minute): string
    {
        $sc = $this->shortClock;
        \assert($sc !== null);
        $fmt = $sc->format;
        if ($sc->use24h) {
            return \str_replace(['{h}', '{mm}'], [(string) $hour, \str_pad((string) $minute, 2, '0', \STR_PAD_LEFT)], $fmt);
        }
        $h12 = $hour % 12;
        if ($h12 === 0) {
            $h12 = 12;
        }
        $amPm = $sc->amPm ?? ['AM', 'PM'];
        $ampmStr = $hour < 12 ? $amPm[0] : $amPm[1];
        return \str_replace(
            ['{h}', '{mm}', '{ampm}'],
            [(string) $h12, \str_pad((string) $minute, 2, '0', \STR_PAD_LEFT), $ampmStr],
            $fmt,
        );
    }

    /**
     * A clock time (H:MM or HH:MM, optional :SS and fraction, optional zone
     * suffix, which is ignored), alone or after the T of an ISO datetime.
     */
    private const CLOCK_TIME = '/\A(?:([0-9]{4})-([0-9]{2})-([0-9]{2})T)?([0-9]{1,2}):([0-9]{2})'
        . '(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\z/';

    /** @return array{int, int}|null */
    private static function parseTime(string $input): ?array
    {
        if (\preg_match(self::CLOCK_TIME, $input, $m) !== 1) {
            return null;
        }
        if ($m[1] !== '' && !self::isRealDate((int) $m[1], (int) $m[2], (int) $m[3])) {
            return null;
        }
        $hour = (int) $m[4];
        $minute = (int) $m[5];
        $second = (int) ($m[6] ?? 0);
        if ($hour > 23 || $minute > 59 || $second > 59) {
            return null;
        }
        return [$hour, $minute];
    }

    private static function isRealDate(int $year, int $month, int $day): bool
    {
        if ($month < 1 || $month > 12 || $day < 1) {
            return false;
        }
        $leap = $year % 4 === 0 && ($year % 100 !== 0 || $year % 400 === 0);
        $lastDay = match ($month) {
            2 => $leap ? 29 : 28,
            4, 6, 9, 11 => 30,
            default => 31,
        };
        return $day <= $lastDay;
    }

    private static function roundTo5(int $minute): int
    {
        return (int) ((\intdiv($minute + 2, 5)) * 5);
    }
}
