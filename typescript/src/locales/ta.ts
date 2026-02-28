import type { AgeLocale } from '../locale.js';

export const ta: AgeLocale = {
  code: 'ta',
  plural: (n) => (n === 1 ? 'one' : 'other'),
  units: {
    day:   { one: '{n} நாள்', other: '{n} நாட்கள்' },
    week:  { one: '{n} வாரம்', other: '{n} வாரங்கள்' },
    month: { one: '{n} மாதம்', other: '{n} மாதங்கள்' },
    year:  { one: '{n} வயது', other: '{n} வயது' },
  },
  half: '{0}ரை',
  delimiter: ', ',
  justBorn: 'பிறந்த குழந்தை',
  stages: {
    newborn: 'பிறந்த குழந்தை',
    infant: 'குழந்தை',
    toddler: 'சிறு குழந்தை',
    child: 'சிறுவர்',
    teenager: 'இளம்பருவம்',
    adult: 'பெரியவர்',
  },
};
