import type { AgeLocale, PluralCategory } from '../locale.js';

function plural(n: number): PluralCategory {
  if (n === 1) return 'one';
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
  return 'many';
}

export const pl: AgeLocale = {
  code: 'pl',
  plural,
  units: {
    day:   { one: '{n} dzień', few: '{n} dni', many: '{n} dni', other: '{n} dni' },
    week:  { one: '{n} tydzień', few: '{n} tygodnie', many: '{n} tygodni', other: '{n} tygodni' },
    month: { one: '{n} miesiąc', few: '{n} miesiące', many: '{n} miesięcy', other: '{n} miesięcy' },
    year:  { one: '{n} rok', few: '{n} lata', many: '{n} lat', other: '{n} lat' },
  },
  half: '{n} i pół',
  delimiter: ', ',
  justBorn: 'Noworodek',
  stages: {
    newborn: 'Noworodek', infant: 'Niemowlę', toddler: 'Maluch',
    child: 'Dziecko', teenager: 'Nastolatek', adult: 'Dorosły',
  },
};
