import type { AgeLocale } from '../locale.js';

export const es: AgeLocale = {
  code: 'es',
  plural: (n) => (n === 1 ? 'one' : 'other'),
  units: {
    day:   { one: '{n} día', other: '{n} días' },
    week:  { one: '{n} semana', other: '{n} semanas' },
    month: { one: '{n} mes', other: '{n} meses' },
    year:  { one: '{n} año', other: '{n} años' },
  },
  half: '{n} y medio',
  delimiter: ', ',
  justBorn: 'Recién nacido',
  stages: {
    newborn: 'Recién nacido',
    infant: 'Bebé',
    toddler: 'Niño pequeño',
    child: 'Niño',
    teenager: 'Adolescente',
    adult: 'Adulto',
  },
};
