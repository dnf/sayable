import type { AgeLocale } from '../locale.js';

export const mr: AgeLocale = {
  code: 'mr',
  plural: (n) => (n === 0 || n === 1 ? 'one' : 'other'),
  units: {
    day:   { one: '{n} दिवस', other: '{n} दिवस' },
    week:  { one: '{n} आठवडा', other: '{n} आठवडे' },
    month: { one: '{n} महिना', other: '{n} महिने' },
    year:  { one: '{n} वर्ष', other: '{n} वर्षे' },
  },
  half: 'साडे {n}',
  delimiter: ', ',
  justBorn: 'नवजात',
  stages: {
    newborn: 'नवजात',
    infant: 'अर्भक',
    toddler: 'बाळ',
    child: 'मूल',
    teenager: 'किशोर',
    adult: 'प्रौढ',
  },
};
