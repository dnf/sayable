import type { TimeLocale } from '../locale.js';
import { de } from './de.js';
import { en } from './en.js';
import { fr } from './fr.js';
import { ja } from './ja.js';

const _ALL: Record<string, TimeLocale> = { de, en, fr, ja };

export function getLocale(code: string): TimeLocale | undefined {
  return _ALL[code];
}

export { de, en, fr, ja };
