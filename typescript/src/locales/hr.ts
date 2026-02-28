import type { AgeLocale, PluralCategory } from '../locale.js';

function plural(n: number): PluralCategory {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 1 && mod100 !== 11) return 'one';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
  return 'many';
}

export const hr: AgeLocale = {
  code: 'hr',
  plural,
  units: {
    day:   { one: '{n} dan', few: '{n} dana', many: '{n} dana', other: '{n} dana' },
    week:  { one: '{n} tjedan', few: '{n} tjedna', many: '{n} tjedana', other: '{n} tjedana' },
    month: { one: '{n} mjesec', few: '{n} mjeseca', many: '{n} mjeseci', other: '{n} mjeseci' },
    year:  { one: '{n} godina', few: '{n} godine', many: '{n} godina', other: '{n} godina' },
  },
  half: '{0} i pol',
  delimiter: ', ',
  justBorn: 'Novorođenče',
  stages: {
    newborn: 'Novorođenče', infant: 'Dojenče', toddler: 'Malo dijete',
    child: 'Dijete', teenager: 'Tinejdžer', adult: 'Odrasla osoba',
  },
};
