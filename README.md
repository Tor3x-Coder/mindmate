# MindMate landing site (Batch 13A)

**Status:** implemented (26 Aug 2026) — pending form URL, support email, and real screenshots.

A lightweight static informational site for MindMate. Vanilla HTML/CSS/JS, no build
step, no frameworks. It is **not** a hosted Flutter app: there is no Sign In/Register
and nothing routes visitors into Flutter Web (`web/index.html` stays the dev-only
Flutter Web shell).

## What's in it

- `index.html` — hero, the check-in → one small step loop, feature grid, screenshot
  frames, safety/privacy boundaries, FAQ, APK download card, QR code.
- `delete-account/index.html` — the Google Play external deletion-request resource:
  app/developer identity, exactly what gets deleted, in-app deletion steps, and the
  external request flow (hosted form + support email).
- `assets/js/config.js` — **fill in when available:**
  - `apk` — set the signed release APK metadata (version, size, min Android, SHA-256,
    URL) once Batch 13 produces it. Until then the download card honestly says the
    release build is being prepared — it never links a debug APK and never shows a
    broken button.
  - `deleteRequestFormUrl` — the hosted form (Google Form / Tally) for deletion
    requests. Until set, the form button is hidden (no dead links) and a note
    explains how to reach the team.
  - `supportEmail` — the real team inbox (drives the mailto fallback).
- `assets/js/site.js` — renders the config-dependent parts. Tiny, no dependencies.
- `assets/css/site.css` — Quiet Tide palette, mobile-first, accessible
  (skip link, landmarks, focus-visible, reduced-motion support).
- `assets/img/qr.png` — QR for `https://tor3x-coder.github.io/mindmate/`. **Regenerate
  if the final Pages URL differs.**

## Screenshots

Real screenshots go in `assets/screenshots/` (suggested names:
`home.png`, `practice.png`, `snapshot.png`, `emergency.png` — 9:19 portrait phone
shots). Then replace each `.shot-placeholder` div in `index.html` with, e.g.:

```html
<img src="assets/screenshots/home.png" alt="MindMate home screen showing today's one small step" loading="lazy" />
```

AI-generated or mocked-up screenshots are not allowed — real captures only.

## Deploying to GitHub Pages

1. Push this repository's branch (the landing folder must exist in the branch you
   deploy).
2. On GitHub: **Repository → Settings → Pages → Build and deployment → Source:
   "Deploy from a branch"**.
3. Branch: the branch you deploy (e.g. `arena/01a03a5d-mindmate` for now, or `main`
   after the work lands there). Folder: **`/landing (root)`**.
4. Site URL: `https://tor3x-coder.github.io/mindmate/`.
5. Verify: open the site, click through `/delete-account/`, and confirm the QR.

Note: GitHub Pages serves the selected folder at the repo's site root, so
`landing/delete-account/index.html` becomes `/delete-account/` — no broken routes.

## Release checklist (when Batch 13 produces the signed APK)

- [ ] Fill `assets/js/config.js → apk` (version, size, min Android, SHA-256, release URL).
- [ ] Publish the APK to GitHub Releases (keep APK binaries out of ordinary Git
      history — they are already excluded from this site by design).
- [ ] Fill `deleteRequestFormUrl` and `supportEmail`; confirm the form button appears
      and the mailto works.
- [ ] Swap screenshot placeholders for real captures.
- [ ] Re-verify the QR matches the final URL; re-check responsive mobile + desktop.
- [ ] Record the deployed URL in `MINDMATE_STATUS.md`.
