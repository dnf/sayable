import type { AgeLocale } from '../locale.js';

export const ms: AgeLocale = {
  code: 'ms',
  plural: () => 'other',
  units: {
    day:   '{n} hari',
    week:  '{n} minggu',
    month: '{n} bulan',
    year:  '{n} tahun',
  },
  half: '{0} setengah',
  delimiter: ', ',
  justBorn: 'Baru lahir',
  stages: {
    newborn: 'Baru lahir',
    infant: 'Bayi',
    toddler: 'Kanak-kanak kecil',
    child: 'Kanak-kanak',
    teenager: 'Remaja',
    adult: 'Dewasa',
  },
};
