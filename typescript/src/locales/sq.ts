import type { AgeLocale } from '../locale.js';

export const sq: AgeLocale = {
  code: 'sq',
  plural: (n) => (n === 1 ? 'one' : 'other'),
  units: {
    day:   { one: '{n} ditë', other: '{n} ditë' },
    week:  { one: '{n} javë', other: '{n} javë' },
    month: { one: '{n} muaj', other: '{n} muaj' },
    year:  { one: '{n} vit', other: '{n} vjet' },
  },
  half: '{0} e gjysmë',
  delimiter: ', ',
  justBorn: 'Sapolindur',
  stages: {
    newborn: 'Sapolindur', infant: 'Foshnjë', toddler: 'Fëmijë i vogël',
    child: 'Fëmijë', teenager: 'Adoleshent', adult: 'I rritur',
  },
};
