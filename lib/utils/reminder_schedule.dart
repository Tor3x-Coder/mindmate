/// The three reminder windows already shown in onboarding and Settings.
///
/// These are deliberately approximate windows rather than a claim that a
/// person should check in at one exact moment. The scheduled notification uses
/// the device's local timezone.
class ReminderSlot {
  final int hour;
  final int minute;

  const ReminderSlot({required this.hour, required this.minute});
}

class ReminderSchedule {
  static const Map<String, ReminderSlot> slots = {
    'Morning': ReminderSlot(hour: 9, minute: 0),
    'Afternoon': ReminderSlot(hour: 15, minute: 0),
    'Evening': ReminderSlot(hour: 19, minute: 0),
  };

  static ReminderSlot? forWindow(String window) => slots[window];
}
