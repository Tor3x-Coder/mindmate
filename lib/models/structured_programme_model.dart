import 'package:flutter/material.dart';

class ProgrammeDay {
  final int dayNumber;
  final String title;
  final String focus;
  final String description;
  final String activityTitle;
  final String activityDescription;
  final String actionId; // allow-listed action
  final String reflectionPrompt;

  const ProgrammeDay({
    required this.dayNumber,
    required this.title,
    required this.focus,
    required this.description,
    required this.activityTitle,
    required this.activityDescription,
    required this.actionId,
    required this.reflectionPrompt,
  });
}

class StructuredProgramme {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String longDescription;
  final String category;
  final int durationDays;
  final String priceLabel; // e.g. "to be validated"
  final Color color;
  final IconData icon;
  final List<String> whatYouGet;
  final List<ProgrammeDay> days;

  const StructuredProgramme({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.longDescription,
    required this.category,
    required this.durationDays,
    required this.priceLabel,
    required this.color,
    required this.icon,
    required this.whatYouGet,
    required this.days,
  });
}

// Demo catalogue — illustrative future paid features, no real payment
const List<StructuredProgramme> demoProgrammes = [
  StructuredProgramme(
    id: 'overthinking_reset_7',
    title: '7-Day Overthinking Reset',
    subtitle: 'Illustrative future paid feature',
    description:
        'A gentle 7-day routine to notice overthinking patterns, calm the mind, and practise small next steps.',
    longDescription:
        'Overthinking can feel like your mind is stuck on replay. This 7-day illustrative programme shows how a future structured plan could combine daily check-in, a short explanation, one safe action, and reflection — without diagnosing or prescribing. This is a competition-only demo: no payment is processed, no bank details are requested.',
    category: 'Overthinking',
    durationDays: 7,
    priceLabel: 'to be validated',
    color: Color(0xFF6B7BFF),
    icon: Icons.psychology_outlined,
    whatYouGet: [
      'Daily 3-minute check-in + what might be happening',
      'One safe step (breathing, journal, thought reframe, small plan)',
      'Reflection prompt + optional chat follow-up',
      'Progress view — no diagnosis, no clinical claims',
    ],
    days: [
      ProgrammeDay(
        dayNumber: 1,
        title: 'Notice the loop',
        focus: 'Understand',
        description:
            'Today we notice when overthinking shows up — what triggers it, and what it feels like in your body.',
        activityTitle: '2-minute thought note',
        activityDescription:
            'Write down one thought that kept looping today. No need to solve it — just notice it.',
        actionId: 'journal_prompt',
        reflectionPrompt:
            'What did you notice about when the thought showed up?',
      ),
      ProgrammeDay(
        dayNumber: 2,
        title: 'Name what matters',
        focus: 'Understand',
        description:
            'When thoughts loop, they often point to something you care about. Naming it can make it less heavy.',
        activityTitle: 'What might be underneath?',
        activityDescription:
            'Pick one looping thought and ask: what might this be about? e.g. wanting to do well, caring about someone.',
        actionId: 'thought_reframe',
        reflectionPrompt: 'What felt most true when you named it?',
      ),
      ProgrammeDay(
        dayNumber: 3,
        title: 'Calm the body',
        focus: 'Calm',
        description:
            'Overthinking lives in the mind, but it also shows up in breathing and tension. A short reset can help.',
        activityTitle: '3-minute breathing reset',
        activityDescription:
            'Try box breathing: 4 in, 4 hold, 4 out, 4 hold — for 3 minutes.',
        actionId: 'breathing',
        reflectionPrompt: 'How does your body feel after the reset?',
      ),
      ProgrammeDay(
        dayNumber: 4,
        title: 'Make it smaller',
        focus: 'Act',
        description:
            'Big worries feel huge. Breaking them into one small next step makes starting easier.',
        activityTitle: 'One tiny plan',
        activityDescription:
            'Choose one thing you can do in the next 10 minutes. Keep it smaller than you think you should.',
        actionId: 'small_plan',
        reflectionPrompt: 'Did making it smaller help you start?',
      ),
      ProgrammeDay(
        dayNumber: 5,
        title: 'Talk it through',
        focus: 'Connect',
        description:
            'You do not have to hold everything alone. Talking it through — even briefly — can lighten the loop.',
        activityTitle: 'Message a safe person or chat',
        activityDescription:
            'Share one sentence about how you have been feeling. You choose how much to share.',
        actionId: 'trusted_person_prompt',
        reflectionPrompt: 'What was it like to reach out, even a little?',
      ),
      ProgrammeDay(
        dayNumber: 6,
        title: 'Rest and reset',
        focus: 'Calm',
        description:
            'Overthinking often gets louder when you are tired. Today is about gentle rest, not fixing.',
        activityTitle: '5-minute wind-down',
        activityDescription:
            'Try a short meditation or slow breathing before bed. No goal — just a pause.',
        actionId: 'meditation',
        reflectionPrompt: 'What helped you feel a bit more rested?',
      ),
      ProgrammeDay(
        dayNumber: 7,
        title: 'Review and carry forward',
        focus: 'Reflect',
        description:
            'Look back at what helped most this week. What do you want to keep?',
        activityTitle: 'What will you carry forward?',
        activityDescription:
            'Write 2-3 things that helped, even a little. Choose one to try next week.',
        actionId: 'journal_prompt',
        reflectionPrompt:
            'What is one small thing you want to keep practising?',
      ),
    ],
  ),
  StructuredProgramme(
    id: 'better_sleep_7',
    title: '7-Day Better Sleep Routine',
    subtitle: 'Illustrative future paid feature',
    description:
        'A calm evening routine to wind down, notice sleep blockers, and build one small habit at a time.',
    longDescription:
        'Sleep and overthinking often go together. This illustrative programme shows how MindMate could guide a gentle sleep routine — check-in, explanation, safe step, reflection. Demo only: no payment processed.',
    category: 'Sleep',
    durationDays: 7,
    priceLabel: 'to be validated',
    color: Color(0xFF4DB6AC),
    icon: Icons.bedtime_outlined,
    whatYouGet: [
      'Evening check-in + wind-down idea',
      'Breathing / meditation / journal options',
      'Small next step for tomorrow',
      'Progress without diagnosis',
    ],
    days: [
      ProgrammeDay(
        dayNumber: 1,
        title: 'Notice your wind-down',
        focus: 'Understand',
        description: 'What do you usually do in the hour before sleep?',
        activityTitle: 'Evening note',
        activityDescription: 'Write down what you did last night before bed.',
        actionId: 'journal_prompt',
        reflectionPrompt: 'What pattern do you notice?',
      ),
      ProgrammeDay(
        dayNumber: 2,
        title: 'One screen-free pause',
        focus: 'Act',
        description: 'Try 10 minutes without screens before sleep.',
        activityTitle: 'Screen-free 10',
        activityDescription: 'Put your phone aside and do something calm.',
        actionId: 'meditation',
        reflectionPrompt: 'How did the pause feel?',
      ),
      ProgrammeDay(
        dayNumber: 3,
        title: 'Breathe out the day',
        focus: 'Calm',
        description: 'Slow breathing can signal to your body that it is safe to rest.',
        activityTitle: '4-7-8 breathing',
        activityDescription: 'Inhale 4, hold 7, exhale 8 — 3 rounds.',
        actionId: 'breathing',
        reflectionPrompt: 'Did your body feel a bit softer after?',
      ),
      ProgrammeDay(
        dayNumber: 4,
        title: 'Worry time earlier',
        focus: 'Understand',
        description: 'If worries pop up at night, try giving them earlier space.',
        activityTitle: 'Worry window',
        activityDescription: 'During the day, write worries down for 5 minutes, then close the note.',
        actionId: 'thought_reframe',
        reflectionPrompt: 'Did having a worry window help at night?',
      ),
      ProgrammeDay(
        dayNumber: 5,
        title: 'Make tomorrow smaller',
        focus: 'Act',
        description: 'Write one small plan for tomorrow so your mind can let go tonight.',
        activityTitle: 'Tiny tomorrow plan',
        activityDescription: 'One thing for tomorrow morning, kept tiny.',
        actionId: 'small_plan',
        reflectionPrompt: 'Did planning help you rest?',
      ),
      ProgrammeDay(
        dayNumber: 6,
        title: 'Connect in daylight',
        focus: 'Connect',
        description: 'Daytime connection can make nights feel less heavy.',
        activityTitle: 'Daytime check-in',
        activityDescription: 'Message someone or step outside briefly in daylight.',
        actionId: 'trusted_person_prompt',
        reflectionPrompt: 'How did daylight connection feel?',
      ),
      ProgrammeDay(
        dayNumber: 7,
        title: 'Keep what helped',
        focus: 'Reflect',
        description: 'Review what wind-down steps helped, even a little.',
        activityTitle: 'Keep 2 steps',
        activityDescription: 'Pick 2 wind-down ideas to keep next week.',
        actionId: 'journal_prompt',
        reflectionPrompt: 'What will you keep?',
      ),
    ],
  ),
];
