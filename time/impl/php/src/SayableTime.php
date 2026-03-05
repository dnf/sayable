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

    /** @return array{int, int}|null */
    private static function parseTime(string $input): ?array
    {
        $t = $input;
        $tIdx = \strpos($t, 'T');
        if ($tIdx !== false) {
            $t = \substr($t, $tIdx + 1);
        }
        $plusIdx = \strpos($t, '+');
        if ($plusIdx !== false) {
            $t = \substr($t, 0, $plusIdx);
        }
        $zIdx = \strpos($t, 'Z');
        if ($zIdx !== false) {
            $t = \substr($t, 0, $zIdx);
        }
        $parts = \explode(':', $t);
        if (\count($parts) < 2) {
            return null;
        }
        if (!\ctype_digit($parts[0])) {
            return null;
        }
        $minStr = \explode('.', $parts[1])[0];
        if (!\ctype_digit($minStr)) {
            return null;
        }
        $hour = (int) $parts[0];
        $minute = (int) $minStr;
        if ($hour < 0 || $hour > 23 || $minute < 0 || $minute > 59) {
            return null;
        }
        return [$hour, $minute];
    }

    private static function roundTo5(int $minute): int
    {
        return (int) ((\intdiv($minute + 2, 5)) * 5);
    }
}
