import { describe, expect, it } from 'vitest';
import {
  SayableDuration,
  formatDuration,
  formatSince,
  formatUntil,
} from '../src/index.js';
import { de } from '../src/locales/de.js';
import { en } from '../src/locales/en.js';
import { fr } from '../src/locales/fr.js';
import { ja } from '../src/locales/ja.js';
import { men } from '../src/locales/men.js';

// ── Section 1: Null / edge cases ──────────────────────────────────────

describe('Null / edge cases', () => {
  // 1.1
  it('format_duration null', () => expect(formatDuration(null)).toBeNull());
  // 1.2
  it('format_duration negative', () => expect(formatDuration(-1)).toBeNull());
  // 1.3
  it('format_since null start', () => expect(formatSince(null, '2025-01-15T10:00:00')).toBeNull());
  // 1.4
  it('format_until null target', () => expect(formatUntil(null, '2025-01-15T10:00:00')).toBeNull());
  // 1.5
  it('format_since future start', () =>
    expect(formatSince('2025-01-15T10:00:00', '2025-01-15T09:00:00')).toBeNull());
  // 1.6
  it('format_until past target', () =>
    expect(formatUntil('2025-01-15T09:00:00', '2025-01-15T10:00:00')).toBeNull());
});

// ── Section 2: Duration — seconds tier (0-59s) ────────────────────────

describe('Duration — seconds', () => {
  // 2.1
  it('zero', () => expect(formatDuration(0)).toBe('just now'));
  // 2.2
  it('1 second', () => expect(formatDuration(1)).toBe('1 second'));
  // 2.3
  it('45 seconds', () => expect(formatDuration(45)).toBe('45 seconds'));
  // 2.4
  it('59 seconds', () => expect(formatDuration(59)).toBe('59 seconds'));
});

// ── Section 3: Duration — minutes + seconds (1-4 min) ─────────────────

describe('Duration — minutes + seconds', () => {
  // 3.1
  it('1 minute', () => expect(formatDuration(60)).toBe('1 minute'));
  // 3.2
  it('1 minute, 30 seconds', () => expect(formatDuration(90)).toBe('1 minute, 30 seconds'));
  // 3.3
  it('4 minutes', () => expect(formatDuration(240)).toBe('4 minutes'));
  // 3.4
  it('4 minutes, 30 seconds', () => expect(formatDuration(270)).toBe('4 minutes, 30 seconds'));
});

// ── Section 4: Duration — minutes tier (5-59 min) ─────────────────────

describe('Duration — minutes', () => {
  // 4.1
  it('5 minutes', () => expect(formatDuration(300)).toBe('5 minutes'));
  // 4.2
  it('25 minutes', () => expect(formatDuration(1500)).toBe('25 minutes'));
  // 4.3
  it('59 minutes', () => expect(formatDuration(3540)).toBe('59 minutes'));
});

// ── Section 5: Duration — hours + minutes tier (1-5 hr) ───────────────

describe('Duration — hours + minutes', () => {
  // 5.1
  it('1 hour', () => expect(formatDuration(3600)).toBe('1 hour'));
  // 5.2
  it('1½ hours (half marker)', () => expect(formatDuration(5400)).toBe('1½ hours'));
  // 5.3
  it('2 hours, 15 minutes', () => expect(formatDuration(8100)).toBe('2 hours, 15 minutes'));
  // 5.4
  it('5 hours', () => expect(formatDuration(18000)).toBe('5 hours'));
});

// ── Section 6: Duration — hours tier (6-23 hr) ────────────────────────

describe('Duration — hours', () => {
  // 6.1
  it('8 hours', () => expect(formatDuration(28800)).toBe('8 hours'));
  // 6.2
  it('23 hours', () => expect(formatDuration(82800)).toBe('23 hours'));
});

// ── Section 7: Duration — days tier ──────────────────────────────────

describe('Duration — days', () => {
  // 7.1
  it('1 day', () => expect(formatDuration(86400)).toBe('1 day'));
  // 7.2
  it('1 day, 3 hours', () => expect(formatDuration(97200)).toBe('1 day, 3 hours'));
  // 7.3
  it('1½ days (half marker)', () => expect(formatDuration(129600)).toBe('1½ days'));
  // 7.4
  it('5 days', () => expect(formatDuration(432000)).toBe('5 days'));
  // 7.5
  it('2 days', () => expect(formatDuration(172800)).toBe('2 days'));
});

// ── Section 8: Duration — weeks tier ─────────────────────────────────

describe('Duration — weeks', () => {
  // 8.1
  it('1 week', () => expect(formatDuration(604800)).toBe('1 week'));
  // 8.2
  it('2 weeks, 1 day', () => expect(formatDuration(1296000)).toBe('2 weeks, 1 day'));
  // 8.3
  it('4 weeks', () => expect(formatDuration(2419200)).toBe('4 weeks'));
});

// ── Section 9: Duration — months and years ───────────────────────────

describe('Duration — months and years', () => {
  // 9.1
  it('1 month (~31 days)', () => expect(formatDuration(2678400)).toBe('1 month'));
  // 9.2
  it('3 months (~91 days)', () => expect(formatDuration(7884000)).toBe('3 months'));
  // 9.3
  it('1 year (365 days)', () => expect(formatDuration(31536000)).toBe('1 year'));
  // 9.4
  it('1 year, 3 months (~456 days)', () => expect(formatDuration(39420000)).toBe('1 year, 3 months'));
});

// ── Section 10: Duration from ISO timestamps ──────────────────────────

describe('Duration — ISO timestamps', () => {
  // 10.1
  it('1½ hours from ISO', () =>
    expect(formatDuration('2025-01-15T10:00:00', '2025-01-15T11:30:00')).toBe('1½ hours'));
  // 10.2
  it('45 minutes from ISO', () =>
    expect(formatDuration('2025-01-15T10:00:00', '2025-01-15T10:45:00')).toBe('45 minutes'));
});

// ── Section 11: Relative time — since ─────────────────────────────────

describe('Relative time — since', () => {
  // 11.1
  it('just now', () =>
    expect(formatSince('2025-01-15T10:00:00', '2025-01-15T10:00:00')).toBe('just now'));
  // 11.2
  it('30 seconds ago', () =>
    expect(formatSince('2025-01-15T10:00:00', '2025-01-15T10:00:30')).toBe('30 seconds ago'));
  // 11.3
  it('45 minutes ago', () =>
    expect(formatSince('2025-01-15T10:00:00', '2025-01-15T10:45:00')).toBe('45 minutes ago'));
  // 11.4
  it('3 hours ago', () =>
    expect(formatSince('2025-01-15T10:00:00', '2025-01-15T13:00:00')).toBe('3 hours ago'));
});

// ── Section 12: Relative time — until ─────────────────────────────────

describe('Relative time — until', () => {
  // 12.1
  it('just now', () =>
    expect(formatUntil('2025-01-15T10:00:00', '2025-01-15T10:00:00')).toBe('just now'));
  // 12.2
  it('in 20 minutes', () =>
    expect(formatUntil('2025-01-15T10:20:00', '2025-01-15T10:00:00')).toBe('in 20 minutes'));
  // 12.3
  it('in 3 hours', () =>
    expect(formatUntil('2025-01-15T13:00:00', '2025-01-15T10:00:00')).toBe('in 3 hours'));
});

// ── Section 13: Locale — German ───────────────────────────────────────

describe('Locale — German', () => {
  const sd = new SayableDuration(de);

  // 13.1
  it('duration 1 hour', () => expect(sd.formatDuration(3600)).toBe('1 Stunde'));
  // 13.2
  it('since', () =>
    expect(sd.formatSince('2025-01-15T10:00:00', '2025-01-15T10:05:00')).toBe('vor 5 Minuten'));
});

// ── Section 14: Locale — French ───────────────────────────────────────

describe('Locale — French', () => {
  const sd = new SayableDuration(fr);

  // 14.1
  it('duration 2 hours', () => expect(sd.formatDuration(7200)).toBe('2 heures'));
});

// ── Section 15: Locale — Japanese ─────────────────────────────────────

describe('Locale — Japanese', () => {
  const sd = new SayableDuration(ja);

  // 15.1
  it('duration 2 minutes', () => expect(sd.formatDuration(120)).toBe('2分'));
  // 15.2
  it('since 1 hour', () =>
    expect(sd.formatSince('2025-01-15T10:00:00', '2025-01-15T11:00:00')).toBe('1時間前'));
});

// ── Section 16: Short compactness — duration ──────────────────────────

describe('Short compactness — duration', () => {
  const sd = new SayableDuration(en, 'short');

  // 16.1
  it('1 hour', () => expect(sd.formatDuration(3600)).toBe('1h'));
  // 16.2
  it('1m, 30s', () => expect(sd.formatDuration(90)).toBe('1m, 30s'));
});

// ── Section 17: Compact compactness — duration ────────────────────────

describe('Compact compactness — duration', () => {
  const sd = new SayableDuration(en, 'compact');

  // 17.1
  it('1 hour', () => expect(sd.formatDuration(3600)).toBe('1h'));
  // 17.2
  it('1m30s', () => expect(sd.formatDuration(90)).toBe('1m30s'));
});

// ── Section 18: Short compactness — relative time ─────────────────────

describe('Short compactness — relative time', () => {
  // 18.1
  it('days and hours both kept', () =>
    expect(new SayableDuration(men, 'short').formatSince('2025-01-20T01:32:11', '2025-01-22T15:39:16'))
      .toBe('lɔhɔnga 2, awa 14 taa gbɔyɔ'));
});

// ── Section 19: Range (500-year ceiling) ──────────────────────────────

describe('Range (500-year ceiling)', () => {
  // 19.1
  it('500 Julian years is the ceiling', () => expect(formatDuration(15778800000)).toBe('500 years'));
  // 19.2
  it('over 6000 months', () => expect(formatDuration(15800000000)).toBeNull());
  // 19.3
  it('well beyond the ceiling', () => expect(formatDuration(99999999999)).toBeNull());
  // 19.4
  it('525 years ago', () => expect(formatSince('1500-01-01T00:00:00', '2025-01-01T00:00:00')).toBeNull());
  // 19.5
  it('575 years from now', () => expect(formatUntil('2600-01-01T00:00:00', '2025-01-01T00:00:00')).toBeNull());
});

// ── Section 20: Timestamp validation ──────────────────────────────────

describe('Timestamp validation', () => {
  // 20.1
  it('seconds are optional', () =>
    expect(formatDuration('2025-01-15T10:00', '2025-01-15T11:30:00')).toBe('1½ hours'));
  // 20.2
  it('minutes are required', () => expect(formatDuration('2025-01-15T10', '2025-01-15T11:30:00')).toBeNull());
  // 20.3
  it('unpadded date', () => expect(formatDuration('2025-1-5T10:00:00', '2025-01-15T11:30:00')).toBeNull());
  // 20.4
  it('impossible date', () => expect(formatDuration('2025-02-30T10:00:00', '2025-03-15T11:30:00')).toBeNull());
  // 20.5
  it('hour out of range', () => expect(formatSince('2025-01-15T10:00:00', '2025-01-15T25:00:00')).toBeNull());
});
