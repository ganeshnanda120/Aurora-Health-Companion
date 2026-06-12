import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/hydration.dart';
import '../models/sleep.dart';
import '../models/habit.dart';
import '../models/nutrition.dart';
import '../models/ai_message.dart';

class StorageService {
  static const String keyUserEmail = 'user_email';
  static const String keyIsOnboarded = 'is_onboarded';
  static const String keyProfile = 'user_profile';
  static const String keyHydration = 'hydration_logs';
  static const String keySleep = 'sleep_logs';
  static const String keyHabits = 'habits';
  static const String keyNutrition = 'nutrition_logs';
  static const String keyMessages = 'ai_messages';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Auth Session ---
  String? getLoggedInEmail() {
    return _prefs.getString(keyUserEmail);
  }

  Future<void> saveLoggedInEmail(String email) async {
    await _prefs.setString(keyUserEmail, email);
  }

  Future<void> clearSession() async {
    await _prefs.remove(keyUserEmail);
    // Note: We might want to keep onboarding/health data for demo purposes, 
    // but clearing session logs the user out.
  }

  // --- Onboarding Status ---
  bool isOnboarded() {
    return _prefs.getBool(keyIsOnboarded) ?? false;
  }

  Future<void> setOnboarded(bool value) async {
    await _prefs.setBool(keyIsOnboarded, value);
  }

  // --- User Profile ---
  UserProfile? getUserProfile() {
    final raw = _prefs.getString(keyProfile);
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw));
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _prefs.setString(keyProfile, jsonEncode(profile.toJson()));
  }

  // --- Hydration Logs ---
  List<HydrationLog> getHydrationLogs() {
    final rawList = _prefs.getStringList(keyHydration);
    if (rawList == null) return [];
    return rawList.map((e) {
      try {
        return HydrationLog.fromJson(jsonDecode(e));
      } catch (err) {
        return null;
      }
    }).whereType<HydrationLog>().toList();
  }

  Future<void> saveHydrationLogs(List<HydrationLog> logs) async {
    final rawList = logs.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(keyHydration, rawList);
  }

  // --- Sleep Logs ---
  List<SleepLog> getSleepLogs() {
    final rawList = _prefs.getStringList(keySleep);
    if (rawList == null) return [];
    return rawList.map((e) {
      try {
        return SleepLog.fromJson(jsonDecode(e));
      } catch (err) {
        return null;
      }
    }).whereType<SleepLog>().toList();
  }

  Future<void> saveSleepLogs(List<SleepLog> logs) async {
    final rawList = logs.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(keySleep, rawList);
  }

  // --- Habits ---
  List<Habit> getHabits() {
    final rawList = _prefs.getStringList(keyHabits);
    if (rawList == null) return [];
    return rawList.map((e) {
      try {
        return Habit.fromJson(jsonDecode(e));
      } catch (err) {
        return null;
      }
    }).whereType<Habit>().toList();
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final rawList = habits.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(keyHabits, rawList);
  }

  // --- Nutrition Logs ---
  List<NutritionLog> getNutritionLogs() {
    final rawList = _prefs.getStringList(keyNutrition);
    if (rawList == null) return [];
    return rawList.map((e) {
      try {
        return NutritionLog.fromJson(jsonDecode(e));
      } catch (err) {
        return null;
      }
    }).whereType<NutritionLog>().toList();
  }

  Future<void> saveNutritionLogs(List<NutritionLog> logs) async {
    final rawList = logs.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(keyNutrition, rawList);
  }

  // --- AI Chat Messages ---
  List<AiMessage> getAiMessages() {
    final rawList = _prefs.getStringList(keyMessages);
    if (rawList == null) return [];
    return rawList.map((e) {
      try {
        return AiMessage.fromJson(jsonDecode(e));
      } catch (err) {
        return null;
      }
    }).whereType<AiMessage>().toList();
  }

  Future<void> saveAiMessages(List<AiMessage> messages) async {
    final rawList = messages.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(keyMessages, rawList);
  }

  // --- Reset All Data ---
  Future<void> resetAll() async {
    await _prefs.clear();
  }
}
