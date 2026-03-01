import type { AgeLocale } from '../locale.js';

export const hi: AgeLocale = {
  code: 'hi',
  plural: (n) => (n === 0 || n === 1 ? 'one' : 'other'),
  units: {
    day:   { one: '{n} दिन', other: '{n} दिन' },
    week:  { one: '{n} सप्ताह', other: '{n} सप्ताह' },
    month: { one: '{n} महीना', other: '{n} महीने' },
    year:  { one: '{n} साल', other: '{n} साल' },
  },
  half: 'साढ़े {n}',
  delimiter: ', ',
  justBorn: 'नवजात',
  stages: {
    newborn: 'नवजात',
    infant: 'शिशु',
    toddler: { m: 'छोटा बच्चा', f: 'छोटी बच्ची' },
    child: { m: 'बच्चा', f: 'बच्ची' },
    teenager: { m: 'किशोर', f: 'किशोरी' },
    adult: 'वयस्क',
  },
};
