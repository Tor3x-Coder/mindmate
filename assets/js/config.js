// MindMate landing site configuration.
// Fill in the empty values when they are available. No build step needed —
// this file is plain JS read by site.js at page load.
window.MINDMATE_LANDING = {
  identity: {
    app: 'MindMate',
    team: 'Junior Achievers — FG Enugu (JA FGCE)',
  },

  // Set to null until the Batch 13 signed, versioned release APK exists.
  // Never point this at app-debug.apk. Once ready, set all fields, e.g.:
  // apk: {
  //   version: '1.0.0+1',
  //   sizeLabel: '18.4 MB',
  //   minAndroid: 'Android 6.0 or newer',
  //   sha256: 'abc123…',
  //   url: 'https://github.com/Tor3x-Coder/mindmate/releases/download/v1.0.0/mindmate-release.apk',
  // },
  apk: null,

  // Google Play external deletion-request workflow (Batch 13A).
  // deleteRequestFormUrl: hosted form (Google Form / Tally) that former users
  // submit without reinstalling the app — set when the form is created.
  deleteRequestFormUrl: 'https://docs.google.com/forms/d/e/1FAIpQLSfTh8fk8S7Pa54Xj2vjEaxXwlWOck_PVfO3IIGtTTwhbgq9iw/viewform',
  supportEmail: 'tor3x.akachukwu@gmail.com',

  // Final published URL (used by the QR code and share links).
  siteUrl: 'https://tor3x-coder.github.io/mindmate/',
};
