import type { AgeLocale } from '../locale.js';

export const ur: AgeLocale = {
  code: 'ur',
  plural: (n) => (n === 0 || n === 1 ? 'one' : 'other'),
  units: {
    day:   { one: '{n} دن', other: '{n} دن' },
    week:  { one: '{n} ہفتہ', other: '{n} ہفتے' },
    month: { one: '{n} مہینہ', other: '{n} مہینے' },
    year:  { one: '{n} سال', other: '{n} سال' },
  },
  half: 'ساڑھے {n}',
  delimiter: '، ',
  justBorn: 'نومولود',
  stages: {
    newborn: 'نومولود',
    infant: 'شیرخوار',
    toddler: 'چھوٹا بچہ',
    child: 'بچہ',
    teenager: 'نوجوان',
    adult: 'بالغ',
  },
};
