/** Parsed date components and derived calendar months / elapsed days. */
interface AgeComponents {
  months: number;
  diffDays: number;
}

/**
 * Parse two YYYY-MM-DD strings into calendar months and elapsed days.
 * Returns null if dateOfBirth is falsy or in the future relative to asOf.
 */
function parseAge(dateOfBirth: string | null | undefined, asOf?: string): AgeComponents | null {
  if (!dateOfBirth) return null;

  // Parse YYYY-MM-DD as integers to avoid timezone/DST issues
  const [dobY, dobM, dobD] = dateOfBirth.split('-').map(Number);
  let refY: number, refM: number, refD: number;
  if (asOf) {
    [refY, refM, refD] = asOf.split('-').map(Number);
  } else {
    const now = new Date();
    refY = now.getFullYear();
    refM = now.getMonth() + 1;
    refD = now.getDate();
  }

  // Total elapsed days (UTC avoids DST shifts)
  const diffDays = Math.round(
    (Date.UTC(refY, refM - 1, refD) - Date.UTC(dobY, dobM - 1, dobD)) / 86_400_000,
  );
  if (diffDays < 0) return null;

  // Calendar months with clamping for short months
  const lastDay = new Date(refY, refM, 0).getDate();
  const clampedBirthday = Math.min(dobD, lastDay);
  let months = (refY - dobY) * 12 + (refM - dobM);
  if (refD < clampedBirthday) months--;

  return { months, diffDays };
}

/**
 * Human-friendly age string for young children (≤3 years).
 * - 0 days    → "Newborn"
 * - 1–6 days  → "3 days"
 * - 7 days–<3 months → "2 weeks, 4 days"
 * - 3–23 months → "14 months"
 * - 24–35 months → "2 years, 3 months"
 * - 3–6 years → "3 years", "3½ years", "4 years", …
 * - 7+ years → "7 years"
 *
 * Calendar-month boundaries use day-of-month clamping: a child born on the
 * 31st turns N months on the last day of a 30-day (or shorter) month.
 *
 * @param dateOfBirth - YYYY-MM-DD date string
 * @param asOf - YYYY-MM-DD reference date (defaults to today)
 */
export function formatAge(dateOfBirth: string | null | undefined, asOf?: string): string | null {
  const age = parseAge(dateOfBirth, asOf);
  if (!age) return null;
  const { months, diffDays } = age;

  // Tier 1: 0–6 days
  if (diffDays === 0) return 'Newborn';
  if (diffDays < 7) {
    return diffDays === 1 ? '1 day' : `${String(diffDays)} days`;
  }

  // Tier 2: weeks + days until 3 calendar months
  if (months < 3) {
    const weeks = Math.floor(diffDays / 7);
    const days = diffDays % 7;
    let result = weeks === 1 ? '1 week' : `${String(weeks)} weeks`;
    if (days > 0) {
      result += days === 1 ? ', 1 day' : `, ${String(days)} days`;
    }
    return result;
  }

  // Tier 3: 3–23 months
  if (months < 24) {
    return `${String(months)} months`;
  }

  // Tier 4: 24–35 months → years + months
  if (months < 36) {
    const years = Math.floor(months / 12);
    const rem = months % 12;
    if (rem === 0) return `${String(years)} years`;
    return rem === 1
      ? `${String(years)} years, 1 month`
      : `${String(years)} years, ${String(rem)} months`;
  }

  // Tier 5: 3–6 years → years with ½ marker
  if (months < 84) {
    const years = Math.floor(months / 12);
    const rem = months % 12;
    return rem >= 6 ? `${String(years)}\u00BD years` : `${String(years)} years`;
  }

  // Tier 6: 7+ years
  return `${String(Math.floor(months / 12))} years`;
}

/**
 * Developmental stage label based on age.
 *
 * | Stage        | Age range          |
 * |--------------|--------------------|
 * | Newborn      | 0–1 months         |
 * | Infant       | 2–11 months        |
 * | Toddler      | 1–2 years          |
 * | Child        | 3–12 years         |
 * | Teenager     | 13–17 years        |
 * | Adult        | 18+ years          |
 *
 * Boundaries follow AAP/CDC consensus.
 *
 * @param dateOfBirth - YYYY-MM-DD date string
 * @param asOf - YYYY-MM-DD reference date (defaults to today)
 */
export function formatStage(dateOfBirth: string | null | undefined, asOf?: string): string | null {
  const age = parseAge(dateOfBirth, asOf);
  if (!age) return null;
  const { months } = age;

  if (months < 2) return 'Newborn';
  if (months < 12) return 'Infant';
  if (months < 36) return 'Toddler';
  if (months < 156) return 'Child';
  if (months < 216) return 'Teenager';
  return 'Adult';
}
