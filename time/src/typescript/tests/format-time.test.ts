import { describe, expect, it } from 'vitest';
import { SayableTime, formatTime } from '../src/index.js';
import { de } from '../src/locales/de.js';
import { en } from '../src/locales/en.js';
import { fr } from '../src/locales/fr.js';
import { ja } from '../src/locales/ja.js';

// ── Section 1: Null / edge cases ──────────────────────────────────────

describe('Null / edge cases', () => {
  // 1.1
  it('format_time null', () => expect(formatTime(null)).toBeNull());
  // 1.2
  it('format_time empty', () => expect(formatTime('')).toBeNull());
  // 1.3
  it('format_time invalid', () => expect(formatTime('invalid')).toBeNull());
  // 1.4
  it('format_time out of range', () => expect(formatTime('25:00')).toBeNull());
});

// ── Section 2: Clock time (normal compactness) ────────────────────────

describe('Clock time (normal)', () => {
  const st = new SayableTime(en);

  // 2.1
  it('midnight', () => expect(st.formatTime('00:00')).toBe('midnight'));
  // 2.2
  it('noon', () => expect(st.formatTime('12:00')).toBe('noon'));
  // 2.3
  it("o'clock", () => expect(st.formatTime('15:00')).toBe("three o'clock"));
  // 2.4
  it('quarter past', () => expect(st.formatTime('14:15')).toBe('a quarter past two'));
  // 2.5
  it('half past', () => expect(st.formatTime('09:30')).toBe('half past nine'));
  // 2.6
  it('quarter to', () => expect(st.formatTime('10:45')).toBe('a quarter to eleven'));
  // 2.7
  it('five past', () => expect(st.formatTime('08:05')).toBe('five past eight'));
  // 2.8
  it('five to', () => expect(st.formatTime('16:55')).toBe('five to five'));
  // 2.9
  it('rounds to midnight', () => expect(st.formatTime('23:58')).toBe('midnight'));
  // 2.10
  it('rounds to twenty', () => expect(st.formatTime('07:22')).toBe('twenty past seven'));
  // 2.11
  it('ISO datetime input', () =>
    expect(st.formatTime('2025-01-15T14:15:00')).toBe('a quarter past two'));
});

// ── Section 3: Clock time (short compactness) ─────────────────────────

describe('Clock time (short)', () => {
  const st = new SayableTime(en, 'short');

  // 3.1
  it('PM', () => expect(st.formatTime('14:15')).toBe('2:15 PM'));
  // 3.2
  it('AM', () => expect(st.formatTime('09:30')).toBe('9:30 AM'));
  // 3.3
  it('midnight', () => expect(st.formatTime('00:00')).toBe('12:00 AM'));
  // 3.4
  it('noon', () => expect(st.formatTime('12:00')).toBe('12:00 PM'));
});

// ── Section 4: Clock time (compact) ───────────────────────────────────

describe('Clock time (compact)', () => {
  const st = new SayableTime(en, 'compact');

  // 4.1
  it('PM', () => expect(st.formatTime('14:15')).toBe('2:15p'));
  // 4.2
  it('AM', () => expect(st.formatTime('09:30')).toBe('9:30a'));
});

// ── Section 5: Locale — German ───────────────────────────────────────

describe('Locale — German', () => {
  const st = new SayableTime(de);

  // 5.1
  it('half to pattern', () => expect(st.formatTime('15:30')).toBe('halb vier'));
});

// ── Section 6: Locale — French ───────────────────────────────────────

describe('Locale — French', () => {
  const st = new SayableTime(fr);

  // 6.1
  it('quarter past', () => expect(st.formatTime('15:15')).toBe('trois heures et quart'));
});

// ── Section 7: Locale — Japanese ─────────────────────────────────────

describe('Locale — Japanese', () => {
  const st = new SayableTime(ja);

  // 7.1
  it('half past', () => expect(st.formatTime('15:30')).toBe('三時半'));
});
