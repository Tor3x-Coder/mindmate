#!/usr/bin/env node

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';

export const PROJECT_ID = 'mindmate-app-fcf2d';
export const SEED_VERSION = 'v1';
export const SEED_DAYS = 21;

export const COLLECTIONS = Object.freeze({
  moodLogs: 'mood_logs',
  journalEntries: 'journal_entries',
  wellnessAssessments: 'wellness_assessments',
  meditationHistory: 'meditation_history',
  breathingSessions: 'breathing_sessions',
  thoughtRecords: 'thought_records',
  feedbackRecords: 'feedback_records',
});

const MOOD_IMPACTS = new Set([
  'A little',
  'Somewhat',
  'A lot',
  'Overwhelming',
  'Not sure yet',
]);

const MOOD_LOGS = [
  {
    daysAgo: 20,
    hour: 8,
    emoji: '😴',
    label: 'Tired',
    impactLabel: 'Somewhat',
    note: 'Slept later than planned and started the day slowly.',
  },
  {
    daysAgo: 19,
    hour: 18,
    emoji: '😐',
    label: 'Okay',
    impactLabel: 'A little',
    note: 'A regular day. A short walk helped me reset after work.',
  },
  {
    daysAgo: 17,
    hour: 20,
    emoji: '😣',
    label: 'Stressed',
    impactLabel: 'A lot',
    note: 'Several small tasks became urgent at the same time.',
  },
  {
    daysAgo: 16,
    hour: 9,
    emoji: '😔',
    label: 'Sad',
    impactLabel: 'Somewhat',
    note: 'Missed someone today and felt quieter than usual.',
  },
  {
    daysAgo: 14,
    hour: 19,
    emoji: '😊',
    label: 'Happy',
    impactLabel: 'A little',
    note: 'Had a good conversation with a friend.',
  },
  {
    daysAgo: 13,
    hour: 21,
    emoji: '😐',
    label: 'Okay',
    impactLabel: 'Not sure yet',
    note: 'Still figuring out how the week felt.',
  },
  {
    daysAgo: 11,
    hour: 17,
    emoji: '😡',
    label: 'Angry',
    impactLabel: 'A lot',
    note: 'A tense conversation stayed on my mind.',
  },
  {
    daysAgo: 10,
    hour: 20,
    emoji: '😣',
    label: 'Stressed',
    impactLabel: 'Overwhelming',
    note: 'School and home responsibilities felt like too much together.',
  },
  {
    daysAgo: 8,
    hour: 8,
    emoji: '😴',
    label: 'Tired',
    impactLabel: 'Somewhat',
    note: 'Woke up several times and had less energy than usual.',
  },
  {
    daysAgo: 7,
    hour: 18,
    emoji: '😊',
    label: 'Happy',
    impactLabel: 'A little',
    note: 'Finished one task I had been avoiding.',
  },
  {
    daysAgo: 5,
    hour: 20,
    emoji: '😔',
    label: 'Sad',
    impactLabel: 'Somewhat',
    note: 'Felt lonely in the evening, so I called my cousin.',
  },
  {
    daysAgo: 3,
    hour: 19,
    emoji: '😐',
    label: 'Okay',
    impactLabel: 'A little',
    note: 'The day was mixed, but there were a few calm moments.',
  },
  {
    daysAgo: 1,
    hour: 21,
    emoji: '😣',
    label: 'Stressed',
    impactLabel: 'Somewhat',
    note: 'Thinking about tomorrow made it hard to switch off.',
  },
  {
    daysAgo: 0,
    hour: 10,
    emoji: '😊',
    label: 'Happy',
    impactLabel: 'A little',
    note: 'Started with a quiet breakfast and a manageable plan.',
  },
];

const JOURNAL_ENTRIES = [
  {
    daysAgo: 19,
    hour: 21,
    prompt: 'What would make tomorrow a little kinder?',
    content:
        'I can prepare one thing tonight and leave the rest for tomorrow. I do not need to solve the whole week at once.',
  },
  {
    daysAgo: 16,
    hour: 21,
    prompt: 'What has been taking up space in your mind?',
    content:
        'I keep replaying a conversation. I am not sure what the other person meant, but I know I felt dismissed. I may ask about it when I feel calmer.',
  },
  {
    daysAgo: 13,
    hour: 20,
    prompt: 'Notice one thing that supported you today.',
    content:
        'A friend checked in without asking me to explain everything. That helped me feel less alone.',
  },
  {
    daysAgo: 10,
    hour: 22,
    prompt: 'Name the next small step.',
    content:
        'I will write down the two tasks that matter most and leave the rest for the morning.',
  },
  {
    daysAgo: 7,
    hour: 20,
    prompt: 'What are you learning about your patterns?',
    content:
        'When I avoid a task, I get quick relief but feel more pressure later. Starting for five minutes feels more possible than finishing it.',
  },
  {
    daysAgo: 5,
    hour: 21,
    prompt: 'What do you need from a safe person?',
    content:
        'I do not need advice yet. I would like someone to listen and check in tomorrow.',
  },
  {
    daysAgo: 1,
    hour: 21,
    prompt: 'What went slightly better than expected?',
    content:
        'I took a break before replying to a difficult message. The pause helped me choose calmer words.',
  },
];

const WELLNESS_ASSESSMENTS = [
  {
    daysAgo: 19,
    hour: 19,
    sleepHours: 6.5,
    exercised: false,
    drankEnoughWater: true,
    stressLevel: 7,
    socialized: false,
    ateHealthyMeals: true,
  },
  {
    daysAgo: 12,
    hour: 19,
    sleepHours: 7.25,
    exercised: true,
    drankEnoughWater: true,
    stressLevel: 5,
    socialized: true,
    ateHealthyMeals: true,
  },
  {
    daysAgo: 3,
    hour: 19,
    sleepHours: 6.75,
    exercised: true,
    drankEnoughWater: false,
    stressLevel: 6,
    socialized: true,
    ateHealthyMeals: false,
  },
];

const MEDITATION_SESSIONS = [
  { daysAgo: 18, hour: 20, sessionType: 'Stress Relief — Quick Reset', durationMinutes: 1 },
  { daysAgo: 15, hour: 21, sessionType: 'Sleep — Wind Down', durationMinutes: 3 },
  { daysAgo: 12, hour: 18, sessionType: 'Focus — Clear Mind', durationMinutes: 5 },
  { daysAgo: 9, hour: 20, sessionType: 'Anxiety — Grounding', durationMinutes: 3 },
  { daysAgo: 7, hour: 21, sessionType: 'Gratitude — Small Joys', durationMinutes: 3 },
  { daysAgo: 5, hour: 18, sessionType: 'Morning — Fresh Start', durationMinutes: 5 },
  { daysAgo: 2, hour: 20, sessionType: 'Stress Relief — Release Tension', durationMinutes: 3 },
  { daysAgo: 0, hour: 8, sessionType: 'Focus — Pre-Study Focus', durationMinutes: 5 },
];

const BREATHING_SESSIONS = [
  { daysAgo: 17, hour: 19, pattern: 'Box Breathing', durationMinutes: 3, completed: true },
  { daysAgo: 14, hour: 8, pattern: 'Simple Calm', durationMinutes: 5, completed: true },
  { daysAgo: 11, hour: 20, pattern: '4-7-8 Breathing', durationMinutes: 3, completed: true },
  { daysAgo: 8, hour: 18, pattern: 'Box Breathing', durationMinutes: 5, completed: true },
  { daysAgo: 4, hour: 21, pattern: 'Simple Calm', durationMinutes: 3, completed: true },
  { daysAgo: 1, hour: 19, pattern: '4-7-8 Breathing', durationMinutes: 5, completed: true },
];

const THOUGHT_RECORDS = [
  {
    daysAgo: 16,
    hour: 21,
    situation: 'A message was left unread for most of the day.',
    automaticThought: 'They must be upset with me.',
    intensityBefore: 7,
    evidenceFor: 'The reply was slower than usual.',
    evidenceAgainst: 'They may be busy, tired, or away from their phone. I do not know yet.',
    balancedThought: 'I noticed uncertainty and filled in the gap with the worst explanation. I can wait or ask calmly later.',
    intensityAfter: 4,
  },
  {
    daysAgo: 10,
    hour: 21,
    situation: 'I looked at the amount of work left before a deadline.',
    automaticThought: 'I will never finish this.',
    intensityBefore: 8,
    evidenceFor: 'There is a lot left and I started late.',
    evidenceAgainst: 'Some tasks are small, and I can ask what matters most.',
    balancedThought: 'The whole list feels overwhelming. I can choose one task and make a realistic plan from there.',
    intensityAfter: 5,
  },
  {
    daysAgo: 5,
    hour: 20,
    situation: 'A friend cancelled plans at short notice.',
    automaticThought: 'People do not really want to spend time with me.',
    intensityBefore: 6,
    evidenceFor: 'The plan changed again.',
    evidenceAgainst: 'They have shown care before and offered another day.',
    balancedThought: 'I felt disappointed. One cancelled plan does not answer the bigger question about our friendship.',
    intensityAfter: 3,
  },
  {
    daysAgo: 1,
    hour: 20,
    situation: 'I made a mistake in a piece of work.',
    automaticThought: 'I am not good at this.',
    intensityBefore: 6,
    evidenceFor: 'I missed an important detail.',
    evidenceAgainst: 'I have learned this before and can correct the detail now.',
    balancedThought: 'I made a mistake in one part. I can repair it and learn what to check next time.',
    intensityAfter: 3,
  },
];

const FEEDBACK_RECORDS = [
  { daysAgo: 17, hour: 19, moodLabel: 'Stressed', moodEmoji: '😣', moodImpact: 'A lot', activityId: 'breathing', activityTitle: 'A short breathing reset', feedback: 'A little better' },
  { daysAgo: 15, hour: 21, moodLabel: 'Tired', moodEmoji: '😴', moodImpact: 'Somewhat', activityId: 'meditation', activityTitle: 'A gentle wind-down', feedback: 'Much better' },
  { daysAgo: 11, hour: 20, moodLabel: 'Angry', moodEmoji: '😡', moodImpact: 'A lot', activityId: 'reframe', activityTitle: 'Reframe one thought', feedback: 'About the same' },
  { daysAgo: 8, hour: 18, moodLabel: 'Tired', moodEmoji: '😴', moodImpact: 'Somewhat', activityId: 'breathing', activityTitle: 'A short breathing reset', feedback: 'A little better' },
  { daysAgo: 7, hour: 20, moodLabel: 'Happy', moodEmoji: '😊', moodImpact: 'A little', activityId: 'positive_journal', activityTitle: 'Keep the moment', feedback: 'Much better' },
  { daysAgo: 5, hour: 21, moodLabel: 'Sad', moodEmoji: '😔', moodImpact: 'Somewhat', activityId: 'journal', activityTitle: 'Write it out', feedback: 'A little better' },
  { daysAgo: 3, hour: 20, moodLabel: 'Okay', moodEmoji: '😐', moodImpact: 'A little', activityId: 'chat', activityTitle: 'Talk it through', feedback: 'Not sure yet' },
  { daysAgo: 0, hour: 10, moodLabel: 'Happy', moodEmoji: '😊', moodImpact: 'A little', activityId: 'breathing', activityTitle: 'A short breathing reset', feedback: 'About the same' },
];

function dateAt(asOf, daysAgo, hour, minute = 0) {
  const date = new Date(
    Date.UTC(
      asOf.getUTCFullYear(),
      asOf.getUTCMonth(),
      asOf.getUTCDate(),
      hour,
      minute,
      0,
      0,
    ),
  );
  date.setUTCDate(date.getUTCDate() - daysAgo);
  return date;
}

function parseAsOf(value) {
  if (!value) return startOfUtcDay(new Date());
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    throw new Error('--as-of must use YYYY-MM-DD.');
  }
  const date = new Date(`${value}T00:00:00.000Z`);
  if (Number.isNaN(date.getTime())) throw new Error('--as-of is not a valid date.');
  const today = startOfUtcDay(new Date());
  if (date > today) throw new Error('--as-of cannot be in the future.');
  return date;
}

function startOfUtcDay(date) {
  return new Date(
    Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()),
  );
}

function parseArgs(argv) {
  const options = {
    uid: '',
    email: '',
    projectId: PROJECT_ID,
    serviceAccount: '',
    asOf: '',
    apply: false,
    confirmDemo: false,
    help: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === '--help' || argument === '-h') {
      options.help = true;
      continue;
    }
    if (argument === '--apply') {
      options.apply = true;
      continue;
    }
    if (argument === '--confirm-demo') {
      options.confirmDemo = true;
      continue;
    }

    const valueFlags = {
      '--uid': 'uid',
      '--email': 'email',
      '--project-id': 'projectId',
      '--service-account': 'serviceAccount',
      '--as-of': 'asOf',
    };
    const key = valueFlags[argument];
    if (key) {
      const value = argv[index + 1];
      if (!value || value.startsWith('--')) {
        throw new Error(`${argument} needs a value.`);
      }
      options[key] = value.trim();
      index += 1;
      continue;
    }

    throw new Error(`Unknown argument: ${argument}`);
  }

  if (!options.help && options.uid && options.email) {
    throw new Error('Use either --uid or --email, not both.');
  }
  if (!options.help && !options.uid && !options.email) {
    throw new Error('Provide the registered demo account with --uid or --email.');
  }
  if (options.apply && !options.confirmDemo) {
    throw new Error('Writing requires both --apply and --confirm-demo.');
  }

  return options;
}

function seededId(collection, index) {
  return `demo_seed_${SEED_VERSION}_${collection}_${String(index + 1).padStart(2, '0')}`;
}

function buildSeedPlan(uid, asOf = startOfUtcDay(new Date())) {
  if (!uid || typeof uid !== 'string') throw new Error('A target UID is required.');

  const documents = [];
  const counters = new Map();
  const add = (collection, daysAgo, hour, fields) => {
    const index = counters.get(collection) ?? 0;
    counters.set(collection, index + 1);
    const date = dateAt(asOf, daysAgo, hour, fields.minute ?? 0).toISOString();
    const {
      daysAgo: _daysAgo,
      hour: _hour,
      minute: _minute,
      ...storedFields
    } = fields;
    documents.push({
      collection,
      id: seededId(collection, index),
      data: {
        uid,
        ...storedFields,
        date,
      },
    });
  };

  MOOD_LOGS.forEach((item) => add(COLLECTIONS.moodLogs, item.daysAgo, item.hour, item));
  JOURNAL_ENTRIES.forEach((item) => add(COLLECTIONS.journalEntries, item.daysAgo, item.hour, item));
  WELLNESS_ASSESSMENTS.forEach((item) => add(COLLECTIONS.wellnessAssessments, item.daysAgo, item.hour, item));
  MEDITATION_SESSIONS.forEach((item) => add(COLLECTIONS.meditationHistory, item.daysAgo, item.hour, item));
  BREATHING_SESSIONS.forEach((item) => add(COLLECTIONS.breathingSessions, item.daysAgo, item.hour, item));
  THOUGHT_RECORDS.forEach((item) => add(COLLECTIONS.thoughtRecords, item.daysAgo, item.hour, item));
  FEEDBACK_RECORDS.forEach((item) => add(COLLECTIONS.feedbackRecords, item.daysAgo, item.hour, item));

  return {
    uid,
    asOf: asOf.toISOString().slice(0, 10),
    seedVersion: SEED_VERSION,
    documents,
  };
}

function summarizePlan(plan) {
  return plan.documents.reduce((summary, document) => {
    summary[document.collection] = (summary[document.collection] ?? 0) + 1;
    return summary;
  }, {});
}

function printUsage() {
  console.log(`MindMate demo history seeder\n\nUsage:\n  node seed_demo_data.mjs --email demo@example.com\n  node seed_demo_data.mjs --uid FIREBASE_UID --apply --confirm-demo\n\nOptions:\n  --email EMAIL             Find the registered account by email.\n  --uid UID                 Target a known Firebase Auth UID.\n  --as-of YYYY-MM-DD        End the 21-day history on this date.\n  --project-id PROJECT_ID   Defaults to ${PROJECT_ID}.\n  --service-account PATH    Optional service-account JSON path.\n  --apply                   Write the deterministic demo documents.\n  --confirm-demo            Required together with --apply.\n\nWithout --apply the script only validates arguments and prints the plan; it\nnever contacts Firebase or writes data.`);
}

async function createAdminApp(options) {
  const firebaseAdminModule = await import('firebase-admin');
  const admin = firebaseAdminModule.default ?? firebaseAdminModule;
  const credentialPath = options.serviceAccount || process.env.GOOGLE_APPLICATION_CREDENTIALS;
  const adminOptions = {};

  if (credentialPath) {
    const serviceAccount = JSON.parse(
      readFileSync(resolve(credentialPath), 'utf8'),
    );
    adminOptions.credential = admin.credential.cert(serviceAccount);
    adminOptions.projectId = options.projectId || serviceAccount.project_id;
  } else {
    adminOptions.credential = admin.credential.applicationDefault();
    adminOptions.projectId = options.projectId;
  }

  const app = admin.apps.length > 0
    ? admin.apps[0]
    : admin.initializeApp(adminOptions);
  return { admin, app };
}

async function findTargetUser(admin, options) {
  const user = options.email
    ? await admin.auth().getUserByEmail(options.email)
    : await admin.auth().getUser(options.uid);

  if (options.uid && user.uid !== options.uid) {
    throw new Error('Firebase Auth returned a different UID than requested.');
  }
  return user;
}

async function writeSeedPlan(admin, app, plan) {
  const db = admin.firestore(app);
  const batch = db.batch();
  for (const document of plan.documents) {
    const reference = db.collection(document.collection).doc(document.id);
    batch.set(reference, document.data);
  }
  await batch.commit();
}

export {
  MOOD_IMPACTS,
  buildSeedPlan,
  dateAt,
  parseArgs,
  parseAsOf,
  seededId,
  summarizePlan,
};

export async function main(argv = process.argv.slice(2)) {
  let options;
  try {
    options = parseArgs(argv);
  } catch (error) {
    console.error(`Error: ${error.message}`);
    printUsage();
    return 1;
  }

  if (options.help) {
    printUsage();
    return 0;
  }

  const asOf = parseAsOf(options.asOf);
  const previewUid = options.uid || '<resolved-from-email>';
  const previewPlan = buildSeedPlan(previewUid, asOf);
  const counts = summarizePlan(previewPlan);

  console.log(`MindMate demo seed ${SEED_VERSION}`);
  console.log(`Target: ${options.email || options.uid}`);
  console.log(`History window: ${SEED_DAYS} days ending ${previewPlan.asOf}`);
  console.log('Documents:', counts);

  if (!options.apply) {
    console.log('Dry run only. No Firebase credentials were loaded and nothing was written.');
    return 0;
  }

  const { admin, app } = await createAdminApp(options);
  const user = await findTargetUser(admin, options);
  const plan = buildSeedPlan(user.uid, asOf);
  console.log(`Resolved Firebase Auth user: ${user.email || '(no email)'} (${user.uid})`);
  console.log('Writing only deterministic demo_seed_v1 documents; existing documents are not deleted.');
  await writeSeedPlan(admin, app, plan);
  console.log(`Seed complete: ${plan.documents.length} documents written.`);
  return 0;
}

const isDirectRun = process.argv[1]
  && fileURLToPath(import.meta.url) === resolve(process.argv[1]);

if (isDirectRun) {
  main().then((exitCode) => {
    process.exitCode = exitCode;
  }).catch((error) => {
    console.error(`Seed failed: ${error.message}`);
    process.exitCode = 1;
  });
}
