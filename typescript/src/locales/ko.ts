import type { AgeLocale } from '../locale.js';

export const ko: AgeLocale = {
  code: 'ko',
  plural: () => 'other',
  units: {
    day:   '{n}일',
    week:  '{n}주',
    month: '{n}개월',
    year:  '{n}살',
  },
  half: '{0} 반',
  delimiter: ' ',
  justBorn: '신생아',
  stages: {
    newborn: '신생아',
    infant: '영아',
    toddler: '유아',
    child: '아동',
    teenager: '청소년',
    adult: '성인',
  },
};
