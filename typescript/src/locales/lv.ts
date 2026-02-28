import type { AgeLocale, PluralCategory } from '../locale.js';

function plural(n: number): PluralCategory {
  if (n === 0) return 'zero';
  if (n % 10 === 1 && n % 100 !== 11) return 'one';
  return 'other';
}

export const lv: AgeLocale = {
  code: 'lv',
  plural,
  units: {
    day:   { zero: '{n} dienu', one: '{n} diena', other: '{n} dienas' },
    week:  { zero: '{n} nedēļu', one: '{n} nedēļa', other: '{n} nedēļas' },
    month: { zero: '{n} mēnešu', one: '{n} mēnesis', other: '{n} mēneši' },
    year:  { zero: '{n} gadu', one: '{n} gads', other: '{n} gadi' },
  },
  half: '{n}½',
  delimiter: ', ',
  justBorn: 'Jaundzimušais',
  stages: {
    newborn: 'Jaundzimušais', infant: 'Zīdainis', toddler: 'Mazulis',
    child: 'Bērns', teenager: 'Pusaudzis', adult: 'Pieaugušais',
  },
};
