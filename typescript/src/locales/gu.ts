import type { AgeLocale } from '../locale.js';

export const gu: AgeLocale = {
  code: 'gu',
  plural: (n) => (n === 0 || n === 1 ? 'one' : 'other'),
  units: {
    day:   { one: '{n} દિવસ', other: '{n} દિવસ' },
    week:  { one: '{n} અઠવાડિયું', other: '{n} અઠવાડિયા' },
    month: { one: '{n} મહિનો', other: '{n} મહિના' },
    year:  { one: '{n} વર્ષ', other: '{n} વર્ષ' },
  },
  half: 'સાડા {n}',
  delimiter: ', ',
  justBorn: 'નવજાત',
  stages: {
    newborn: 'નવજાત',
    infant: 'શિશુ',
    toddler: 'નાનું બાળક',
    child: 'બાળક',
    teenager: { m: 'કિશોર', f: 'કિશોરી' },
    adult: 'પુખ્ત',
  },
};
