/// Contextual check-in model for the AI-powered One Safe Step.
///
/// This model captures the three structured questions plus an optional
/// bounded free-text context. It is deliberately small and non-clinical.
enum CheckInFeeling {
  lowOrSad,
  anxiousOrWorried,
  overwhelmed,
  lonelyOrDisconnected,
  frustratedOrAngry,
  numbOrTired,
  okayCheckIn,
}

enum CheckInEnergySource {
  schoolOrWork,
  relationshipsOrFamily,
  money,
  sleepOrBody,
  myThoughts,
  somethingElse,
  notSure,
}

enum CheckInNeed {
  calmMind,
  understandFeeling,
  getOffChest,
  figureOut,
  connectSomeone,
}

extension CheckInFeelingX on CheckInFeeling {
  String get wireValue {
    switch (this) {
      case CheckInFeeling.lowOrSad:
        return 'low_or_sad';
      case CheckInFeeling.anxiousOrWorried:
        return 'anxious_or_worried';
      case CheckInFeeling.overwhelmed:
        return 'overwhelmed';
      case CheckInFeeling.lonelyOrDisconnected:
        return 'lonely_or_disconnected';
      case CheckInFeeling.frustratedOrAngry:
        return 'frustrated_or_angry';
      case CheckInFeeling.numbOrTired:
        return 'numb_or_tired';
      case CheckInFeeling.okayCheckIn:
        return 'okay_checkin';
    }
  }

  String get displayLabel {
    switch (this) {
      case CheckInFeeling.lowOrSad:
        return 'Low or sad';
      case CheckInFeeling.anxiousOrWorried:
        return 'Anxious or worried';
      case CheckInFeeling.overwhelmed:
        return 'Overwhelmed';
      case CheckInFeeling.lonelyOrDisconnected:
        return 'Lonely or disconnected';
      case CheckInFeeling.frustratedOrAngry:
        return 'Frustrated or angry';
      case CheckInFeeling.numbOrTired:
        return 'Numb or tired';
      case CheckInFeeling.okayCheckIn:
        return 'Okay, but I want to check in';
    }
  }

  String get emoji {
    switch (this) {
      case CheckInFeeling.lowOrSad:
        return '😔';
      case CheckInFeeling.anxiousOrWorried:
        return '😟';
      case CheckInFeeling.overwhelmed:
        return '😣';
      case CheckInFeeling.lonelyOrDisconnected:
        return '🥺';
      case CheckInFeeling.frustratedOrAngry:
        return '😤';
      case CheckInFeeling.numbOrTired:
        return '😴';
      case CheckInFeeling.okayCheckIn:
        return '🙂';
    }
  }

  /// Maps the feeling to a high-level situation for Learn recommendations
  /// and fallback routing. This is not a diagnosis.
  String get situationHint {
    switch (this) {
      case CheckInFeeling.overwhelmed:
        return 'overwhelmed';
      case CheckInFeeling.lonelyOrDisconnected:
        return 'lonely_or_disconnected';
      case CheckInFeeling.anxiousOrWorried:
        return 'overthinking';
      case CheckInFeeling.lowOrSad:
      case CheckInFeeling.numbOrTired:
        return 'low_motivation';
      case CheckInFeeling.frustratedOrAngry:
        return 'overwhelmed';
      case CheckInFeeling.okayCheckIn:
        return 'okay';
    }
  }

  static CheckInFeeling? fromWire(String? value) {
    switch (value) {
      case 'low_or_sad':
        return CheckInFeeling.lowOrSad;
      case 'anxious_or_worried':
        return CheckInFeeling.anxiousOrWorried;
      case 'overwhelmed':
        return CheckInFeeling.overwhelmed;
      case 'lonely_or_disconnected':
        return CheckInFeeling.lonelyOrDisconnected;
      case 'frustrated_or_angry':
        return CheckInFeeling.frustratedOrAngry;
      case 'numb_or_tired':
        return CheckInFeeling.numbOrTired;
      case 'okay_checkin':
        return CheckInFeeling.okayCheckIn;
      default:
        return null;
    }
  }
}

extension CheckInEnergySourceX on CheckInEnergySource {
  String get wireValue {
    switch (this) {
      case CheckInEnergySource.schoolOrWork:
        return 'school_or_work';
      case CheckInEnergySource.relationshipsOrFamily:
        return 'relationships_or_family';
      case CheckInEnergySource.money:
        return 'money';
      case CheckInEnergySource.sleepOrBody:
        return 'sleep_or_body';
      case CheckInEnergySource.myThoughts:
        return 'my_thoughts';
      case CheckInEnergySource.somethingElse:
        return 'something_else';
      case CheckInEnergySource.notSure:
        return 'not_sure';
    }
  }

  String get displayLabel {
    switch (this) {
      case CheckInEnergySource.schoolOrWork:
        return 'School or work';
      case CheckInEnergySource.relationshipsOrFamily:
        return 'Relationships or family';
      case CheckInEnergySource.money:
        return 'Money';
      case CheckInEnergySource.sleepOrBody:
        return 'Sleep or my body';
      case CheckInEnergySource.myThoughts:
        return 'My thoughts';
      case CheckInEnergySource.somethingElse:
        return 'Something else';
      case CheckInEnergySource.notSure:
        return 'I am not sure';
    }
  }

  static CheckInEnergySource? fromWire(String? value) {
    switch (value) {
      case 'school_or_work':
        return CheckInEnergySource.schoolOrWork;
      case 'relationships_or_family':
        return CheckInEnergySource.relationshipsOrFamily;
      case 'money':
        return CheckInEnergySource.money;
      case 'sleep_or_body':
        return CheckInEnergySource.sleepOrBody;
      case 'my_thoughts':
        return CheckInEnergySource.myThoughts;
      case 'something_else':
        return CheckInEnergySource.somethingElse;
      case 'not_sure':
        return CheckInEnergySource.notSure;
      default:
        return null;
    }
  }
}

extension CheckInNeedX on CheckInNeed {
  String get wireValue {
    switch (this) {
      case CheckInNeed.calmMind:
        return 'calm_mind';
      case CheckInNeed.understandFeeling:
        return 'understand_feeling';
      case CheckInNeed.getOffChest:
        return 'get_off_chest';
      case CheckInNeed.figureOut:
        return 'figure_out';
      case CheckInNeed.connectSomeone:
        return 'connect_someone';
    }
  }

  String get displayLabel {
    switch (this) {
      case CheckInNeed.calmMind:
        return 'Calm my mind';
      case CheckInNeed.understandFeeling:
        return 'Understand what I am feeling';
      case CheckInNeed.getOffChest:
        return 'Get something off my chest';
      case CheckInNeed.figureOut:
        return 'Figure out what to do';
      case CheckInNeed.connectSomeone:
        return 'Connect with someone';
    }
  }

  static CheckInNeed? fromWire(String? value) {
    switch (value) {
      case 'calm_mind':
        return CheckInNeed.calmMind;
      case 'understand_feeling':
        return CheckInNeed.understandFeeling;
      case 'get_off_chest':
        return CheckInNeed.getOffChest;
      case 'figure_out':
        return CheckInNeed.figureOut;
      case 'connect_someone':
        return CheckInNeed.connectSomeone;
      default:
        return null;
    }
  }
}

class CheckInContext {
  static const int maxFreeTextChars = 500;

  final CheckInFeeling feeling;
  final CheckInEnergySource energySource;
  final CheckInNeed need;
  final String freeText; // bounded, optional

  const CheckInContext({
    required this.feeling,
    required this.energySource,
    required this.need,
    this.freeText = '',
  });

  String get boundedFreeText {
    final trimmed = freeText.trim();
    if (trimmed.length <= maxFreeTextChars) return trimmed;
    return trimmed.substring(0, maxFreeTextChars);
  }

  bool get hasFreeText => boundedFreeText.isNotEmpty;

  /// Human-readable summary for local UI, not sent as diagnosis.
  String get summaryForDisplay {
    final parts = <String>[
      feeling.displayLabel,
      'Energy: ${energySource.displayLabel}',
      'Need: ${need.displayLabel}',
    ];
    if (hasFreeText) parts.add('Note: $boundedFreeText');
    return parts.join(' • ');
  }

  Map<String, dynamic> toJson() {
    return {
      'feeling': feeling.wireValue,
      'energySource': energySource.wireValue,
      'need': need.wireValue,
      if (boundedFreeText.isNotEmpty) 'freeText': boundedFreeText,
      'situationHint': feeling.situationHint,
    };
  }

  factory CheckInContext.fromJson(Map<String, dynamic> json) {
    final feeling = CheckInFeelingX.fromWire(json['feeling'] as String?);
    final energy = CheckInEnergySourceX.fromWire(json['energySource'] as String?);
    final need = CheckInNeedX.fromWire(json['need'] as String?);

    if (feeling == null || energy == null || need == null) {
      throw const FormatException('Invalid check-in context');
    }

    final rawFree = json['freeText'];
    final freeText = rawFree is String ? rawFree : '';

    return CheckInContext(
      feeling: feeling,
      energySource: energy,
      need: need,
      freeText: freeText,
    );
  }
}
