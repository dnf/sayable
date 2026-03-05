<?php

declare(strict_types=1);

namespace SayableDuration;

/** Locale-aware duration and relative time formatter. */
final class SayableDuration
{
    public const VERSION = '0.5.0';

    private readonly DurationLocale $locale;
    /** @var array<string, string>|string */
    private readonly string|array $second;
    /** @var array<string, string>|string */
    private readonly string|array $minute;
    /** @var array<string, string>|string */
    private readonly string|array $hour;
    /** @var array<string, string>|string */
    private readonly string|array $day;
    /** @var array<string, string>|string */
    private readonly string|array $week;
    /** @var array<string, string>|string */
    private readonly string|array $month;
    /** @var array<string, string>|string */
    private readonly string|array $year;
    private readonly string $half;
    private readonly string $delimiter;
    private readonly string $justNow;
    private readonly string $ago;
    private readonly string $inFuture;

    public function __construct(DurationLocale $locale, Compactness $compactness = Compactness::Normal)
    {
        $this->locale = $locale;

        $ovr = match ($compactness) {
            Compactness::Short => $locale->short,
            Compactness::Compact => $locale->compact,
            Compactness::Normal => null,
        };

        $this->second = $ovr?->second ?? $locale->units->second;
        $this->minute = $ovr?->minute ?? $locale->units->minute;
        $this->hour = $ovr?->hour ?? $locale->units->hour;
        $this->day = $ovr?->day ?? $locale->units->day;
        $this->week = $ovr?->week ?? $locale->units->week;
        $this->month = $ovr?->month ?? $locale->units->month;
        $this->year = $ovr?->year ?? $locale->units->year;
        $this->half = $ovr?->half ?? $locale->half;
        $this->delimiter = $ovr?->delimiter ?? $locale->delimiter;
        $this->justNow = $locale->justNow;
        $this->ago = $ovr?->ago ?? $locale->ago;
        $this->inFuture = $ovr?->inFuture ?? $locale->inFuture;
    }

    public function formatDuration(int $seconds): ?string
    {
        if ($seconds < 0) {
            return null;
        }
        return $this->formatDurationInternal($seconds);
    }

    public function formatDurationIso(string $start, string $end): ?string
    {
        if ($start === '' || $end === '') {
            return null;
        }
        $s = self::parseIsoToSeconds($start);
        $e = self::parseIsoToSeconds($end);
        if ($s === null || $e === null) {
            return null;
        }
        return $this->formatDurationInternal(\abs($e - $s));
    }

    public function formatSince(?string $start, ?string $asOf): ?string
    {
        if ($start === null || $start === '' || $asOf === null || $asOf === '') {
            return null;
        }
        $s = self::parseIsoToSeconds($start);
        $a = self::parseIsoToSeconds($asOf);
        if ($s === null || $a === null) {
            return null;
        }
        $diff = $a - $s;
        if ($diff < 0) {
            return null;
        }
        if ($diff === 0) {
            return $this->justNow;
        }
        return \str_replace('{0}', $this->formatDurationInternal($diff), $this->ago);
    }

    public function formatUntil(?string $target, ?string $asOf): ?string
    {
        if ($target === null || $target === '' || $asOf === null || $asOf === '') {
            return null;
        }
        $t = self::parseIsoToSeconds($target);
        $a = self::parseIsoToSeconds($asOf);
        if ($t === null || $a === null) {
            return null;
        }
        $diff = $t - $a;
        if ($diff < 0) {
            return null;
        }
        if ($diff === 0) {
            return $this->justNow;
        }
        return \str_replace('{0}', $this->formatDurationInternal($diff), $this->inFuture);
    }

    private function formatDurationInternal(int $total): string
    {
        if ($total === 0) {
            return $this->justNow;
        }

        // 1-59 seconds
        if ($total < 60) {
            return self::resolveUnit($total, $this->second, $this->locale);
        }

        $totalMinutes = \intdiv($total, 60);
        $remainderSeconds = $total % 60;

        // 1-4 minutes: minutes + seconds
        if ($totalMinutes < 5) {
            $result = self::resolveUnit($totalMinutes, $this->minute, $this->locale);
            if ($remainderSeconds > 0) {
                $result .= $this->delimiter . self::resolveUnit($remainderSeconds, $this->second, $this->locale);
            }
            return $result;
        }

        // 5-59 minutes
        if ($totalMinutes < 60) {
            return self::resolveUnit($totalMinutes, $this->minute, $this->locale);
        }

        $totalHours = \intdiv($total, 3600);
        $remainderMinutes = \intdiv($total % 3600, 60);

        // 1-5 hours: hours + minutes (with half marker)
        if ($totalHours <= 5) {
            if ($remainderMinutes === 30) {
                return self::resolveUnit($totalHours, $this->hour, $this->locale, $this->half);
            }
            $result = self::resolveUnit($totalHours, $this->hour, $this->locale);
            if ($remainderMinutes > 0) {
                $result .= $this->delimiter . self::resolveUnit($remainderMinutes, $this->minute, $this->locale);
            }
            return $result;
        }

        // 6-23 hours
        if ($totalHours < 24) {
            return self::resolveUnit($totalHours, $this->hour, $this->locale);
        }

        $totalDays = \intdiv($total, 86400);
        $remainderHours = \intdiv($total % 86400, 3600);

        // 1-2 days: days + hours (with half marker)
        if ($totalDays <= 2) {
            if ($remainderHours === 12) {
                return self::resolveUnit($totalDays, $this->day, $this->locale, $this->half);
            }
            $result = self::resolveUnit($totalDays, $this->day, $this->locale);
            if ($remainderHours > 0) {
                $result .= $this->delimiter . self::resolveUnit($remainderHours, $this->hour, $this->locale);
            }
            return $result;
        }

        // 3-6 days
        if ($totalDays < 7) {
            return self::resolveUnit($totalDays, $this->day, $this->locale);
        }

        $totalWeeks = \intdiv($totalDays, 7);
        $remainderDays = $totalDays % 7;

        // 1-4 weeks (up to 29 days; 30+ transitions to months)
        if ($totalDays < 30) {
            $result = self::resolveUnit($totalWeeks, $this->week, $this->locale);
            if ($remainderDays > 0) {
                $result .= $this->delimiter . self::resolveUnit($remainderDays, $this->day, $this->locale);
            }
            return $result;
        }

        // Approximate months (30.44 days average)
        $totalMonths = (int) \round($totalDays / 30.44);

        // 1-11 months
        if ($totalMonths < 12) {
            if ($totalMonths === 0) {
                $totalMonths = 1;
            }
            return self::resolveUnit($totalMonths, $this->month, $this->locale);
        }

        // 12+ months: years + months
        $totalYears = \intdiv($totalMonths, 12);
        $remainderMonths = $totalMonths % 12;
        $result = self::resolveUnit($totalYears, $this->year, $this->locale);
        if ($remainderMonths > 0) {
            $result .= $this->delimiter . self::resolveUnit($remainderMonths, $this->month, $this->locale);
        }
        return $result;
    }

    private static function parseIsoToSeconds(string $iso): ?int
    {
        if ($iso === '') {
            return null;
        }

        $tIdx = \strpos($iso, 'T');
        if ($tIdx === false) {
            return null;
        }

        $datePart = \substr($iso, 0, $tIdx);
        $timePart = \substr($iso, $tIdx + 1);

        $dp = \explode('-', $datePart);
        if (\count($dp) < 3) {
            return null;
        }

        $year = self::safeAtoi($dp[0]);
        $month = self::safeAtoi($dp[1]);
        $day = self::safeAtoi($dp[2]);
        if ($year === null || $month === null || $day === null) {
            return null;
        }

        $plusIdx = \strpos($timePart, '+');
        if ($plusIdx !== false) {
            $timePart = \substr($timePart, 0, $plusIdx);
        }
        $zIdx = \strpos($timePart, 'Z');
        if ($zIdx !== false) {
            $timePart = \substr($timePart, 0, $zIdx);
        }

        $tp = \explode(':', $timePart);
        $hour = self::safeAtoi($tp[0]);
        if ($hour === null) {
            return null;
        }
        $minute = \count($tp) > 1 ? self::safeAtoi($tp[1]) : 0;
        if ($minute === null) {
            return null;
        }
        if (\count($tp) > 2) {
            $secParts = \explode('.', $tp[2]);
            $second = self::safeAtoi($secParts[0]);
            if ($second === null) {
                return null;
            }
        } else {
            $second = 0;
        }

        $days = self::daysSinceEpoch($year, $month, $day);
        return $days * 86400 + $hour * 3600 + $minute * 60 + $second;
    }

    private static function safeAtoi(string $s): ?int
    {
        if ($s === '') {
            return null;
        }
        $n = 0;
        for ($i = 0, $len = \strlen($s); $i < $len; $i++) {
            $c = \ord($s[$i]);
            if ($c < 48 || $c > 57) {
                return null;
            }
            $n = $n * 10 + ($c - 48);
        }
        return $n;
    }

    private static function isLeapYear(int $year): bool
    {
        return ($year % 4 === 0 && $year % 100 !== 0) || ($year % 400 === 0);
    }

    private static function daysInMonth(int $year, int $month): int
    {
        return match ($month) {
            1, 3, 5, 7, 8, 10, 12 => 31,
            4, 6, 9, 11 => 30,
            2 => self::isLeapYear($year) ? 29 : 28,
            default => 30,
        };
    }

    private static function daysSinceEpoch(int $year, int $month, int $day): int
    {
        $days = 0;
        if ($year >= 2000) {
            for ($y = 2000; $y < $year; $y++) {
                $days += self::isLeapYear($y) ? 366 : 365;
            }
        } else {
            for ($y = $year; $y < 2000; $y++) {
                $days -= self::isLeapYear($y) ? 366 : 365;
            }
        }
        for ($m = 1; $m < $month; $m++) {
            $days += self::daysInMonth($year, $m);
        }
        $days += $day - 1;
        return $days;
    }

    /**
     * @param array<string, string>|string $unitForms
     */
    private static function resolveUnit(
        int $count,
        string|array $unitForms,
        DurationLocale $locale,
        string $half = '',
    ): string {
        $baseN = $locale->formatNumber !== null
            ? ($locale->formatNumber)($count)
            : (string) $count;

        $n = ($half !== '' && \str_contains($half, '{n}'))
            ? \str_replace('{n}', $baseN, $half)
            : $baseN;

        if (\is_string($unitForms)) {
            $template = $unitForms;
        } else {
            $cat = $half !== '' ? PluralCategory::Other : ($locale->plural)($count);
            $template = $unitForms[$cat->value] ?? $unitForms[PluralCategory::Other->value] ?? '';
        }

        $result = \str_replace('{n}', $n, $template);

        if ($locale->formatUnit !== null) {
            $result = ($locale->formatUnit)($count, $result);
        }

        if ($half !== '' && \str_contains($half, '{0}')) {
            $result = \str_replace('{0}', $result, $half);
        }

        return $result;
    }
}
