# Prompt for the next coding chat

We are continuing MindMate development on the fixed branch `arena/01a05e3e-mindmate`.

Read `docs/MINDMATE_NEXT_PRODUCT_PLAN.md` first. Do not start by redesigning the whole app. Implement the first vertical slice only: **AI-powered Personalised One Safe Step**.

Current baseline:

- Release candidate `1.0.1+2` is stable and must remain recoverable.
- Android APK, App Bundle, and hosted Web release already exist.
- Chat history is local, user-scoped where possible, bounded, and not stored in Firestore.
- Crisis routing must remain deterministic and must continue opening `EmergencySupportScreen` through the trusted allow-listed action.
- The AI must not diagnose, prescribe, autonomously escalate, or choose arbitrary external URLs.
- No real payments, Paystack, subscriptions, premium entitlement system, ads, sponsor accounts, NGO dashboards, or organisation billing should be implemented in this first slice.

First implementation target:

1. Add a short contextual check-in with:
   - current feeling
   - biggest source of impact
   - what the user needs most
   - optional bounded free-text context
2. Add a typed context model and a typed guidance response model.
3. Extend the existing Chat/Worker contract carefully so the AI can generate:
   - acknowledgement
   - non-diagnostic “what might be happening?” explanation
   - dynamic One Safe Step wording
   - why the step may help
   - one or two alternatives
   - at most one gentle question
4. Require the AI to return an allow-listed `action_id`; reject unknown actions.
5. Support the initial situations of overwhelmed, lonely/disconnected, overthinking, and low motivation without hardcoding the user-facing prose.
6. Use existing in-app actions where possible: breathing, meditation, journal prompt, thought reframe, small plan, Learn, Chat, trusted person prompt, and Emergency Support.
7. Keep crisis detection ahead of normal guidance and preserve the trusted emergency action exactly.
8. Add tests for normal guidance, unknown action rejection, malformed AI output, crisis-first routing, and the check-in-to-guidance flow.
9. Do not automatically send full journal history. Journal reflection is a later, explicit opt-in feature.
10. After implementation, run Dart formatting, Flutter analyzer, focused tests, full Flutter tests, Worker tests, and manual checks before considering a new release candidate.

Do not code the paid/NGO system yet. After the contextual One Safe Step slice is stable, implement the clearly labelled competition-only simulated structured-programme unlock described in the plan. It must not request bank details, call a payment provider, or claim that money was charged.
