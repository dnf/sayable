import type { AgeLocale } from '../locale.js';

export const de: AgeLocale = {
  code: 'de',
  plural: (n) => (n === 1 ? 'one' : 'other'),
  units: {
    day:   { one: '{n} Tag', other: '{n} Tage' },
    week:  { one: '{n} Woche', other: '{n} Wochen' },
    month: { one: '{n} Monat', other: '{n} Monate' },
    year:  { one: '{n} Jahr', other: '{n} Jahre' },
  },
  half: '{n}½',
  delimiter: ', ',
  justBorn: 'Neugeboren',
  stages: {
    newborn: 'Neugeborenes',
    infant: 'Säugling',
    toddler: 'Kleinkind',
    child: 'Kind',
    teenager: 'Teenager',
    adult: 'Erwachsener',
  },
};
