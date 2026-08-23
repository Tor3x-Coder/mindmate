const fs = require('node:fs');
const path = require('node:path');

const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
} = require('firebase/firestore');
const { after, before, beforeEach, describe, it } = require('mocha');

const PROJECT_ID = 'mindmate-rules-test';
let testEnv;

const validAppointment = (overrides = {}) => ({
  uid: 'user-a',
  professionalId: 'professional-1',
  professionalName: 'Dr Ada Example',
  consultationType: 'Online',
  preferredDate: '2026-08-24',
  preferredTime: '10:30',
  note: 'I would prefer a morning session.',
  status: 'pending',
  requestedAt: '2026-08-22T12:00:00.000Z',
  ...overrides,
});

const validTrustedContact = (overrides = {}) => ({
  uid: 'user-a',
  name: 'Amara Example',
  relationship: 'Sister',
  phone: '+2348000000000',
  createdAt: '2026-08-22T12:00:00.000Z',
  ...overrides,
});

const validSupportEvent = (overrides = {}) => ({
  uid: 'user-a',
  actionLabel: 'Called trusted contact',
  detail: 'Emergency Support screen',
  followUp: null,
  createdAt: '2026-08-22T12:00:00.000Z',
  ...overrides,
});

function dbFor(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

async function seedUser(uid, isAdmin = false) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users', uid), {
      fullName: uid,
      email: `${uid}@example.com`,
      goals: [],
      isAdmin,
      createdAt: '2026-08-22T12:00:00.000Z',
    });
  });
}

before(async () => {
  const rules = fs.readFileSync(
    path.resolve(__dirname, '..', 'firestore.rules'),
    'utf8',
  );

  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      host: '127.0.0.1',
      port: 8080,
      rules,
    },
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

after(async () => {
  await testEnv.cleanup();
});

describe('user profiles', () => {
  it('allows a user to create their own non-admin profile', async () => {
    const db = dbFor('user-a');
    const profileRef = doc(db, 'users', 'user-a');
    await assertSucceeds(
      setDoc(profileRef, {
        fullName: 'User A',
        email: 'user-a@example.com',
        goals: [],
        createdAt: '2026-08-22T12:00:00.000Z',
      }),
    );
    // Registration profiles currently omit isAdmin. Normal onboarding updates
    // must still work while the missing field safely defaults to non-admin.
    await assertSucceeds(
      updateDoc(profileRef, {
        goals: ['Better Sleep'],
        reminderTime: 'Evening',
      }),
    );
  });

  it('denies self-admin creation and later self-promotion', async () => {
    const db = dbFor('user-a');

    await assertFails(
      setDoc(doc(db, 'users', 'user-a'), {
        fullName: 'User A',
        email: 'user-a@example.com',
        goals: [],
        isAdmin: true,
        createdAt: '2026-08-22T12:00:00.000Z',
      }),
    );

    await seedUser('user-a');
    await assertFails(
      updateDoc(doc(db, 'users', 'user-a'), { isAdmin: true }),
    );
  });

  it('allows ordinary profile changes but protects email', async () => {
    await seedUser('user-a');
    const db = dbFor('user-a');

    await assertSucceeds(
      updateDoc(doc(db, 'users', 'user-a'), { goals: ['Better Sleep'] }),
    );
    await assertFails(
      updateDoc(doc(db, 'users', 'user-a'), {
        email: 'changed@example.com',
      }),
    );
  });

  it('denies reading another user profile', async () => {
    await seedUser('user-b');
    await assertFails(getDoc(doc(dbFor('user-a'), 'users', 'user-b')));
  });
});

describe('appointments', () => {
  it('allows an owner to create a correctly shaped pending request', async () => {
    await assertSucceeds(
      setDoc(
        doc(dbFor('user-a'), 'appointments', 'appointment-1'),
        validAppointment(),
      ),
    );
  });

  it('denies approved-on-create, foreign uid, and extra fields', async () => {
    const db = dbFor('user-a');

    await assertFails(
      setDoc(
        doc(db, 'appointments', 'approved-on-create'),
        validAppointment({ status: 'approved' }),
      ),
    );
    await assertFails(
      setDoc(
        doc(db, 'appointments', 'foreign-owner'),
        validAppointment({ uid: 'user-b' }),
      ),
    );
    await assertFails(
      setDoc(
        doc(db, 'appointments', 'extra-field'),
        validAppointment({ adminNote: 'not allowed' }),
      ),
    );
    await assertFails(
      setDoc(
        doc(db, 'appointments', 'oversized-note'),
        validAppointment({ note: 'x'.repeat(1001) }),
      ),
    );
  });

  it('allows owner reads/query/delete but denies cross-user reads', async () => {
    const ownerDb = dbFor('user-a');
    const appointmentRef = doc(ownerDb, 'appointments', 'appointment-1');
    await assertSucceeds(setDoc(appointmentRef, validAppointment()));

    await assertSucceeds(getDoc(appointmentRef));
    await assertSucceeds(
      getDocs(
        query(
          collection(ownerDb, 'appointments'),
          where('uid', '==', 'user-a'),
        ),
      ),
    );
    await assertFails(
      getDoc(doc(dbFor('user-b'), 'appointments', 'appointment-1')),
    );
    await assertSucceeds(deleteDoc(appointmentRef));
  });

  it('denies every owner update, including self-approval', async () => {
    const db = dbFor('user-a');
    const appointmentRef = doc(db, 'appointments', 'appointment-1');
    await assertSucceeds(setDoc(appointmentRef, validAppointment()));

    await assertFails(updateDoc(appointmentRef, { status: 'approved' }));
    await assertFails(updateDoc(appointmentRef, { note: 'Changed note' }));
  });

  it('allows an admin to read all requests and change status only', async () => {
    await seedUser('admin-user', true);
    await assertSucceeds(
      setDoc(
        doc(dbFor('user-a'), 'appointments', 'appointment-1'),
        validAppointment(),
      ),
    );

    const adminDb = dbFor('admin-user');
    const appointmentRef = doc(adminDb, 'appointments', 'appointment-1');

    await assertSucceeds(getDocs(collection(adminDb, 'appointments')));
    await assertSucceeds(updateDoc(appointmentRef, { status: 'approved' }));
    await assertFails(
      updateDoc(appointmentRef, { professionalName: 'Changed by admin' }),
    );
    await assertFails(updateDoc(appointmentRef, { status: 'cancelled' }));
  });
});

describe('trusted contacts', () => {
  it('allows valid owner CRUD while preserving uid and createdAt', async () => {
    const db = dbFor('user-a');
    const contactRef = doc(db, 'trusted_contacts', 'contact-1');
    await assertSucceeds(setDoc(contactRef, validTrustedContact()));
    await assertSucceeds(getDoc(contactRef));
    await assertSucceeds(updateDoc(contactRef, { name: 'Amara Updated' }));
    await assertFails(updateDoc(contactRef, { uid: 'user-b' }));
    await assertFails(
      updateDoc(contactRef, { createdAt: '2026-08-23T12:00:00.000Z' }),
    );
    await assertSucceeds(deleteDoc(contactRef));
  });

  it('denies foreign ownership and cross-user reads', async () => {
    await assertFails(
      setDoc(
        doc(dbFor('user-a'), 'trusted_contacts', 'foreign-contact'),
        validTrustedContact({ uid: 'user-b' }),
      ),
    );

    await assertSucceeds(
      setDoc(
        doc(dbFor('user-a'), 'trusted_contacts', 'contact-1'),
        validTrustedContact(),
      ),
    );
    await assertFails(
      getDoc(doc(dbFor('user-b'), 'trusted_contacts', 'contact-1')),
    );
  });
});

describe('support events', () => {
  it('allows owner create/read/delete but keeps events immutable', async () => {
    const db = dbFor('user-a');
    const eventRef = doc(db, 'support_events', 'event-1');
    await assertSucceeds(setDoc(eventRef, validSupportEvent()));
    await assertSucceeds(getDoc(eventRef));
    await assertFails(updateDoc(eventRef, { detail: 'Rewritten detail' }));
    await assertSucceeds(deleteDoc(eventRef));
  });

  it('denies foreign ownership and cross-user reads', async () => {
    await assertFails(
      setDoc(
        doc(dbFor('user-a'), 'support_events', 'foreign-event'),
        validSupportEvent({ uid: 'user-b' }),
      ),
    );

    await assertSucceeds(
      setDoc(
        doc(dbFor('user-a'), 'support_events', 'event-1'),
        validSupportEvent(),
      ),
    );
    await assertFails(
      getDoc(doc(dbFor('user-b'), 'support_events', 'event-1')),
    );
  });
});
