import type { AgeLocale } from '../locale.js';

export const pt: AgeLocale = {
  code: 'pt',
  plural: (n) => (n === 0 || n === 1 ? 'one' : 'other'),
  units: {
    day:   { one: '{n} dia', other: '{n} dias' },
    week:  { one: '{n} semana', other: '{n} semanas' },
    month: { one: '{n} mês', other: '{n} meses' },
    year:  { one: '{n} ano', other: '{n} anos' },
  },
  half: '{0} e meio',
  delimiter: ', ',
  justBorn: 'Recém-nascido',
  stages: {
    newborn: 'Recém-nascido',
    infant: 'Bebê',
    toddler: 'Criança pequena',
    child: 'Criança',
    teenager: 'Adolescente',
    adult: 'Adulto',
  },
};
