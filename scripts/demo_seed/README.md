# MindMate demo history seed

This is a one-off, repeatable Firebase Admin SDK script for the competition
account. Register the demo account normally through the app first. The script
then writes three weeks of synthetic, clearly non-clinical history to that
account using deterministic `demo_seed_v1_*` document IDs.

It seeds only these existing personal collections:

- `mood_logs`
- `journal_entries`
- `wellness_assessments`
- `meditation_history`
- `breathing_sessions`
- `thought_records`
- `feedback_records`

It does **not** write the `users` profile, professionals, appointments,
trusted contacts, support events, or chat data. It does not delete anything.
Rerunning it updates only its own deterministic seed documents, so it is safe
to tweak and rerun for the same demo account.

## Install the Admin SDK when you are ready

This is separate from Flutter and does not change the app dependencies.

```powershell
cd scripts/demo_seed
npm install
```

Keep the service-account JSON outside the repository. Never paste it into chat,
commit it, or put it in a public folder. The script accepts either
`GOOGLE_APPLICATION_CREDENTIALS` or `--service-account`.

## Preview without Firebase or writes

This is the default behavior. It validates the target argument and prints the
50-document plan without loading credentials or contacting Firebase.

```powershell
node seed_demo_data.mjs --email demo@example.com
```

You can pin the date for a repeatable preview:

```powershell
node seed_demo_data.mjs --uid FIREBASE_UID --as-of 2026-09-02
```

## Apply to the registered demo account

Use the real email or UID of the account you registered in the app. `--apply`
and `--confirm-demo` are both required before any write is allowed.

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = 'T:\private\mindmate-demo-service-account.json'
node seed_demo_data.mjs --email demo@example.com --apply --confirm-demo
```

Or with a direct credential path:

```powershell
node seed_demo_data.mjs `
  --uid FIREBASE_UID `
  --service-account 'T:\private\mindmate-demo-service-account.json' `
  --apply `
  --confirm-demo
```

The script first resolves the Firebase Auth user, then writes one Firestore
batch. If the email/UID is wrong, stop before using `--apply`; the script never
tries to find or modify another account automatically.

## Tests

The pure planning and safety checks do not contact Firebase:

```powershell
npm test
```

The script does not deploy the app or the AI Worker, and it does not require an
APK/Web build.
