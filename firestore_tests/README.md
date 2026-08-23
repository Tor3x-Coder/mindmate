# MindMate Firestore rules tests

These tests run only against the local Firebase Firestore Emulator. They never read or modify the live `mindmate-app-fcf2d` database.

## Covered authorization cases

- owner profile creation and ordinary profile updates;
- self-admin creation/promotion denial;
- cross-user profile denial;
- pending-only appointment creation;
- foreign UID and extra appointment field denial;
- owner appointment read/query/delete;
- owner appointment update/self-approval denial;
- admin all-request read and status-only approve/decline;
- invalid admin status/details changes denial;
- trusted-contact owner CRUD, immutable UID/createdAt, and cross-user denial;
- support-event owner create/read/delete, update denial, and cross-user denial.

## Requirements

- Node.js 20, 22, or 24;
- Java 21 or newer available as `java` in the terminal;
- npm.

## Run

First check Java:

```powershell
java -version
```

If PowerShell cannot find Java but Android Studio is installed, temporarily use its bundled runtime:

```powershell
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
java -version
```

Then, from `T:\Dev\mindmate\firestore_tests`:

```powershell
npm install
npm test
```

`npm test` starts the Firestore Emulator, runs the Mocha suite, and stops the emulator automatically. Test dependencies are development-only: `npm audit --omit=dev` reports 0 production vulnerabilities, and the locked toolchain currently has no high/critical audit findings.

Expected result:

```text
13 passing
```

Do not deploy `firestore.rules` until these tests pass and `flutter analyze` confirms the client/service guard changes compile.
