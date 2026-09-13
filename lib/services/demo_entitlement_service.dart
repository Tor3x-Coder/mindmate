import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local-only demo entitlement for simulated structured programmes.
/// No payment provider, no bank details, no real charge.
/// Competition demo only — clearly labelled in UI.
class DemoEntitlementService {
  static const String _keyEntitlements = 'mindmate_demo_entitlements_v1';
  static const String _keyProgress = 'mindmate_demo_progress_v1';

  /// Returns set of unlocked programme IDs
  Future<Set<String>> getUnlockedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyEntitlements);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<String>().toSet();
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<bool> isUnlocked(String programmeId) async {
    final ids = await getUnlockedIds();
    return ids.contains(programmeId);
  }

  Future<void> unlock(String programmeId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getUnlockedIds();
    ids.add(programmeId);
    await prefs.setString(_keyEntitlements, jsonEncode(ids.toList()));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEntitlements);
    await prefs.remove(_keyProgress);
  }

  // Progress: programmeId -> set of completed day numbers
  Future<Map<String, Set<int>>> getProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyProgress);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final result = <String, Set<int>>{};
      decoded.forEach((k, v) {
        if (k is String && v is List) {
          result[k] = v.whereType<int>().toSet();
        }
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  Future<Set<int>> getCompletedDays(String programmeId) async {
    final progress = await getProgress();
    return progress[programmeId] ?? {};
  }

  Future<void> markDayComplete(String programmeId, int dayNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final progress = await getProgress();
    final completed = progress[programmeId] ?? <int>{};
    completed.add(dayNumber);
    progress[programmeId] = completed;
    final toSave = progress.map((k, v) => MapEntry(k, v.toList()));
    await prefs.setString(_keyProgress, jsonEncode(toSave));
  }

  Future<void> markDayIncomplete(String programmeId, int dayNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final progress = await getProgress();
    final completed = progress[programmeId] ?? <int>{};
    completed.remove(dayNumber);
    progress[programmeId] = completed;
    final toSave = progress.map((k, v) => MapEntry(k, v.toList()));
    await prefs.setString(_keyProgress, jsonEncode(toSave));
  }
}
