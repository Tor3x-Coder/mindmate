# MindMate competition demo runbook

## Before presenting

- Open <https://mindmate-app-fcf2d.web.app> in a prepared browser tab.
- Keep the release APK available on the Android phone and retain the APK hash.
- Keep `docs/mindmate-web-qr.png` ready to display or print.
- Use a demo account; never expose a real user's private information.
- Confirm the phone has charge, mobile data/Wi-Fi, and enough space for the release APK.
- Do not upgrade dependencies or make last-minute production changes.

## Suggested five-minute flow

1. **Problem — 30 seconds**
   - Young people often need a calm, private first step before they are ready to ask for help.
   - MindMate turns that moment into a small check-in, a practical activity, reflection, and a route to human support.

2. **Home and check-in — 45 seconds**
   - Show the calm home screen and complete a short check-in.
   - Point out that the app suggests one small step rather than pretending to solve everything at once.

3. **Practice — 45 seconds**
   - Open a short breathing or meditation activity.
   - Show the captions, pacing, and pause/stop controls.
   - Mention that the core Learn and practice content remains available locally after it has been bundled into the app.

4. **Learn to Chat — 60 seconds**
   - Open a Learn article.
   - Tap **Ask MindMate about this**.
   - Show the article-context banner and ask for one practical next step.
   - Explain that the AI is identified as an AI companion, not a therapist or doctor.

5. **Chat history — 45 seconds**
   - Open the hamburger drawer.
   - Show New chat, Today/Older conversations, switching, and local history.
   - Explain that chat history is stored on the device, scoped to the signed-in account where available, bounded, and not written to Firestore.

6. **Safety route — 45 seconds**
   - Use the prepared safe crisis test phrase only; do not improvise a personal crisis story during the presentation.
   - Show the deterministic Emergency Support action and destination.
   - Explain that MindMate does not diagnose, prescribe, autonomously escalate, or choose arbitrary external links.

7. **Close — 30 seconds**
   - Show the hosted URL or QR code.
   - End with the product boundary: MindMate is a supportive first step and bridge to trusted human help, not a replacement for professional or emergency care.

## If something goes wrong

- **Web network issue:** switch to the signed APK and demonstrate bundled Learn/practice content. Do not claim AI chat works offline.
- **AI response delay:** acknowledge the network dependency, wait once, then continue with Learn/practice and safety screens.
- **Phone battery issue:** use the hosted URL on a laptop/Chrome responsive view and show the QR for later Safari testing.
- **Emergency resource question:** explain that the screen provides the prepared support routes and that emergency numbers must be re-verified before public release.
- **Test data question:** use the demo account only; never show a real profile, journal, mood, or chat.

## Questions to answer consistently

- **Is MindMate a therapist?** No. It is a transparent AI companion for reflection and small next steps, with clear routes to human and emergency support.
- **Does the AI diagnose or prescribe?** No.
- **Where is Chat history stored?** Locally on the device, bounded and user-scoped where a signed-in identity is available; it is not stored in Firestore.
- **What happens during a crisis?** Crisis routing is deterministic and renders the trusted Emergency Support action; the user remains in control of opening support.
- **Does it work without internet?** Bundled Learn and practice content is available locally; AI responses require network access.
- **What is the business model today?** Do not claim current payment, premium, subscription, ad, sponsor, or school-licence revenue. Keep the competition discussion focused on the product, safety, impact, and validated prototype.
