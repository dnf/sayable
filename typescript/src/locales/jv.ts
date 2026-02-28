import type { AgeLocale } from '../locale.js';

export const jv: AgeLocale = {
  code: 'jv',
  plural: () => 'other',
  units: {
    day:   '{n} dina',
    week:  '{n} minggu',
    month: '{n} wulan',
    year:  '{n} taun',
  },
  half: '{0} setengah',
  delimiter: ', ',
  justBorn: 'Bayi anyar',
  stages: {
    newborn: 'Bayi anyar',
    infant: 'Bayi',
    toddler: 'Balita',
    child: 'Bocah',
    teenager: 'Remaja',
    adult: 'Diwasa',
  },
};
