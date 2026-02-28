import type { AgeLocale } from '../locale.js';

export const th: AgeLocale = {
  code: 'th',
  plural: () => 'other',
  units: {
    day:   '{n} วัน',
    week:  '{n} สัปดาห์',
    month: '{n} เดือน',
    year:  '{n} ปี',
  },
  half: '{0}ครึ่ง',
  delimiter: ' ',
  justBorn: 'แรกเกิด',
  stages: {
    newborn: 'แรกเกิด',
    infant: 'ทารก',
    toddler: 'เด็กวัยเตาะแตะ',
    child: 'เด็ก',
    teenager: 'วัยรุ่น',
    adult: 'ผู้ใหญ่',
  },
};
