import type { AgeLocale } from '../locale.js';

export const vi: AgeLocale = {
  code: 'vi',
  plural: () => 'other',
  units: {
    day:   '{n} ngày',
    week:  '{n} tuần',
    month: '{n} tháng',
    year:  '{n} tuổi',
  },
  half: '{0} rưỡi',
  delimiter: ', ',
  justBorn: 'Sơ sinh',
  stages: {
    newborn: 'Sơ sinh',
    infant: 'Trẻ sơ sinh',
    toddler: 'Trẻ mới biết đi',
    child: 'Trẻ em',
    teenager: 'Thiếu niên',
    adult: 'Người lớn',
  },
};
