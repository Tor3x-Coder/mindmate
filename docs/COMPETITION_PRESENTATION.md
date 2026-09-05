# MindMate competition presentation

**Recommended length:** 6–8 minutes including the live demo  
**Product release:** MindMate `1.0.1+2`  
**Live demo:** <https://mindmate-app-fcf2d.web.app>  
**Competition QR:** `docs/mindmate-web-qr.png`

This is the presentation story. Keep slides visual and use the notes as the speaking script; do not put every paragraph on a slide.

---

## Slide 1 — MindMate

### One small step toward a better day

**On the slide**

- MindMate
- A calm, private wellbeing companion for young people
- Check in → take one small step → reflect → find support
- Team: `[team names]`

**Speaker notes**

“Many people do not need a huge solution in the first difficult moment. They need a safe, low-pressure first step. MindMate is designed to help a young person check in, try one practical action, reflect on what happened, and reach trusted human support when they need it.”

---

## Slide 2 — The problem

### The first step is often the hardest one

**On the slide**

- Stress and difficult feelings are often carried privately.
- Asking for help can feel too big, too formal, or too late.
- Generic advice does not meet someone where they are.
- A wellbeing tool must be supportive without pretending to be a clinician.

**Speaker notes**

“We focused on the moment before someone is ready for formal help. The product challenge is not to replace a counsellor. It is to make the next safe step easier while keeping a clear bridge to people and services.”

---

## Slide 3 — Our solution

### A gentle loop, not a feature catalogue

**On the slide**

1. **Check in** with words and context.
2. **Choose one small step** — breathing, meditation, reflection, or a practical plan.
3. **Reflect** on whether it helped.
4. **Connect to support** when self-guided help is not enough.

**Speaker notes**

“MindMate is organised around one repeatable journey. The user is not forced into a long questionnaire or a huge library. They can start with a small action and change direction at any time.”

---

## Slide 4 — Live demo

### Show the journey in the product

**Demo order**

1. Home check-in and the **One Safe Step** suggestion.
2. A short breathing or meditation practice with captions and controls.
3. Learn article: open a read and tap **Ask MindMate about this**.
4. Chat: ask for one practical next step.
5. Open the hamburger drawer and show **New chat**, Today/Older threads, switching, and local history.
6. Use the prepared safe crisis test phrase and show the trusted **Emergency Support** action.
7. Finish on the hosted URL or QR code.

**Speaker notes**

“Notice the handoff between the sections. Learn does not end at an article; it can give the conversation context. Chat does not become a black box; it has boundaries and a visible route to human support.”

**Demo rule**

Use a prepared demo account and safe test text. Never display real journal entries, private conversations, passwords, or a real person’s crisis story.

---

## Slide 5 — Safety by design

### Helpful does not mean pretending to be a professional

**On the slide**

- The AI is identified as an AI companion.
- It does not diagnose, prescribe, or claim to be therapy.
- Crisis detection is deterministic and routes to a trusted in-app Emergency Support screen.
- The model cannot choose arbitrary external URLs or autonomously escalate.
- Difficult-day replies acknowledge first, offer a practical step or small options, and ask at most one gentle question.

**Speaker notes**

“We treated safety as a product boundary, not a disclaimer at the bottom of a screen. The crisis action is allow-listed and deterministic. The AI can support reflection, but it does not make clinical decisions or take control away from the user.”

---

## Slide 6 — Privacy and trust

### The most personal conversations should not become a new data problem

**On the slide**

- Chat history is stored locally on the device.
- History is scoped to the signed-in account where an identity is available.
- It is bounded: 12 conversations, 24 messages per conversation, 4,000 stored characters per message.
- Chat history is not written to Firestore.
- Learn and practice content is bundled for a dependable core experience.
- Network-dependent AI responses are presented honestly as network-dependent.

**Speaker notes**

“We deliberately did not create a Firestore chat collection. Local history makes the privacy boundary easier to explain and reduces the amount of sensitive conversation data we retain. The limits also keep local storage predictable.”

---

## Slide 7 — Evidence of execution

### From idea to a tested release candidate

**On the slide**

- Android release APK: `1.0.1+2`, 65.4 MB
- Android App Bundle: 54.2 MB
- Hosted Flutter Web: `mindmate-app-fcf2d.web.app`
- Flutter tests: **53/53 passed**
- Chrome responsive smoke test passed
- APK SHA-256 recorded for release integrity
- Web QR ready for the coach’s phone

**Speaker notes**

“This is not only a mockup. We built and tested Android and Web release artifacts, deployed the Web version, and validated the main user journeys. The remaining Safari check is an external device check when an iPhone is available; the product is already live and ready to open.”

---

## Slide 8 — Impact and responsibility

### A practical first step can widen access to support

**On the slide**

- Lower the friction before asking for help.
- Make small wellbeing practices easier to discover and repeat.
- Keep emergency and human support visible.
- Respect privacy and avoid manipulative engagement.
- Design for young people without reducing them to a score.

**Speaker notes**

“Our impact goal is not to measure how long someone stays inside the app. It is to help them take a useful next step and know where to go when they need another person.”

---

## Slide 9 — Stewardship and the road ahead

### Build trust before adding complexity

**On the slide**

**Today**

- Validated prototype with Android and Web releases
- Local Chat history and transparent safety boundaries
- No current payment, subscription, advertising, or sponsor revenue claim

**Next**

- Repeat device and accessibility testing with young users and qualified reviewers
- Continue health-literate review of content and emergency resources
- Evaluate sustainable funding only with privacy, safety, and policy requirements in place

**Speaker notes**

“We are not presenting unimplemented monetisation as current revenue. For this stage, financial stewardship means being honest about what is built, protecting trust, and not rushing a paid system into a sensitive product.”

---

## Slide 10 — Closing

### MindMate helps make the next safe step feel possible

**On the slide**

- Try the app: `https://mindmate-app-fcf2d.web.app`
- Scan the QR code
- Check in → take one small step → reflect → connect
- Thank you

**Speaker notes**

“MindMate does not promise to solve every difficult day. It helps someone begin: with one small step, an honest boundary, and a clearer path to support.”

---

# Likely judge questions

## What makes MindMate different from a generic chatbot?

MindMate is a guided wellbeing journey rather than an open-ended chatbot alone. It combines check-ins, local Learn content, practical exercises, contextual Chat, bounded local history, and a deterministic crisis route.

## Can the AI replace a counsellor?

No. It is explicitly an AI companion for reflection and small next steps. It does not diagnose, prescribe, or replace professional or emergency support.

## What happens to private chats?

Saved Chat history stays on the device and is scoped to the signed-in user where possible. It is bounded and is not written to Firestore. AI requests still require network access when the user chooses to send a message.

## What happens during a crisis?

The crisis route is handled before normal conversational behaviour. The interface renders the trusted Emergency Support action, which opens the in-app support screen. The app does not autonomously contact someone or select arbitrary links.

## How does the project sustain itself?

Do not claim current revenue or paid access. The competition release is a validated prototype. Any future sustainability model must be evaluated around safety, privacy, affordability, and provider/platform requirements before implementation.

## What did the team learn?

A strong wellbeing product needs more than attractive screens: clear boundaries, reliable content, safe failure paths, private data handling, and a release process that tests the real user journey.

# Team role split template

- **Opening/problem:** `[Name]`
- **Product journey/demo:** `[Name]`
- **Technology and safety:** `[Name]`
- **Impact/stewardship/closing:** `[Name]`
- **Backup operator:** `[Name]`

Every speaker should know the demo fallback: if the Web network is unavailable, switch to the signed APK and show bundled Learn/practice content without claiming that AI Chat works offline.
