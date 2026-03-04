import type { TimeLocale } from '../locale.js';

export const en: TimeLocale = {
  code: 'en',
  clock: {
    hours: ['twelve', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven'],
    midnight: 'midnight',
    noon: 'noon',
    patterns: {
      0:  "{h} o'clock",
      5:  'five past {h}',
      10: 'ten past {h}',
      15: 'a quarter past {h}',
      20: 'twenty past {h}',
      25: 'twenty-five past {h}',
      30: 'half past {h}',
      35: 'twenty-five to {next_h}',
      40: 'twenty to {next_h}',
      45: 'a quarter to {next_h}',
      50: 'ten to {next_h}',
      55: 'five to {next_h}',
    },
  },
  short: {
    clock: { use24h: false, amPm: ['AM', 'PM'], format: '{h}:{mm} {ampm}' },
  },
  compact: {
    clock: { use24h: false, amPm: ['a', 'p'], format: '{h}:{mm}{ampm}' },
  },
};
