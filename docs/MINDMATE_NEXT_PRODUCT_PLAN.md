# MindMate next product plan

**Status:** Planning document only — no new payment, premium, organisation, or AI-personalisation implementation is included in the current release candidate.  
**Current release candidate:** `1.0.1+2`  
**Current branch:** `arena/01a05e3e-mindmate`  
**Current hosted app:** <https://mindmate-app-fcf2d.web.app>

This document records the product direction agreed after the competition release. The current Android/Web release remains the stable baseline. Future work must be implemented in separate, testable increments and must never be presented as already live until it has been built, tested, and deployed.

---

## 1. Product direction

MindMate should evolve from a collection of wellbeing tools into a **personalised support engine**:

```text
Check in
  → understand the situation
  → explain what might be happening without diagnosing
  → choose an appropriate next step
  → let the user try it
  → ask whether it helped
  → adapt or connect the user to support
```

The product promise becomes:

> **MindMate understands the kind of difficult moment someone is experiencing and helps them decide what to do next.**

The goal is not to maximise time spent in the app. The goal is to help a person take a useful, safe next step and keep a path to human support visible.

---

## 2. Non-negotiable product boundaries

These apply to every future phase:

- MindMate is an AI wellbeing companion, not a therapist, doctor, emergency service, or diagnostic tool.
- The AI must not diagnose, prescribe, make clinical decisions, or claim certainty about a person.
- Crisis-first behaviour remains deterministic and must continue opening the trusted `EmergencySupportScreen` action.
- The AI may generate wording and recommendations, but it may only trigger allow-listed in-app actions.
- The AI must not choose arbitrary external URLs, invent emergency numbers, or autonomously escalate to another person.
- Crisis support, emergency routes, basic check-ins, basic One Safe Step, and essential support must not be paywalled.
- Private Chat history remains local and user-scoped where an identity is available; it is not written to Firestore.
- Journal AI reflection must be explicitly opt-in and limited to text the user deliberately reviews and shares.
- No ads, private-chat sales, hidden data monetisation, or manipulative engagement loops.
- No current claims of revenue, paying customers, premium access, subscriptions, Paystack, sponsors, school contracts, or NGO contracts until those systems genuinely exist.
- Emergency and professional resources must be re-verified against authoritative current sources before public release.

---

## 3. Free core experience

The essential MindMate journey stays accessible to young people:

- Contextual check-ins
- AI-generated “what might be happening?” guidance
- Personalised One Safe Step
- Basic AI Chat
- Basic journaling
- Basic CBT reflection
- Breathing and core meditation
- Curated Learn content
- Basic progress and feedback
- Trusted human-support routes
- Emergency Support

The free core is the mission layer. A user should not have to pay before they can understand what they are feeling or take their first safe step.

---

## 4. First product upgrade: AI-powered Personalised One Safe Step

This is the first implementation priority. It should be a vertical slice rather than a large feature collection.

### 4.1 Contextual check-in questions

Use a short, non-clinical flow:

**What feels strongest right now?**

- Low or sad
- Anxious or worried
- Overwhelmed
- Lonely or disconnected
- Frustrated or angry
- Numb or tired
- Okay, but I want to check in

**What is taking the most energy?**

- School or work
- Relationships or family
- Money
- Sleep or my body
- My thoughts
- Something else
- I am not sure

**What would help most right now?**

- Calm my mind
- Understand what I am feeling
- Get something off my chest
- Figure out what to do
- Connect with someone

**Optional context**

> Want to tell MindMate a little more?

The free-text context must be bounded and optional. This is a support check-in, not a clinical assessment.

### 4.2 Initial situations

Start with four high-value routes:

1. Overwhelmed
2. Lonely or disconnected
3. Overthinking
4. Low motivation

Do not add ten routes until these four are useful, tested, and safe.

### 4.3 AI guidance response

The AI should generate:

- Acknowledgement
- A cautious “what might be happening?” explanation
- A personalised One Safe Step
- Why the step may help
- One or two alternative approaches
- At most one gentle follow-up question

The response must use words such as “may”, “might”, and “can” instead of diagnosis language.

### 4.4 Safe action contract

The response should be structured and validated. The AI can produce dynamic copy, but the action must be an allow-listed ID, for example:

```text
breathing
meditation
journal_prompt
thought_reframe
small_plan
open_learn
open_chat
trusted_person_prompt
open_emergency_support
```

The client must reject unknown action IDs. The AI must not be allowed to invent a URL or arbitrary app navigation.

Illustrative response shape:

```json
{
  "summary": "It sounds like you may be carrying several demands at once.",
  "what_might_be_happening": "When too much competes for attention, starting can feel harder.",
  "next_step": {
    "title": "Make the next few minutes smaller",
    "description": "Write down what is competing for your attention, then choose one thing for today.",
    "action_id": "small_plan"
  },
  "alternatives": [
    { "title": "Try a calming reset", "action_id": "breathing" },
    { "title": "Talk it through", "action_id": "open_chat" }
  ]
}
```

### 4.5 Feedback and adaptation

After an activity, ask whether it helped:

- A lot
- A little
- Not really
- I want a different approach

For the first version, adaptation may be a safe rule-based selection rather than model training. The user should see that MindMate can switch between:

- Understand it — CBT or reflection
- Calm it — breathing or meditation
- Act on it — a small practical action
- Connect — trusted or professional support

---

## 5. AI across the app

AI should be an intelligence layer, not an uncontrolled replacement for the app:

### Home and check-in

- Interpret the structured context.
- Generate the “what might be happening?” card.
- Produce One Safe Step and alternatives.

### Learn

- Recommend existing curated articles based on the check-in.
- Explain why an article may be relevant.
- Never generate uncontrolled health content as the source of truth.

### Chat

- Receive check-in context when the user chooses to continue into Chat.
- Start with the user’s situation instead of making them repeat everything.

### Activities

- Use feedback to offer a different type of approach when the first activity did not help.

### Progress

- Eventually show cautious, non-clinical observations based on approved data.
- Never infer or state a diagnosis.

### Journal

- Future, explicitly opt-in only.
- Send only the selected entry or bounded excerpt after the user reviews what will be shared.
- Never send the complete journal history automatically.

### Deterministic areas

Keep these outside unrestricted AI control:

- Crisis routing
- Emergency numbers and resources
- Privacy controls
- Local Chat history saving/deletion
- Account access
- Payment entitlements
- Arbitrary links

---

## 6. Learn redesign

Learn should become the **understanding layer** of MindMate rather than a passive article library.

### New positioning

```text
Learn
Make sense of what you are going through.
```

### User-friendly entry paths

**I want to understand…**

- My emotions
- My thoughts
- My motivation
- My relationships
- My stress
- My habits

**I am dealing with…**

- Overthinking
- Feeling overwhelmed
- Feeling lonely
- Comparing myself
- People-pleasing
- Low motivation
- Brain fog
- Imposter feelings

**I want to learn how to…**

- Calm my mind
- Handle difficult thoughts
- Set boundaries
- Build healthier habits
- Understand my emotions
- Ask for help

### Article requirements

Every article should finish with:

> **What can you try now?**

The available actions should connect to existing tools:

- Try a breathing practice
- Write a short reflection
- Make one small plan
- Ask MindMate about this
- Find support

Existing curated articles should be re-tagged and connected before adding a large amount of new content. Learn should move users from:

```text
Understand → try something → reflect → adapt
```

---

## 7. Future paid depth layer

The following are future paid extensions, not current features or current revenue claims.

### 7.1 Structured wellbeing programmes

Examples:

- 7-Day Overthinking Reset
- 7-Day Better Sleep Routine
- 5-Day Stress and Focus Plan
- 7-Day Confidence Reset
- 7-Day Reconnection Routine

A programme can combine daily check-in, explanation, activity, small action, reflection, and progress review.

### 7.2 Personalised My Plans

The free core gives one safe step. A future paid layer may create a longer, structured plan around a user-selected goal.

### 7.3 Advanced opt-in AI reflection

Possible future capabilities:

- Themes in selected journal entries
- Possible stressors
- Reflection questions
- Thought-pattern prompts
- Suggested next steps

This must remain optional, bounded, non-diagnostic, and transparent.

### 7.4 Expanded guided content

Potential future paid depth may include:

- Specialised programmes
- Longer audio sessions
- Additional guided routines
- More structured practice journeys

### 7.5 Advanced patterns

Future progress insights may carefully describe observations such as:

> “You have been checking in more often when your workload feels high.”

They must never become diagnoses or claims of clinical certainty.

---

## 8. Competition payment demonstration

A competition-only payment demonstration may be added later, but it must not be confused with a real payment system.

Suggested demo product:

```text
7-Day Overthinking Reset
Illustrative future paid feature
```

Demo flow:

1. User opens the structured programme.
2. The screen explains that it is a future paid extension.
3. An illustrative price may be shown as “to be validated”.
4. The user taps **Simulate demo unlock**.
5. The app explicitly says no payment was processed and no bank details were requested.
6. A local demo entitlement unlocks the preview.
7. The programme opens.

Do not use Paystack, real card fields, real subscriptions, or real charges in the competition demo.

Do not label the result “payment successful”. Use:

> **Demo access unlocked — no payment was processed.**

---

## 9. Future organisation / NGO / foundation model

This is a future funding hypothesis, not a current service claim.

Possible structure:

```text
Young person
  → Free MindMate core
  → Optional structured programmes

Organisation / foundation / CSR funder
  → Sponsors access to approved structured programmes
```

A real organisation product would require:

- Organisation accounts
- Admin roles
- Cohorts or groups
- Invite codes or sponsored seats
- Consent and safeguarding rules
- Aggregate reporting only
- Programme configuration
- Support and onboarding
- Contracts and privacy policies

Organisations must never receive:

- Individual Chat history
- Private journal entries
- Personal check-in details
- Individual emotional profiles

Potential aggregate reporting could describe programme-level participation, not individual mental-health content.

Do not claim current NGO customers, sponsors, school contracts, or organisation revenue.

---

## 10. Recommended implementation order

### Phase 0 — Preserve the release

- Keep the current Android APK, App Bundle, Web deployment, QR, and hash as the stable baseline.
- Do not modify the current release artifact in place.
- Create a new release candidate for every future code change.

### Phase 1 — Personalised One Safe Step

- Add the three-question contextual check-in.
- Add a bounded optional context field.
- Add a typed guidance response model.
- Extend the Worker request/response safely.
- Validate action IDs on the client.
- Render the AI-generated guidance card.
- Add the activity outcome feedback loop.
- Preserve deterministic crisis-first routing.

### Phase 2 — Connect Learn

- Add situation tags and action metadata to curated articles.
- Show context-based article recommendations.
- Add “What can you try now?” actions to articles.
- Keep article content curated and reviewable.

### Phase 3 — Competition payment demonstration

- Add one clearly labelled simulated structured programme.
- Use local demo entitlement only.
- No real payment provider, card details, or charge.
- Demonstrate the future user experience honestly.

### Phase 4 — Future depth features

- Structured programmes
- My Plans
- Expanded guided content
- Explicit opt-in journal reflection
- Cautious patterns and progress insights

### Phase 5 — Organisation model

- Validate demand with organisations first.
- Design privacy-safe organisation accounts and cohorts.
- Build aggregate reporting only after the service being sold is real.
- Add genuine payment and entitlement verification only after policy and provider decisions.

---

## 11. Definition of success

The product upgrade is successful when a user can say:

> “MindMate understood what I was dealing with, explained it without diagnosing me, gave me a useful next step, and helped me try another approach when the first one did not help.”

The business direction is successful when we can honestly say:

> “The core support journey remains accessible, future paid depth is clearly separated, organisation funding protects user privacy, and no current revenue is claimed before it exists.”
