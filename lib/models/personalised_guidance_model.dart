/// The short, non-clinical context a person chooses before asking MindMate
/// for one safe next step. It deliberately contains no scores or diagnoses.
class ContextualCheckIn {
  static const int maxContextCharacters = 500;

  final String feeling;
  final String impact;
  final String need;
  final String context;

  const ContextualCheckIn({
    required this.feeling,
    required this.impact,
    required this.need,
    this.context = '',
  });

  Map<String, String> toJson() => {
        'feeling': feeling,
        'impact': impact,
        'need': need,
        if (context.trim().isNotEmpty) 'context': context.trim(),
      };

  bool get hasOptionalContext => context.trim().isNotEmpty;
}

class GuidanceAction {
  static const String breathing = 'breathing';
  static const String meditation = 'meditation';
  static const String journalPrompt = 'journal_prompt';
  static const String thoughtReframe = 'thought_reframe';
  static const String smallPlan = 'small_plan';
  static const String openLearn = 'open_learn';
  static const String openChat = 'open_chat';
  static const String trustedPersonPrompt = 'trusted_person_prompt';
  static const String openEmergencySupport = 'open_emergency_support';

  static const Set<String> allowedActionIds = {
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

  final String title;
  final String description;
  final String actionId;

  const GuidanceAction({
    required this.title,
    required this.description,
    required this.actionId,
  });

  factory GuidanceAction.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('The guidance action was not an object.');
    }

    final title = _requiredText(value['title'], 'guidance action title');
    final description =
        _requiredText(value['description'], 'guidance action description');
    final actionId = _requiredText(value['action_id'], 'guidance action id');

    if (!allowedActionIds.contains(actionId)) {
      throw FormatException('Unknown guidance action: $actionId');
    }

    return GuidanceAction(
      title: title,
      description: description,
      actionId: actionId,
    );
  }
}

class PersonalisedGuidanceResponse {
  final String acknowledgement;
  final String whatMightBeHappening;
  final GuidanceAction nextStep;
  final String whyItMayHelp;
  final List<GuidanceAction> alternatives;
  final String? question;

  const PersonalisedGuidanceResponse({
    required this.acknowledgement,
    required this.whatMightBeHappening,
    required this.nextStep,
    required this.whyItMayHelp,
    required this.alternatives,
    this.question,
  });

  factory PersonalisedGuidanceResponse.fromJson(Map<String, dynamic> json) {
    final rawAlternatives = json['alternatives'];
    if (rawAlternatives is! List) {
      throw const FormatException('Guidance alternatives were not a list.');
    }

    final alternatives = rawAlternatives
        .map(GuidanceAction.fromJson)
        .take(2)
        .toList(growable: false);

    final rawQuestion = json['question'];
    if (rawQuestion != null && rawQuestion is! String) {
      throw const FormatException('Guidance question was not text.');
    }

    final question = rawQuestion is String && rawQuestion.trim().isNotEmpty
        ? rawQuestion.trim()
        : null;

    return PersonalisedGuidanceResponse(
      acknowledgement:
          _requiredText(json['acknowledgement'], 'acknowledgement'),
      whatMightBeHappening: _requiredText(
        json['what_might_be_happening'],
        'what might be happening',
      ),
      nextStep: GuidanceAction.fromJson(json['next_step']),
      whyItMayHelp: _requiredText(json['why_it_may_help'], 'why it may help'),
      alternatives: alternatives,
      question: question,
    );
  }
}

String _requiredText(Object? value, String field) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing guidance $field.');
  }
  return value.trim();
}
