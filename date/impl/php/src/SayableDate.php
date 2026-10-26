<?php

declare(strict_types=1);

namespace SayableDate;

/** Locale-aware date formatter. */
final class SayableDate
{
    public const VERSION = '0.5.0';

    /** @var list<string> */
    private readonly array $months;
    /** @var list<string>|null */
    private readonly ?array $monthsInDate;
    /** @var list<string> */
    private readonly array $weekdays;
    private readonly string $dayFormat;
    /** @var array<string, string> */
    private readonly array $dayFormatExceptions;
    private readonly string $datePattern;
    private readonly string $datePatternWithYear;
    private readonly string $today;
    private readonly string $tomorrow;
    private readonly string $yesterday;
    private readonly Compactness $compactness;

    public function __construct(
        private readonly DateLocale $locale,
        Compactness $compactness = Compactness::Normal,
    ) {
        $this->compactness = $compactness;
        $ovr = match ($compactness) {
            Compactness::Short => $locale->short,
            Compactness::Compact => $locale->compact,
            Compactness::Normal => null,
        };

        $this->months = $ovr?->months ?? $locale->months;
        $this->monthsInDate = $ovr?->monthsInDate ?? $locale->monthsInDate;
        $this->weekdays = $ovr?->weekdays ?? $locale->weekdays;
        $this->dayFormat = $ovr?->dayFormat ?? $locale->dayFormat;
        if ($ovr !== null && $ovr->dayFormat !== null && $ovr->dayFormatExceptions === null) {
            $this->dayFormatExceptions = [];
        } else {
            $this->dayFormatExceptions = $ovr?->dayFormatExceptions ?? $locale->dayFormatExceptions;
        }
        $this->datePattern = $ovr?->datePattern ?? $locale->datePattern;
        $this->datePatternWithYear = $ovr?->datePatternWithYear ?? $locale->datePatternWithYear;
        $this->today = $ovr?->today ?? $locale->today;
        $this->tomorrow = $ovr?->tomorrow ?? $locale->tomorrow;
        $this->yesterday = $ovr?->yesterday ?? $locale->yesterday;
    }

    public function formatDate(?string $date): ?string
    {
        if ($date === null || $date === '') {
            return null;
        }
        $parsed = self::parseDate($date);
        if ($parsed === null) {
            return null;
        }
        return $this->formatAbsolute($parsed[0], $parsed[1], $parsed[2], false);
    }

    public function formatDateWithYear(?string $date): ?string
    {
        if ($date === null || $date === '') {
            return null;
        }
        $parsed = self::parseDate($date);
        if ($parsed === null) {
            return null;
        }
        return $this->formatAbsolute($parsed[0], $parsed[1], $parsed[2], true);
    }

    public function formatRelative(?string $date, ?string $asOf): ?string
    {
        if ($date === null || $date === '' || $asOf === null || $asOf === '') {
            return null;
        }
        $parsedDate = self::parseDate($date);
        $parsedAsOf = self::parseDate($asOf);
        if ($parsedDate === null || $parsedAsOf === null) {
            return null;
        }

        [$dy, $dm, $dd] = $parsedDate;
        [$ay, $am, $ad] = $parsedAsOf;

        $dateJdn = self::toJdn($dy, $dm, $dd);
        $asofJdn = self::toJdn($ay, $am, $ad);
        $diff = $dateJdn - $asofJdn;

        if ($diff === 0) {
            return $this->today;
        }
        if ($diff === 1) {
            return $this->tomorrow;
        }
        if ($diff === -1) {
            return $this->yesterday;
        }

        $loc = $this->locale;
        $isCompact = $this->compactness === Compactness::Compact;

        if ($diff === 2 && $loc->dayAfterTomorrow !== null && !$isCompact) {
            return $loc->dayAfterTomorrow;
        }
        if ($diff === -2 && $loc->dayBeforeYesterday !== null && !$isCompact) {
            return $loc->dayBeforeYesterday;
        }

        if ($isCompact) {
            $includeYear = $dy !== $ay;
            return $this->formatAbsolute($dy, $dm, $dd, $includeYear);
        }

        if ($diff >= 2 && $diff <= 6 && $loc->thisWeekday !== null) {
            $dow = self::weekday($dy, $dm, $dd);
            return \str_replace('{weekday}', $this->weekdays[$dow], $loc->thisWeekday);
        }
        if ($diff >= -6 && $diff <= -2 && $loc->lastWeekday !== null) {
            $dow = self::weekday($dy, $dm, $dd);
            return \str_replace('{weekday}', $this->weekdays[$dow], $loc->lastWeekday);
        }
        if ($diff >= 7 && $diff <= 13 && $loc->nextWeekday !== null) {
            $dow = self::weekday($dy, $dm, $dd);
            return \str_replace('{weekday}', $this->weekdays[$dow], $loc->nextWeekday);
        }

        $includeYear = $dy !== $ay;
        return $this->formatAbsolute($dy, $dm, $dd, $includeYear);
    }

    private function formatAbsolute(int $year, int $month, int $day, bool $includeYear): string
    {
        $dayStr = (string) $day;
        $fmt = $this->dayFormatExceptions[$dayStr] ?? $this->dayFormat;
        $formattedDay = \str_replace('{n}', $dayStr, $fmt);

        $monthNames = $this->monthsInDate ?? $this->months;
        $monthName = $monthNames[$month - 1];

        $pattern = $includeYear ? $this->datePatternWithYear : $this->datePattern;
        $result = \str_replace('{month}', $monthName, $pattern);
        $result = \str_replace('{day}', $formattedDay, $result);
        $result = \str_replace('{d}', (string) $day, $result);
        $result = \str_replace('{m}', (string) $month, $result);
        if ($includeYear) {
            $result = \str_replace('{year}', (string) $year, $result);
            $result = \str_replace('{yy}', \str_pad((string) ($year % 100), 2, '0', \STR_PAD_LEFT), $result);
        }

        return $result;
    }

    /**
     * YYYY-MM-DD naming a real calendar day, optionally followed by T and a
     * time (which is not read).
     *
     * @return array{int, int, int}|null
     */
    private static function parseDate(string $s): ?array
    {
        if (\preg_match('/\A([0-9]{4})-([0-9]{2})-([0-9]{2})(?:T|\z)/', $s, $m) !== 1) {
            return null;
        }
        $year = (int) $m[1];
        $month = (int) $m[2];
        $day = (int) $m[3];
        if ($month < 1 || $month > 12 || $day < 1 || $day > self::daysInMonth($year, $month)) {
            return null;
        }
        return [$year, $month, $day];
    }

    private static function daysInMonth(int $year, int $month): int
    {
        if ($month === 2) {
            return ($year % 4 === 0 && ($year % 100 !== 0 || $year % 400 === 0)) ? 29 : 28;
        }
        return match ($month) {
            4, 6, 9, 11 => 30,
            default => 31,
        };
    }

    private static function toJdn(int $year, int $month, int $day): int
    {
        $a = \intdiv(14 - $month, 12);
        $y = $year + 4800 - $a;
        $m = $month + 12 * $a - 3;
        return $day + \intdiv(153 * $m + 2, 5) + 365 * $y + \intdiv($y, 4) - \intdiv($y, 100) + \intdiv($y, 400) - 32045;
    }

    private static function weekday(int $year, int $month, int $day): int
    {
        $jdn = self::toJdn($year, $month, $day);
        return ($jdn + 1) % 7;
    }
}
