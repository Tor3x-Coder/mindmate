import assert from 'node:assert/strict';
import test from 'node:test';

import {
  COLLECTIONS,
  MOOD_IMPACTS,
  SEED_DAYS,
  SEED_VERSION,
  buildSeedPlan,
  parseArgs,
  parseAsOf,
  seededId,
  summarizePlan,
} from './seed_demo_data.mjs';

const AS_OF = new Date('2026-09-02T00:00:00.000Z');

function documentsFor(plan, collection) {
  return plan.documents.filter((document) => document.collection === collection);
}

function assertKeys(object, expectedKeys) {
  assert.deepEqual(Object.keys(object).sort(), [...expectedKeys].sort());
}

test('builds a repeatable three-week plan without touching users', () => {
  const first = buildSeedPlan('demo-uid', AS_OF);
  const second = buildSeedPlan('demo-uid', AS_OF);

  assert.deepEqual(first, second);
  assert.equal(first.seedVersion, SEED_VERSION);
  assert.equal(first.asOf, '2026-09-02');
  assert.equal(first.documents.length, 50);
  assert.equal(first.documents.some((document) => document.collection === 'users'), false);
  assert.ok(first.documents.every((document) => document.id.startsWith('demo_seed_v1_')));
  assert.ok(first.documents.every((document) => document.data.uid === 'demo-uid'));

  const counts = summarizePlan(first);
  assert.deepEqual(counts, {
    [COLLECTIONS.moodLogs]: 14,
    [COLLECTIONS.journalEntries]: 7,
    [COLLECTIONS.wellnessAssessments]: 3,
    [COLLECTIONS.meditationHistory]: 8,
    [COLLECTIONS.breathingSessions]: 6,
    [COLLECTIONS.thoughtRecords]: 4,
    [COLLECTIONS.feedbackRecords]: 8,
  });
});

test('uses the production field shapes for seeded documents', () => {
  const plan = buildSeedPlan('demo-uid', AS_OF);
  const mood = documentsFor(plan, COLLECTIONS.moodLogs)[0].data;
  const journal = documentsFor(plan, COLLECTIONS.journalEntries)[0].data;
  const wellness = documentsFor(plan, COLLECTIONS.wellnessAssessments)[0].data;
  const meditation = documentsFor(plan, COLLECTIONS.meditationHistory)[0].data;
  const breathing = documentsFor(plan, COLLECTIONS.breathingSessions)[0].data;
  const thought = documentsFor(plan, COLLECTIONS.thoughtRecords)[0].data;
  const feedback = documentsFor(plan, COLLECTIONS.feedbackRecords)[0].data;

  assertKeys(mood, ['uid', 'emoji', 'label', 'impactLabel', 'note', 'date']);
  assertKeys(journal, ['uid', 'prompt', 'content', 'date']);
  assertKeys(wellness, [
    'uid',
    'sleepHours',
    'exercised',
    'drankEnoughWater',
    'stressLevel',
    'socialized',
    'ateHealthyMeals',
    'date',
  ]);
  assertKeys(meditation, ['uid', 'sessionType', 'durationMinutes', 'date']);
  assertKeys(breathing, ['uid', 'pattern', 'durationMinutes', 'completed', 'date']);
  assertKeys(thought, [
    'uid',
    'situation',
    'automaticThought',
    'intensityBefore',
    'evidenceFor',
    'evidenceAgainst',
    'balancedThought',
    'intensityAfter',
    'date',
  ]);
  assertKeys(feedback, [
    'uid',
    'moodLabel',
    'moodEmoji',
    'moodImpact',
    'activityId',
    'activityTitle',
    'feedback',
    'date',
  ]);

  for (const document of plan.documents) {
    const date = new Date(document.data.date);
    assert.equal(Number.isNaN(date.getTime()), false);
    assert.ok(date <= new Date('2026-09-02T23:59:59.999Z'));
    assert.ok(date >= new Date('2026-08-13T00:00:00.000Z'));
  }

  const impacts = documentsFor(plan, COLLECTIONS.moodLogs).map(
    (document) => document.data.impactLabel,
  );
  assert.ok(impacts.every((impact) => MOOD_IMPACTS.has(impact)));
  assert.ok(impacts.includes('Overwhelming'));
});

test('argument parsing keeps writes opt-in and validates the target', () => {
  const dryRun = parseArgs(['--email', 'demo@example.com']);
  assert.equal(dryRun.apply, false);
  assert.equal(dryRun.confirmDemo, false);

  const apply = parseArgs([
    '--uid',
    'demo-uid',
    '--as-of',
    '2026-09-02',
    '--apply',
    '--confirm-demo',
  ]);
  assert.equal(apply.apply, true);
  assert.equal(apply.confirmDemo, true);
  assert.equal(parseAsOf('2026-09-02').toISOString(), AS_OF.toISOString());
  assert.throws(() => parseArgs(['--apply']), /--uid or --email/);
  assert.throws(
    () => parseArgs(['--uid', 'demo-uid', '--apply']),
    /--confirm-demo/,
  );
  assert.throws(() => parseAsOf('2026-09-03'), /future/);
});

test('seed IDs are deterministic and separate by collection index', () => {
  assert.equal(
    seededId(COLLECTIONS.moodLogs, 0),
    'demo_seed_v1_mood_logs_01',
  );
  assert.notEqual(
    seededId(COLLECTIONS.moodLogs, 0),
    seededId(COLLECTIONS.journalEntries, 0),
  );
  assert.equal(SEED_DAYS, 21);
});
