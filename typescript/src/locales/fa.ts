import type { AgeLocale } from '../locale.js';

export const fa: AgeLocale = {
  code: 'fa',
  plural: (n) => (n === 0 || n === 1 ? 'one' : 'other'),
  units: {
    day:   { one: '{n} روز', other: '{n} روز' },
    week:  { one: '{n} هفته', other: '{n} هفته' },
    month: { one: '{n} ماه', other: '{n} ماه' },
    year:  { one: '{n} سال', other: '{n} سال' },
  },
  half: '{0} و نیم',
  delimiter: ' و ',
  justBorn: 'نوزاد',
  stages: {
    newborn: 'نوزاد',
    infant: 'شیرخوار',
    toddler: 'نوپا',
    child: 'کودک',
    teenager: 'نوجوان',
    adult: 'بزرگسال',
  },
};
