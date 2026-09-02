import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../utils/reminder_schedule.dart';

/// Owns the optional local daily check-in reminder.
///
/// Notifications are scheduled on the device only. This service does not use
/// Firestore and quietly becomes unavailable on web, where this app cannot
/// deliver an OS notification.
class ReminderService {
  static const int dailyReminderId = 4101;
  static const int testReminderId = 4102;
  static const String _channelId = 'mindmate_daily_check_in';
  static const String _channelName = 'Daily check-ins';
  static const String _channelDescription =
      'Gentle reminders to pause and notice how you are doing.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  late final Future<void> _initialization;
  bool _isReady = false;

  ReminderService() {
    _initialization = _initialize();
  }

  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _initialize() async {
    if (!isSupported) return;

    try {
      tz_data.initializeTimeZones();
      await _setDeviceTimezone();

      final initialized = await _plugin.initialize(
        settings: InitializationSettings(
          android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      if (initialized != true) return;

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.defaultImportance,
        ),
      );
      _isReady = true;
    } catch (_) {
      // Notifications are helpful but must never stop MindMate from opening.
      _isReady = false;
    }
  }

  Future<void> _setDeviceTimezone() async {
    try {
      final deviceTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceTimezone.identifier));
    } catch (_) {
      // The competition app is Nigeria-first. This keeps the reminder in the
      // expected local evening window if a platform cannot report its IANA
      // timezone; the normal path uses the actual device timezone above.
      tz.setLocalLocation(tz.getLocation('Africa/Lagos'));
    }
  }

  Future<bool> requestPermissions() async {
    await _initialization;
    if (!_isReady) return false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? true;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(
            alert: true,
            badge: false,
            sound: true,
          ) ??
          false;
    }

    return false;
  }

  Future<bool> scheduleDaily(
    String window, {
    bool requestPermission = false,
  }) async {
    try {
      await _initialization;
      if (!_isReady) return false;

      final slot = ReminderSchedule.forWindow(window);
      if (slot == null) {
        await cancelDaily();
        return false;
      }

      if (requestPermission && !await requestPermissions()) {
        await cancelDaily();
        return false;
      }

      final now = tz.TZDateTime.now(tz.local);
      var next = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        slot.hour,
        slot.minute,
      );
      if (!next.isAfter(now)) {
        next = next.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id: dailyReminderId,
        title: 'A small check-in for you',
        body: 'Take a calm minute to notice how you are doing.',
        scheduledDate: next,
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_check_in',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> showTestNotification() async {
    try {
      await _initialization;
      if (!_isReady) return false;
      if (!await requestPermissions()) return false;

      await _plugin.show(
        id: testReminderId,
        title: 'MindMate reminder test',
        body: 'Notifications are ready for your daily check-in.',
        notificationDetails: _notificationDetails,
        payload: 'test_check_in',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> cancelDaily() async {
    try {
      await _initialization;
      if (!_isReady) return;
      await _plugin.cancel(id: dailyReminderId);
    } catch (_) {
      // A notification cleanup failure must not block logout or deletion.
    }
  }

  Future<void> cancelTestNotification() async {
    try {
      await _initialization;
      if (!_isReady) return;
      await _plugin.cancel(id: testReminderId);
    } catch (_) {
      // A notification cleanup failure must not block logout or deletion.
    }
  }

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    ),
  );
}
