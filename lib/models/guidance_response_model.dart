import 'check_in_context_model.dart';

/// Allow-listed action IDs that the AI is permitted to return.
/// The client must reject any unknown action.
class GuidanceActionIds {
  static const String breathing = 'breathing';
  static const String meditation = 'meditation';
  static const String journalPrompt = 'journal_prompt';
  static const String thoughtReframe = 'thought_reframe';
  static const String smallPlan = 'small_plan';
  static const String openLearn = 'open_learn';
  static const String openChat = 'open_chat';
  static const String trustedPersonPrompt = 'trusted_person_prompt';
  static const String openEmergencySupport = 'open_emergency_support';

  static const Set<String> all = {
    breathing,
    meditation,
    journalPrompt,
    thoughtReframe,
    smallPlan,
    openLearn,
    openChat,
    trustedPersonPrompt,
    openEmergencySupport,
  };

  static bool isAllowed(String? id) => id != null && all.contains(id);
}

class GuidanceAlternative {
  final String title;
  final String actionId;

  const GuidanceAlternative({
    required this.title,
    required this.actionId,
  });

  factory GuidanceAlternative.fromJson(Map<String, dynamic> json) {
    final title = json['title'];
    final actionId = json['action_id'] ?? json['actionId'];
    if (title is! String || title.trim().isEmpty) {
      throw const FormatException('Invalid alternative title');
    }
    if (actionId is! String || !GuidanceActionIds.isAllowed(actionId)) {
      throw const FormatException('Invalid or disallowed alternative action_id');
    }
    return GuidanceAlternative(
      title: title.trim(),
      actionId: actionId,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'action_id': actionId,
      };
}

class GuidanceNextStep {
  final String title;
  final String description;
  final String actionId;
  final String? whyItMightHelp;

  const GuidanceNextStep({
    required this.title,
    required this.description,
    required this.actionId,
    this.whyItMightHelp,
  });

  factory GuidanceNextStep.fromJson(Map<String, dynamic> json) {
    final title = json['title'];
    final description = json['description'];
    final actionId = json['action_id'] ?? json['actionId'];
    final why = json['why_it_might_help'] ?? json['whyItMightHelp'];

    if (title is! String || title.trim().isEmpty) {
      throw const FormatException('Invalid next_step title');
    }
    if (description is! String || description.trim().isEmpty) {
      throw const FormatException('Invalid next_step description');
    }
    if (actionId is! String || !GuidanceActionIds.isAllowed(actionId)) {
      throw FormatException('Invalid or disallowed next_step action_id: $actionId');
    }

    return GuidanceNextStep(
      title: title.trim(),
      description: description.trim(),
      actionId: actionId,
      whyItMightHelp: why is String && why.trim().isNotEmpty ? why.trim() : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'action_id': actionId,
        if (whyItMightHelp != null) 'why_it_might_help': whyItMightHelp,
      };
}

class GuidanceResponse {
  final String summary;
  final String whatMightBeHappening;
  final GuidanceNextStep nextStep;
  final List<GuidanceAlternative> alternatives;
  final String? gentleQuestion;
  final String? whyItMightHelp;
  final bool isCrisis;
  final String? crisisNote;

  // The original check-in for local display / feedback loop.
  final CheckInContext? checkInContext;

  const GuidanceResponse({
    required this.summary,
    required this.whatMightBeHappening,
    required this.nextStep,
    this.alternatives = const [],
    this.gentleQuestion,
    this.whyItMightHelp,
    this.isCrisis = false,
    this.crisisNote,
    this.checkInContext,
  });

  bool get hasEmergencyAction =>
      nextStep.actionId == GuidanceActionIds.openEmergencySupport ||
      alternatives.any((a) => a.actionId == GuidanceActionIds.openEmergencySupport);

  factory GuidanceResponse.fromJson(
    Map<String, dynamic> json, {
    CheckInContext? context,
  }) {
    // Support both snake_case and camelCase from Worker.
    final summary = json['summary'] as String?;
    final whatMight = json['what_might_be_happening'] ??
        json['whatMightBeHappening'] as String?;
    final nextStepRaw = json['next_step'] ?? json['nextStep'];
    final alternativesRaw = json['alternatives'] as List?;
    final gentleQuestion = json['gentle_question'] ?? json['gentleQuestion'];
    final whyItMightHelp = json['why_it_might_help'] ?? json['whyItMightHelp'];
    final isCrisis = json['is_crisis'] == true || json['isCrisis'] == true;
    final crisisNote = json['crisis_note'] ?? json['crisisNote'];

    if (summary is! String || summary.trim().isEmpty) {
      throw const FormatException('Invalid guidance summary');
    }
    if (whatMight is! String || whatMight.trim().isEmpty) {
      throw const FormatException('Invalid what_might_be_happening');
    }
    if (nextStepRaw is! Map<String, dynamic>) {
      throw const FormatException('Invalid next_step');
    }

    final nextStep = GuidanceNextStep.fromJson(nextStepRaw);

    final alternatives = <GuidanceAlternative>[];
    if (alternativesRaw != null) {
      for (final item in alternativesRaw) {
        if (item is Map<String, dynamic>) {
          try {
            alternatives.add(GuidanceAlternative.fromJson(item));
          } on FormatException {
            // Reject malformed alternatives individually? Spec says reject unknown actions.
            // For safety, if any alternative has disallowed action, throw.
            // We already throw inside fromJson for disallowed, so propagate.
            rethrow;
          }
        }
      }
      if (alternatives.length > 2) {
        // Keep at most 2 as per spec.
        alternatives.removeRange(2, alternatives.length);
      }
    }

    if (gentleQuestion != null &&
        gentleQuestion is! String) {
      throw const FormatException('Invalid gentle_question');
    }

    return GuidanceResponse(
      summary: summary.trim(),
      whatMightBeHappening: whatMight.trim(),
      nextStep: nextStep,
      alternatives: alternatives,
      gentleQuestion: gentleQuestion is String && gentleQuestion.trim().isNotEmpty
          ? gentleQuestion.trim()
          : null,
      whyItMightHelp: whyItMightHelp is String && whyItMightHelp.trim().isNotEmpty
          ? whyItMightHelp.trim()
          : null,
      isCrisis: isCrisis,
      crisisNote: crisisNote is String ? crisisNote : null,
      checkInContext: context,
    );
  }

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'what_might_be_happening': whatMightBeHappening,
        'next_step': nextStep.toJson(),
        'alternatives': alternatives.map((a) => a.toJson()).toList(),
        if (gentleQuestion != null) 'gentle_question': gentleQuestion,
        if (whyItMightHelp != null) 'why_it_might_help': whyItMightHelp,
        if (isCrisis) 'is_crisis': true,
      };

  /// Safe fallback when AI parsing fails. Uses allowed actions only.
  factory GuidanceResponse.fallback(CheckInContext ctx) {
    final feeling = ctx.feeling;
    final need = ctx.need;

    // Choose action based on need first, then feeling.
    String actionId;
    String title;
    String description;
    String why;

    switch (need) {
      case CheckInNeed.calmMind:
        actionId = GuidanceActionIds.breathing;
        title = 'Try a short calming reset';
        description =
            'Take a few slower breaths and notice what shifts, even a little.';
        why = 'A brief pause can give your body a moment to settle.';
        break;
      case CheckInNeed.understandFeeling:
        actionId = GuidanceActionIds.thoughtReframe;
        title = 'Unpack the thought gently';
        description =
            'Write down what happened, what you noticed, and one other way to see it.';
        why = 'Looking at a thought from another angle can make it feel less stuck.';
        break;
      case CheckInNeed.getOffChest:
        actionId = GuidanceActionIds.journalPrompt;
        title = 'Get it out of your head';
        description =
            'Write what is on your mind for a few minutes, without needing to fix it yet.';
        why = 'Putting feelings into words can create a little space.';
        break;
      case CheckInNeed.figureOut:
        actionId = GuidanceActionIds.smallPlan;
        title = 'Make the next few minutes smaller';
        description =
            'List what is competing for your attention, then pick one small thing for today.';
        why = 'One small doable step can be easier than solving everything at once.';
        break;
      case CheckInNeed.connectSomeone:
        actionId = GuidanceActionIds.trustedPersonPrompt;
        title = 'Reach out to someone you trust';
        description =
            'Consider sending a short message to a safe person about how you are feeling.';
        why = 'Connection can help when things feel heavy or lonely.';
        break;
    }

    // Adjust for feeling if needed.
    if (feeling == CheckInFeeling.lonelyOrDisconnected &&
        need != CheckInNeed.connectSomeone) {
      // Offer connection as alternative.
    }

    final whatMight = switch (feeling) {
      CheckInFeeling.overwhelmed =>
        'When a lot competes for your attention, it may feel harder to start. It makes sense that your mind might be trying to hold everything at once.',
      CheckInFeeling.lonelyOrDisconnected =>
        'Feeling disconnected can happen even around others. It may be that you are needing more of a sense of being seen or understood right now.',
      CheckInFeeling.anxiousOrWorried =>
        'When thoughts keep looping, your mind may be trying to prepare or protect you, even if the looping itself feels tiring.',
      CheckInFeeling.lowOrSad =>
        'Low or sad feelings may make energy and motivation feel lower. It makes sense that starting things might feel heavier right now.',
      CheckInFeeling.numbOrTired =>
        'Feeling numb or tired can be a sign your system has been carrying a lot. It may help to focus on one gentle, restful next step.',
      CheckInFeeling.frustratedOrAngry =>
        'Frustration or anger can show up when something feels blocked or unfair. It may make sense to want space before deciding what to do next.',
      CheckInFeeling.okayCheckIn =>
        'It sounds like you are checking in with curiosity. Noticing what is present may be a useful step on its own.',
    };

    final alternatives = <GuidanceAlternative>[];
    if (actionId != GuidanceActionIds.breathing) {
      alternatives.add(const GuidanceAlternative(
        title: 'Try a calming reset',
        actionId: GuidanceActionIds.breathing,
      ));
    }
    if (actionId != GuidanceActionIds.openChat && alternatives.length < 2) {
      alternatives.add(const GuidanceAlternative(
        title: 'Talk it through',
        actionId: GuidanceActionIds.openChat,
      ));
    }

    return GuidanceResponse(
      summary: 'Thanks for checking in - ${feeling.displayLabel.toLowerCase()} can be a lot to hold.',
      whatMightBeHappening: whatMight,
      nextStep: GuidanceNextStep(
        title: title,
        description: description,
        actionId: actionId,
        whyItMightHelp: why,
      ),
      alternatives: alternatives,
      gentleQuestion: 'Is there one small thing that would make the next hour a bit kinder?',
      checkInContext: ctx,
    );
  }
}
