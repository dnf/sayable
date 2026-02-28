import type { AgeLocale, PluralCategory } from '../locale.js';

function plural(n: number): PluralCategory {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 1 && mod100 !== 11) return 'one';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
  return 'many';
}

export const sr: AgeLocale = {
  code: 'sr',
  plural,
  units: {
    day:   { one: '{n} дан', few: '{n} дана', many: '{n} дана', other: '{n} дана' },
    week:  { one: '{n} недеља', few: '{n} недеље', many: '{n} недеља', other: '{n} недеља' },
    month: { one: '{n} месец', few: '{n} месеца', many: '{n} месеци', other: '{n} месеци' },
    year:  { one: '{n} година', few: '{n} године', many: '{n} година', other: '{n} година' },
  },
  half: '{0} и по',
  delimiter: ', ',
  justBorn: 'Новорођенче',
  stages: {
    newborn: 'Новорођенче', infant: 'Одојче', toddler: 'Мало дете',
    child: 'Дете', teenager: 'Тинејџер', adult: 'Одрасла особа',
  },
};
