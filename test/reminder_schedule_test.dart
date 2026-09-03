import 'package:flutter_test/flutter_test.dart';
import 'package:mindmate/utils/reminder_schedule.dart';

void main() {
  test('maps the existing reminder windows to gentle local times', () {
    expect(ReminderSchedule.forWindow('Morning')?.hour, 9);
    expect(ReminderSchedule.forWindow('Afternoon')?.hour, 15);
    expect(ReminderSchedule.forWindow('Evening')?.hour, 19);
    expect(ReminderSchedule.forWindow('Not a window'), isNull);
  });

  test('exposes only the three existing windows', () {
    expect(
      ReminderSchedule.slots.keys,
      containsAllInOrder(['Morning', 'Afternoon', 'Evening']),
    );
    expect(ReminderSchedule.slots, hasLength(3));
  });
}
