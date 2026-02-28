import type { AgeLocale } from '../locale.js';

export const it: AgeLocale = {
  code: 'it',
  plural: (n) => (n === 1 ? 'one' : 'other'),
  units: {
    day:   { one: '{n} giorno', other: '{n} giorni' },
    week:  { one: '{n} settimana', other: '{n} settimane' },
    month: { one: '{n} mese', other: '{n} mesi' },
    year:  { one: '{n} anno', other: '{n} anni' },
  },
  half: '{0} e mezzo',
  delimiter: ', ',
  justBorn: 'Neonato',
  stages: {
    newborn: 'Neonato',
    infant: 'Lattante',
    toddler: 'Bimbo',
    child: 'Bambino',
    teenager: 'Adolescente',
    adult: 'Adulto',
  },
};
