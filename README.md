MindMate
MindMate is an action-first mental wellness companion that helps people move from:

“I do not know what to do right now.”

…to one small, personalised, safe next step.

Users can check in with how they feel, receive a suitable guided activity, reflect privately, see patterns over time, talk with an AI companion, and connect with real human support when self-guided tools are not enough.

MindMate is being developed as a real-world wellness product. It is currently a competition prototype/private beta and is not a diagnostic or clinical tool.

Core experience
text

Mood check-in
      ↓
Understand the current need
      ↓
Recommend one next step
      ↓
Breathing / meditation / journaling / CBT / chat / support
      ↓
Ask whether it helped
      ↓
Offer another approach or human support
MindMate does not try to replace therapy or emergency care. It helps users take a supported first step and find the right kind of help.

Safety boundary
MindMate does not:

diagnose mental-health conditions;
prescribe medication or treatment;
claim to be a therapist, doctor, or emergency service;
decide whether a person is safe;
replace qualified professional or emergency care.
The AI companion is for supportive conversation and reflection only. If a user may be in immediate danger, MindMate directs them to emergency and crisis-support resources instead of treating normal AI chat as sufficient help.

Current product features
Core user experience
Firebase email/password registration and login
Password visibility toggle and password reset
Terms and Privacy acknowledgement during registration
Illustration onboarding carousel
Personalisation setup with goals and preferred check-in window
Bottom navigation: Home, Practice, Chat, and Me
Light/dark/system theme settings
Text-size and animation preferences
Session persistence through Firebase Auth
Mood and NextStep flow
Mood check-in using shared mood options
Qualitative impact choices instead of forcing users to choose a numerical intensity:
A little
Somewhat
A lot
Overwhelming
Not sure yet
Mood-aware copy and recommendations
NextStep screen with one recommended action and a small number of alternatives
Post-activity feedback options:
Much worse
A little worse
About the same
A little better
Much better
Not sure yet
Feedback currently stays in frontend state; persistence is planned for the backend phase
Guided practices
Breathing patterns:
Box Breathing
4-7-8 Breathing
Simple Calm
Adjustable 1, 3, and 5-minute breathing sessions
Animated breathing figure and progress display
Meditation journey organised by intention:
Stress Relief
Sleep
Focus
Anxiety
Gratitude
Morning
Three guided sessions per meditation category
3D meditation guide model through model_viewer_plus
Meditation timers and on-screen guidance
Meditation history logging
CBT-style thought-reframe wizard with branching categories:
Relationship
School/work
Mistake/regret
Future worry
Self-doubt
Sad/low
Angry/frustrated
Hurt/disappointed
Something else
Branch-specific CBT questions with a neutral fallback path
Before/after thought-intensity reflection
Reflection and progress
Private journal entries
Optional journal prompts
Create, edit, and delete journal entries
Diary-style recent-entry cards
Progress screen focused on effort, observations, mood trail, and what seems helpful
Achievements screen with gentle milestones and unlocked wins
No-guilt achievement language; missed days are not treated as failure
Rule-based pattern insights across mood and wellness history
Human support
Professional support directory
Support-need filters such as Stress, Relationships, and Sleep
Professional profiles with category, bio, location, contact details, and online/physical availability
Appointment request flow:
choose consultation type;
choose preferred date and time;
review details;
send a request;
request starts as pending.
My Requests screen with request timeline and status history
Admin appointment review queue with approve/decline UI
Emergency Support screen with Nigeria-specific emergency resources and crisis-support links
Home shortcut: “Need help right now?”
Emergency Support follow-up asking whether the user managed to reach support
AI companion
Cloudflare Worker endpoint protects the AI model connection from the Flutter client
Guided conversation modes in the frontend:
Listen
Calm me
Make a plan
Suggested starters
Friendly AI failure state
Transparent AI-support disclaimer
Current chat messages remain in memory while the chat session is open
Planned but not finished
Backend and data
Save qualitative mood-impact choices to Firestore
Save activity feedback and use it to improve recommendations
Add a proper recommendation/history model for NextStep
Add optional AI reflection for journal entries with user consent
Add persistent chat sessions and a past-chat history screen
Add trusted-contact storage and owner-only rules
Track user-triggered call/message support actions without pretending the app knows whether the external call or message was completed
Add the missing thought_records Firestore rule
Strengthen UID-preservation rules on document updates
Finalise strict admin and appointment rules
Add backend enforcement for one active pending request per professional
Add admin appointment-review service methods and rules
Real professional system
The current directory is request-based. A real professional platform will eventually need:

professional Firebase accounts;
provider roles and provider identity links;
provider appointment inboxes;
provider approval/decline actions;
email, push, or SMS notifications;
verified professional contact details;
availability/calendar handling;
user and provider status updates.
The competition prototype can demonstrate an admin/coordinator review queue first, but the long-term product is intended to support real professionals directly.

AI and safety
Send the selected conversation mode to the Cloudflare Worker as structured metadata
Give Listen, Calm me, and Make a plan separate behaviour instructions
Stop generic replies and unnecessary follow-up questions
Prevent the AI from inventing assumptions about budget, location, relationships, or preferences
Validate chat roles and reject client-injected system messages
Limit message/history sizes on the Worker
Add rate limiting and abuse protection
Add deterministic crisis routing before normal generation
Add an offline/fallback path when the Worker is unavailable
Clinician/wellness review of CBT, meditation, breathing, and crisis wording
Release readiness
Android real-device testing
Release APK signing
iOS testing if needed
App icon and final brand name
Privacy Policy and legally reviewed Terms
Data deletion/export controls
Accessibility pass
Error/loading/empty-state pass
Adversarial testing pass
Real audio and voice guidance for breathing and meditation
Meditation guide animation
Notification scheduling for check-in reminders
Community features remain on hold until a moderation plan exists
Technical stack
Flutter / Dart
Firebase Auth — email/password authentication
Cloud Firestore — moods, journals, wellness reflections, meditation history, professionals, appointments, thought records
Provider — state management
SharedPreferences — local settings
HTTP — communication with the AI Worker
Cloudflare Workers AI — AI companion backend
model_viewer_plus — 3D meditation guide
url_launcher — phone links and external support resources
The Flutter app does not contain an AI provider API key. The app sends requests to the Cloudflare Worker, where the AI binding/model is configured.

Project structure
text

lib/
  models/       # Data classes with fromMap/toMap methods
  screens/      # Feature screens and navigation flows
  services/     # Auth, Firestore, settings, and chat services
  utils/        # Theme, constants, and pattern logic
assets/
  illustrations/ # Onboarding and app illustrations
  models/       # 3D meditation guide models
web/
  index.html    # Flutter web setup and model-viewer web asset setup
Common patterns
Most features use a model, a Firestore service method, and a screen.
Collection names live in utils/constants.dart.
Theme colours should come from utils/app_theme.dart instead of raw colours.
Current user ID is read from AuthService.currentUser?.uid.
Firestore owner rules must protect every personal collection.
Any query combining where() and orderBy() may require a Firebase composite index.
Setup
Install Flutter and verify the environment:

Bash

flutter doctor
Install dependencies:

Bash

flutter pub get
Configure Firebase using FlutterFire. firebase_options.dart should be created for your own Firebase project and should not be treated as a shared secret/configuration for the team.

Deploy or paste the correct Firestore rules. Before release, make sure the rules include all collections currently used by the app, including thought_records.

Configure the Cloudflare Worker and its AI binding. Set the Worker URL in chat_service.dart.

Run the web app:

Bash

flutter run -d chrome --no-web-resources-cdn
The --no-web-resources-cdn flag is useful when the network cannot reach Google’s CanvasKit/font CDN. Without it, Flutter Web may fail before the app opens.

Run a debug Android build for team testing:

Bash

flutter build apk --debug
Output:

text

build/app/outputs/flutter-apk/app-debug.apk
Build a release APK when the team has finished testing:

Bash

flutter build apk --release
Web 3D model setup
For the 3D meditation guide on Web, confirm that web/index.html includes the required model_viewer_plus script:

HTML

<script type="module" src="./assets/packages/model_viewer_plus/assets/model-viewer.min.js" defer></script>
Test the model on the actual browser/device that will be used for the competition.

Competition status
Competition: 11 September 2026
Target feature freeze: 28 August 2026
The competition accepts prototypes, so the immediate goal is one polished, reliable end-to-end journey rather than every future production feature.
The main demo journey should be:

text

User checks in
      ↓
MindMate recommends a next step
      ↓
User tries an activity
      ↓
User says whether it helped
      ↓
MindMate offers another option or human support
Brand note
MindMate is currently a working name. Before public launch, check app-store names, domains, social handles, and trademarks because other wellness products use similar names.

License and attribution
Add third-party model, icon, illustration, font, and asset credits here as they are confirmed.

Third-party asset credits: (to be completed)