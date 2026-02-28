import type { AgeLocale } from '../locale.js';

export const pa: AgeLocale = {
  code: 'pa',
  plural: (n) => (n === 0 || n === 1 ? 'one' : 'other'),
  units: {
    day:   { one: '{n} ਦਿਨ', other: '{n} ਦਿਨ' },
    week:  { one: '{n} ਹਫ਼ਤਾ', other: '{n} ਹਫ਼ਤੇ' },
    month: { one: '{n} ਮਹੀਨਾ', other: '{n} ਮਹੀਨੇ' },
    year:  { one: '{n} ਸਾਲ', other: '{n} ਸਾਲ' },
  },
  half: 'ਸਾਢੇ {n}',
  delimiter: ', ',
  justBorn: 'ਨਵਜੰਮਿਆ',
  stages: {
    newborn: 'ਨਵਜੰਮਿਆ',
    infant: 'ਸ਼ਿਸ਼ੂ',
    toddler: 'ਛੋਟਾ ਬੱਚਾ',
    child: 'ਬੱਚਾ',
    teenager: 'ਕਿਸ਼ੋਰ',
    adult: 'ਬਾਲਗ',
  },
};
