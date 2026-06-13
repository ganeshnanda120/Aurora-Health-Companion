import 'package:flutter/material.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../models/hydration.dart';
import '../models/sleep.dart';
import '../models/habit.dart';
import '../models/nutrition.dart';
import '../models/ai_message.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';

class HealthProvider extends ChangeNotifier {
  final StorageService _storage;
  final AiService _ai = AiService();
  final _uuid = const Uuid();

  // Authentication & Session state
  bool _isAuthenticated = false;
  String? _userEmail;
  bool _isOnboarded = false;

  // Health data state
  UserProfile? _profile;
  List<HydrationLog> _hydrationLogs = [];
  List<SleepLog> _sleepLogs = [];
  List<Habit> _habits = [];
  List<NutritionLog> _nutritionLogs = [];
  List<AiMessage> _messages = [];

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  bool get isOnboarded => _isOnboarded;
  UserProfile? get profile => _profile;
  List<HydrationLog> get hydrationLogs => _hydrationLogs;
  List<SleepLog> get sleepLogs => _sleepLogs;
  List<Habit> get habits => _habits;
  List<NutritionLog> get nutritionLogs => _nutritionLogs;
  List<AiMessage> get messages => _messages;

  HealthProvider(this._storage) {
    _loadFromStorage();
  }

  // Load state and load default demo data if new user
  void _loadFromStorage() {
    _userEmail = _storage.getLoggedInEmail();
    _isAuthenticated = _userEmail != null;
    _isOnboarded = _storage.isOnboarded();
    _profile = _storage.getUserProfile();
    _hydrationLogs = _storage.getHydrationLogs();
    _sleepLogs = _storage.getSleepLogs();
    _habits = _storage.getHabits();
    _nutritionLogs = _storage.getNutritionLogs();
    _messages = _storage.getAiMessages();

    // Do not generate mock/fake telemetry reports

    notifyListeners();
  }

  // Simulated authentication: Login
  Future<bool> login(String email, String password) async {
    // Demo credentials check
    if (email.trim().toLowerCase() == 'demo@aurora.com' && password == '123456') {
      _userEmail = email;
      _isAuthenticated = true;
      await _storage.saveLoggedInEmail(email);

      // Check if onboarded (simulated)
      _isOnboarded = _storage.isOnboarded();
      if (_isOnboarded) {
        _profile = _storage.getUserProfile();
      } else {
        _profile = null;
      }

      _loadFromStorage();
      return true;
    }
    return false;
  }

  // Simulated authentication: Signup
  Future<bool> signup(String name, String email, String password) async {
    if (email.isNotEmpty && password.length >= 6) {
      _userEmail = email;
      _isAuthenticated = true;
      await _storage.saveLoggedInEmail(email);
      _isOnboarded = false;
      
      // Seed profile name
      _profile = UserProfile(
        name: name,
        age: 25,
        gender: 'Other',
        height: 175,
        weight: 70,
        wakeUpTime: '07:00',
        bedTime: '23:00',
        activityLevel: 'Moderate',
        healthGoals: ['Improve Hydration', 'Sleep Better', 'Build Better Habits'],
        notificationPreferences: {
          'Hydration': true,
          'Sleep': true,
          'Habits': true,
          'Insights': true,
        },
      );
      await _storage.saveUserProfile(_profile!);
      _loadFromStorage();
      return true;
    }
    return false;
  }

  // Simulated authentication: Social Logins (Google, Apple)
  Future<void> socialLogin(String provider) async {
    _userEmail = 'demo_${provider.toLowerCase()}@aurora.com';
    _isAuthenticated = true;
    await _storage.saveLoggedInEmail(_userEmail!);
    
    // Check if onboarded (simulated)
    _isOnboarded = _storage.isOnboarded();
    if (_isOnboarded) {
      _profile = _storage.getUserProfile();
    } else {
      _profile = null;
    }
    
    _loadFromStorage();
  }

  // Logout
  Future<void> logout() async {
    await _storage.clearSession();
    _isAuthenticated = false;
    _userEmail = null;
    notifyListeners();
  }

  // Complete Onboarding Form
  Future<void> completeOnboarding(UserProfile userProfile) async {
    _profile = userProfile;
    _isOnboarded = true;
    await _storage.saveUserProfile(userProfile);
    await _storage.setOnboarded(true);
    
    // Do not generate mock/fake telemetry reports
    notifyListeners();
  }

  // Save changes to profile in settings
  Future<void> updateProfile(UserProfile userProfile) async {
    _profile = userProfile;
    await _storage.saveUserProfile(userProfile);
    notifyListeners();
  }

  // Reset all data
  Future<void> resetAllData() async {
    await _storage.resetAll();
    _isAuthenticated = false;
    _userEmail = null;
    _isOnboarded = false;
    _profile = null;
    _hydrationLogs = [];
    _sleepLogs = [];
    _habits = [];
    _nutritionLogs = [];
    _messages = [];
    notifyListeners();
  }

  // --- Hydration Methods ---
  Future<void> addHydration(int amountMl) async {
    final log = HydrationLog(
      id: _uuid.v4(),
      amountMl: amountMl,
      timestamp: DateTime.now(),
    );
    _hydrationLogs.add(log);
    await _storage.saveHydrationLogs(_hydrationLogs);
    notifyListeners();
  }

  Future<void> clearHydration() async {
    _hydrationLogs.clear();
    await _storage.saveHydrationLogs(_hydrationLogs);
    notifyListeners();
  }

  // --- Sleep Methods ---
  Future<void> logSleep(double durationHours, int qualityScore, {String notes = ''}) async {
    final log = SleepLog(
      id: _uuid.v4(),
      date: DateTime.now(),
      durationHours: durationHours,
      qualityScore: qualityScore,
      notes: notes,
    );
    _sleepLogs.add(log);
    await _storage.saveSleepLogs(_sleepLogs);
    notifyListeners();
  }

  // --- Habit Methods ---
  Future<void> addCustomHabit(String title, String category) async {
    final habit = Habit(
      id: _uuid.v4(),
      title: title,
      category: category,
      createdAt: DateTime.now(),
      history: {},
      streakCount: 0,
    );
    _habits.add(habit);
    await _storage.saveHabits(_habits);
    notifyListeners();
  }

  Future<void> toggleHabitStatus(String id, String dateStr, String state) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      final habit = _habits[index];
      final newHistory = Map<String, String>.from(habit.history);
      
      if (newHistory[dateStr] == state) {
        newHistory.remove(dateStr); // Deselect
      } else {
        newHistory[dateStr] = state; // 'completed', 'skipped', or 'paused'
      }

      // Re-calculate streak
      int streak = _calculateHabitStreak(newHistory);

      _habits[index] = habit.copyWith(
        history: newHistory,
        streakCount: streak,
      );

      await _storage.saveHabits(_habits);
      notifyListeners();
    }
  }

  int _calculateHabitStreak(Map<String, String> history) {
    int streak = 0;
    DateTime date = DateTime.now();
    
    while (true) {
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      if (history[dateStr] == 'completed') {
        streak++;
        date = date.subtract(const Duration(days: 1));
      } else if (history[dateStr] == 'paused' || history[dateStr] == 'skipped') {
        // Break days but don't break streak if they paused or skipped purposefully,
        // or break it. Let's say paused/skipped just skips the day without incrementing,
        // but if it's missing (no log), the streak ends.
        date = date.subtract(const Duration(days: 1));
      } else {
        // If yesterday was skipped/paused, it might still continue, but check if we're looking at today.
        // If today is empty, check yesterday.
        if (dateStr == "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}") {
          date = date.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }
    return streak;
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    await _storage.saveHabits(_habits);
    notifyListeners();
  }

  // --- Nutrition Methods ---
  Future<void> addNutrition(String mealType, String foodName, int calories, int protein, int carbs, int fat) async {
    final log = NutritionLog(
      id: _uuid.v4(),
      mealType: mealType,
      foodName: foodName,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      timestamp: DateTime.now(),
    );
    _nutritionLogs.add(log);
    await _storage.saveNutritionLogs(_nutritionLogs);
    notifyListeners();
  }

  Future<void> deleteNutrition(String id) async {
    _nutritionLogs.removeWhere((n) => n.id == id);
    await _storage.saveNutritionLogs(_nutritionLogs);
    notifyListeners();
  }

  // --- AI Companion Methods ---
  Future<void> sendMessage(String text, {bool isVoice = false}) async {
    if (text.trim().isEmpty) return;

    final userMsg = AiMessage(
      id: _uuid.v4(),
      text: text,
      sender: "user",
      timestamp: DateTime.now(),
      isVoice: isVoice,
    );
    _messages.add(userMsg);
    notifyListeners();

    // 1. Process action in local command parser
    final result = _ai.parseCommand(text);

    // 2. Perform state updates if action matches
    if (result.action == AiAction.addHydration) {
      await addHydration(result.value as int);
    } else if (result.action == AiAction.addSleep) {
      await logSleep(result.value as double, 80, notes: "Logged via AI Voice Companion");
    } else if (result.action == AiAction.createHabit) {
      await addCustomHabit(result.value as String, "Routine");
    }

    // 3. Resolve dynamic responses based on current provider variables
    var replyText = result.response;
    if (replyText.contains("[dynamic_")) {
      replyText = _ai.generateDynamicResponse(
        queryAction: result.action,
        hydration: _hydrationLogs,
        sleep: _sleepLogs,
        habits: _habits,
        nutrition: _nutritionLogs,
      );
    }

    final auroraMsg = AiMessage(
      id: _uuid.v4(),
      text: replyText,
      sender: "aurora",
      timestamp: DateTime.now(),
      isVoice: isVoice,
    );
    
    _messages.add(auroraMsg);
    await _storage.saveAiMessages(_messages);
    notifyListeners();

    // 4. Trigger voice synthesis if it's voice-to-voice mode
    if (isVoice) {
      await _ai.speak(replyText);
    }
  }

  Future<void> clearMessages() async {
    _messages.clear();
    await _storage.saveAiMessages(_messages);
    notifyListeners();
  }

  // --- Dynamic Insights ---
  String getTodayInsight() {
    if (_sleepLogs.isEmpty && _hydrationLogs.isEmpty && _habits.isEmpty) {
      return "Welcome to Aurora! Start logging hydration, habits, or sleep to receive customized daily insights.";
    }

    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    // Water math
    final waterToday = _hydrationLogs
        .where((e) => e.timestamp.year == today.year && e.timestamp.month == today.month && e.timestamp.day == today.day)
        .fold(0, (sum, item) => sum + item.amountMl);

    // Sleep math
    final avgSleep = _sleepLogs.isEmpty
        ? 7.5
        : _sleepLogs.fold(0.0, (sum, item) => sum + item.durationHours) / _sleepLogs.length;
    final lastSleep = _sleepLogs.isEmpty ? 0.0 : _sleepLogs.last.durationHours;

    if (lastSleep > 0 && lastSleep < (avgSleep - 0.75)) {
      return "You slept ${lastSleep.toStringAsFixed(1)} hours, which is shorter than your average (${avgSleep.toStringAsFixed(1)}h). Prioritize hydration and take deep breaths today.";
    }

    if (waterToday < 1000) {
      return "Hydration is running low today (${waterToday}ml logged). Drinking water will improve your focus and energy levels.";
    }

    final pendingHabits = _habits.where((h) => h.isActive && h.history[todayStr] != 'completed').length;
    if (pendingHabits > 0) {
      return "You have $pendingHabits habits left to complete today. Focus on consistency to build lasting routines!";
    }

    return "Fantastic job! You've accomplished your primary goals. Keep maintaining this solid routine.";
  }

  // Streaks Calculator
  Map<String, int> getStreaks() {
    int hydrationStreak = 0;
    int sleepStreak = 0;
    int habitStreak = _habits.fold(0, (maxS, h) => h.streakCount > maxS ? h.streakCount : maxS);
    int nutritionStreak = 0;

    final today = DateTime.now();

    // Hydration Streak: Check how many consecutive days user met 1500ml water
    DateTime checkDate = today;
    while (true) {
      final dateLogs = _hydrationLogs.where((e) =>
        e.timestamp.year == checkDate.year &&
        e.timestamp.month == checkDate.month &&
        e.timestamp.day == checkDate.day
      );
      final sum = dateLogs.fold(0, (s, e) => s + e.amountMl);
      if (sum >= 1500) {
        hydrationStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        if (checkDate == today) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue; // Allow today to be incomplete
        }
        break;
      }
    }

    // Sleep Streak: Days in a row logging sleep
    checkDate = today;
    while (true) {
      final hasLog = _sleepLogs.any((e) =>
        e.date.year == checkDate.year &&
        e.date.month == checkDate.month &&
        e.date.day == checkDate.day
      );
      if (hasLog) {
        sleepStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        if (checkDate == today) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue; // Allow today to be incomplete
        }
        break;
      }
    }

    // Nutrition Streak: Days in a row logging meals
    checkDate = today;
    while (true) {
      final hasLog = _nutritionLogs.any((e) =>
        e.timestamp.year == checkDate.year &&
        e.timestamp.month == checkDate.month &&
        e.timestamp.day == checkDate.day
      );
      if (hasLog) {
        nutritionStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        if (checkDate == today) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue; // Allow today to be incomplete
        }
        break;
      }
    }

    return {
      'hydration': hydrationStreak,
      'sleep': sleepStreak,
      'habit': habitStreak,
      'nutrition': nutritionStreak,
      'longest': [hydrationStreak, sleepStreak, habitStreak, nutritionStreak].reduce((a, b) => a > b ? a : b),
    };
  }

  // Health Memory Insights (Aurora remembers patterns)
  List<String> getMemoryInsights() {
    List<String> insights = [];

    // Pattern 1: Hydration issues
    int lowWaterDays = 0;
    for (int i = 1; i <= 7; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final sum = _hydrationLogs
          .where((e) => e.timestamp.year == date.year && e.timestamp.month == date.month && e.timestamp.day == date.day)
          .fold(0, (s, e) => s + e.amountMl);
      if (sum < 1000) lowWaterDays++;
    }
    if (lowWaterDays >= 4) {
      insights.add("Aurora noticed you missed your hydration goal on $lowWaterDays days this past week. Setting small morning water targets can help.");
    }

    // Pattern 2: Sleep patterns
    double weekendSleep = 0;
    int weekendCount = 0;
    double weekdaySleep = 0;
    int weekdayCount = 0;
    for (var log in _sleepLogs) {
      if (log.date.weekday == DateTime.saturday || log.date.weekday == DateTime.sunday) {
        weekendSleep += log.durationHours;
        weekendCount++;
      } else {
        weekdaySleep += log.durationHours;
        weekdayCount++;
      }
    }
    if (weekendCount > 0 && weekdayCount > 0) {
      double avgWeekend = weekendSleep / weekendCount;
      double avgWeekday = weekdaySleep / weekdayCount;
      if (avgWeekend > avgWeekday + 1.5) {
        insights.add("You sleep about ${(avgWeekend - avgWeekday).toStringAsFixed(1)} hours longer on weekends. Try balancing weekday sleep to maintain circadian consistency.");
      }
    }

    // Pattern 3: Habit patterns
    if (_habits.isNotEmpty) {
      int completedStreakMax = _habits.fold(0, (m, h) => h.streakCount > m ? h.streakCount : m);
      if (completedStreakMax >= 5) {
        insights.add("You have maintained a habit consistency streak of $completedStreakMax days. Excellent focus!");
      }
    }

    if (insights.isEmpty) {
      insights.add("Your data logs look balanced. Keep tracking hydration and sleep to unlock behavioral insights.");
    }

    return insights;
  }
}
