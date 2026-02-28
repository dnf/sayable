import type { AgeLocale, PluralCategory } from '../locale.js';

function plural(n: number): PluralCategory {
  if (n === 0) return 'zero';
  if (n === 1) return 'one';
  if (n === 2) return 'two';
  const mod100 = n % 100;
  if (mod100 >= 3 && mod100 <= 10) return 'few';
  if (mod100 >= 11 && mod100 <= 99) return 'many';
  return 'other';
}

export const ar: AgeLocale = {
  code: 'ar',
  plural,
  units: {
    day:   { zero: '{n} يوم', one: 'يوم', two: 'يومان', few: '{n} أيام', many: '{n} يومًا', other: '{n} يوم' },
    week:  { zero: '{n} أسبوع', one: 'أسبوع', two: 'أسبوعان', few: '{n} أسابيع', many: '{n} أسبوعًا', other: '{n} أسبوع' },
    month: { zero: '{n} شهر', one: 'شهر', two: 'شهران', few: '{n} أشهر', many: '{n} شهرًا', other: '{n} شهر' },
    year:  { zero: '{n} سنة', one: 'سنة', two: 'سنتان', few: '{n} سنوات', many: '{n} سنة', other: '{n} سنة' },
  },
  half: '{0} ونصف',
  delimiter: ' و',
  justBorn: 'حديث الولادة',
  stages: {
    newborn: 'حديث الولادة',
    infant: 'رضيع',
    toddler: 'طفل صغير',
    child: 'طفل',
    teenager: 'مراهق',
    adult: 'بالغ',
  },
};
