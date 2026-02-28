import type { AgeLocale } from '../locale.js';

export const ja: AgeLocale = {
  code: 'ja',
  plural: () => 'other',
  units: {
    day:   '{n}日',
    week:  '{n}週',
    month: '{n}ヶ月',
    year:  '{n}歳',
  },
  half: '{0}半',
  delimiter: '',
  justBorn: '新生児',
  stages: {
    newborn: '新生児',
    infant: '乳児',
    toddler: '幼児',
    child: '児童',
    teenager: '青少年',
    adult: '成人',
  },
};
