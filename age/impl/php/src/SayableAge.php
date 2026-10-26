<?php

declare(strict_types=1);

namespace SayableAge;

/** Locale-aware age formatter. */
final class SayableAge
{
    public const VERSION = '0.5.0';

    private const MAX_AGE_MONTHS = 6000;

    private readonly AgeLocale $locale;
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
    private readonly string $justBorn;

    /** @var (callable(): array{int, int, int})|null */
    private static $nowOverride = null;

    public function __construct(AgeLocale $locale, Compactness $compactness = Compactness::Normal)
    {
        $this->locale = $locale;

        $ovr = match ($compactness) {
            Compactness::Short => $locale->short,
            Compactness::Compact => $locale->compact,
            Compactness::Normal => null,
        };

        if ($ovr !== null) {
            $this->day = $ovr->day ?? $locale->units->day;
            $this->week = $ovr->week ?? $locale->units->week;
            $this->month = $ovr->month ?? $locale->units->month;
            $this->year = $ovr->year ?? $locale->units->year;
            $this->half = $ovr->half ?? $locale->half;
            $this->delimiter = $ovr->delimiter ?? $locale->delimiter;
            $this->justBorn = $ovr->justBorn ?? $locale->justBorn;
        } else {
            $this->day = $locale->units->day;
            $this->week = $locale->units->week;
            $this->month = $locale->units->month;
            $this->year = $locale->units->year;
            $this->half = $locale->half;
            $this->delimiter = $locale->delimiter;
            $this->justBorn = $locale->justBorn;
        }
    }

    /**
     * Override the "today" date for testing.
     *
     * @param (callable(): array{int, int, int})|null $fn Returns [year, month, day] or null to restore
     *
     * @internal
     */
    public static function setNowForTesting(?callable $fn): void
    {
        self::$nowOverride = $fn;
    }

    /**
     * Human-friendly age string.
     *
     * @param string|null $dateOfBirth YYYY-MM-DD date string
     * @param string|null $asOf YYYY-MM-DD reference date (defaults to today)
     */
    public function formatAge(?string $dateOfBirth, ?string $asOf = null): ?string
    {
        $age = self::parseAge($dateOfBirth, $asOf);
        if ($age === null) {
            return null;
        }

        [$months, $diffDays] = $age;

        // Tier 1: 0 days
        if ($diffDays === 0) {
            return $this->justBorn;
        }

        // Tier 1b: 1-6 days
        if ($diffDays < 7) {
            return self::resolveUnit($diffDays, $this->day, $this->locale);
        }

        // Tier 2: weeks + days until 3 calendar months
        if ($months < 3) {
            $weeks = \intdiv($diffDays, 7);
            $days = $diffDays % 7;
            $result = self::resolveUnit($weeks, $this->week, $this->locale);
            if ($days > 0) {
                $result .= $this->delimiter . self::resolveUnit($days, $this->day, $this->locale);
            }
            return $result;
        }

        // Tier 3: 3-23 months
        if ($months < 24) {
            return self::resolveUnit($months, $this->month, $this->locale);
        }

        // Tier 4: 24-35 months -> years + months
        if ($months < 36) {
            $years = \intdiv($months, 12);
            $rem = $months % 12;
            if ($rem === 0) {
                return self::resolveUnit($years, $this->year, $this->locale);
            }
            return self::resolveUnit($years, $this->year, $this->locale)
                . $this->delimiter
                . self::resolveUnit($rem, $this->month, $this->locale);
        }

        // Tier 5: 3-6 years -> years with half marker
        if ($months < 84) {
            $years = \intdiv($months, 12);
            $rem = $months % 12;
            return $rem >= 6
                ? self::resolveUnit($years, $this->year, $this->locale, $this->half)
                : self::resolveUnit($years, $this->year, $this->locale);
        }

        // Tier 6: 7+ years
        return self::resolveUnit(\intdiv($months, 12), $this->year, $this->locale);
    }

    /**
     * Developmental stage label based on age.
     *
     * @param string|null $dateOfBirth YYYY-MM-DD date string
     * @param string|null $asOf YYYY-MM-DD reference date (defaults to today)
     * @param string|null $gender 'f' for feminine, null for default/masculine
     */
    public function formatStage(?string $dateOfBirth, ?string $asOf = null, ?string $gender = null): ?string
    {
        $age = self::parseAge($dateOfBirth, $asOf);
        if ($age === null) {
            return null;
        }

        $months = $age[0];
        $label = match (true) {
            $months < 2 => $this->locale->stages->newborn,
            $months < 12 => $this->locale->stages->infant,
            $months < 36 => $this->locale->stages->toddler,
            $months < 156 => $this->locale->stages->child,
            $months < 216 => $this->locale->stages->teenager,
            default => $this->locale->stages->adult,
        };

        return $label->resolve($gender);
    }

    /**
     * Parse two YYYY-MM-DD strings into [calendar months, elapsed days].
     *
     * @return array{int, int}|null
     */
    private static function parseAge(?string $dateOfBirth, ?string $asOf): ?array
    {
        if ($dateOfBirth === null || $dateOfBirth === '') {
            return null;
        }

        $dobParts = self::parseDateParts($dateOfBirth);
        if ($dobParts === null) {
            return null;
        }

        [$dobY, $dobM, $dobD] = $dobParts;

        if ($asOf !== null && $asOf !== '') {
            $refParts = self::parseDateParts($asOf);
            if ($refParts === null) {
                return null;
            }
            [$refY, $refM, $refD] = $refParts;
        } else {
            if (self::$nowOverride !== null) {
                [$refY, $refM, $refD] = (self::$nowOverride)();
            } else {
                $refY = (int) \date('Y');
                $refM = (int) \date('n');
                $refD = (int) \date('j');
            }
        }

        $dobJdn = self::julianDay($dobY, $dobM, $dobD);
        $refJdn = self::julianDay($refY, $refM, $refD);
        $diffDays = $refJdn - $dobJdn;
        if ($diffDays < 0) {
            return null;
        }

        // Calendar months: clamp birthday to last day of reference month so that
        // e.g. a child born Jan 31 turns 1 month old on Feb 28 (or 29 in a leap year).
        $lastDay = self::daysInMonth($refY, $refM);
        $clampedBirthday = \min($dobD, $lastDay);
        $months = ($refY - $dobY) * 12 + ($refM - $dobM);
        if ($refD < $clampedBirthday) {
            $months--;
        }
        if ($months > self::MAX_AGE_MONTHS) {
            return null;
        }

        return [$months, $diffDays];
    }

    /**
     * Parse "YYYY-MM-DD" into [year, month, day].
     *
     * @return array{int, int, int}|null
     */
    private static function parseDateParts(string $s): ?array
    {
        if (\preg_match('/\A([0-9]{4})-([0-9]{2})-([0-9]{2})\z/', $s, $m) !== 1) {
            return null;
        }

        $y = (int) $m[1];
        $month = (int) $m[2];
        $d = (int) $m[3];

        if ($month < 1 || $month > 12 || $d < 1 || $d > self::daysInMonth($y, $month)) {
            return null;
        }

        return [$y, $month, $d];
    }

    private static function julianDay(int $y, int $m, int $d): int
    {
        $a = \intdiv(14 - $m, 12);
        $yy = $y + 4800 - $a;
        $mm = $m + 12 * $a - 3;
        return $d + \intdiv(153 * $mm + 2, 5) + 365 * $yy + \intdiv($yy, 4) - \intdiv($yy, 100) + \intdiv($yy, 400) - 32045;
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

    /**
     * Resolve a unit count to its display string using locale rules.
     *
     * The $half template supports two placeholder styles:
     * - {n} modifies the formatted number before unit substitution (e.g. "3½" instead of "3")
     * - {0} wraps the fully resolved expression after unit substitution (e.g. "3 years and a half")
     *
     * @param array<string, string>|string $unitForms
     */
    private static function resolveUnit(
        int $count,
        string|array $unitForms,
        AgeLocale $locale,
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
            $cat = ($locale->plural)($count);
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
