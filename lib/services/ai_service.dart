import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/hydration.dart';
import '../models/sleep.dart';
import '../models/habit.dart';
import '../models/nutrition.dart';

class AiService {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  bool _isTtsEnabled = false;

  AiService() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.windows)) {
        await _tts.setLanguage("en-US");
        await _tts.setSpeechRate(0.5);
        await _tts.setVolume(1.0);
        await _tts.setPitch(1.0);
        _isTtsEnabled = true;
      }
    } catch (e) {
      debugPrint("TTS initialization failed (likely simulator/unsupported): $e");
      _isTtsEnabled = false;
    }
  }

  // Speak text output
  Future<void> speak(String text) async {
    if (!_isTtsEnabled) {
      debugPrint("TTS Simulated speaking: $text");
      return;
    }
    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint("TTS speaking failed: $e");
    }
  }

  Future<void> stopSpeaking() async {
    if (_isTtsEnabled) {
      await _tts.stop();
    }
  }

  // Parse natural language commands and return instructions
  AiParseResult parseCommand(String text) {
    final cleanText = text.toLowerCase().trim();

    // 1. Hydration commands: "I drank 500ml water", "add 300ml water", "drank 250ml"
    final waterReg = RegExp(r'(?:drank|drink|added|add|intake)\s*(\d+)\s*(?:ml|milliliters|ounces|oz)?');
    if (waterReg.hasMatch(cleanText)) {
      final match = waterReg.firstMatch(cleanText);
      final amount = int.tryParse(match?.group(1) ?? '250') ?? 250;
      return AiParseResult(
        action: AiAction.addHydration,
        value: amount,
        response: "Awesome! I've added $amount ml to today's hydration progress. Let's keep drinking water!",
      );
    }
    if (cleanText.contains("water") && RegExp(r'\d+').hasMatch(cleanText)) {
      final numReg = RegExp(r'\d+');
      final amount = int.tryParse(numReg.firstMatch(cleanText)?.group(0) ?? '250') ?? 250;
      return AiParseResult(
        action: AiAction.addHydration,
        value: amount,
        response: "Splendid! I've registered $amount ml of water for you.",
      );
    }

    // 2. Sleep commands: "I slept 7 hours last night", "slept 8.5 hours", "logged 6 hours sleep"
    final sleepReg = RegExp(r'(?:slept|sleep|hours|duration)\s*(\d+(?:\.\d+)?)\s*(?:hours|hour|hrs|h)?');
    if (sleepReg.hasMatch(cleanText)) {
      final match = sleepReg.firstMatch(cleanText);
      final duration = double.tryParse(match?.group(1) ?? '8') ?? 8.0;
      return AiParseResult(
        action: AiAction.addSleep,
        value: duration,
        response: "Got it. I've updated your sleep log with $duration hours. Sleep is crucial for recovery!",
      );
    }

    // 3. Habit commands: "Create a habit to meditate every morning", "add habit to read", "create habit walking"
    final habitReg = RegExp(r'(?:create|add|new)\s*habit\s*(?:to)?\s*([a-zA-Z\s]+)');
    if (habitReg.hasMatch(cleanText)) {
      final match = habitReg.firstMatch(cleanText);
      var habitTitle = match?.group(1)?.replaceAll(RegExp(r'(every morning|every day|daily|morning|night|evening)'), '').trim() ?? 'Exercise';
      if (habitTitle.isEmpty) habitTitle = 'New Habit';
      
      // Capitalize first letters
      habitTitle = habitTitle.split(' ').map((word) {
        if (word.isEmpty) return '';
        return word[0].toUpperCase() + word.substring(1);
      }).join(' ');

      return AiParseResult(
        action: AiAction.createHabit,
        value: habitTitle,
        response: "Done! I've created the habit to '$habitTitle' for you. Consistency is key!",
      );
    }

    // Default responses to queries
    if (cleanText.contains("how am i doing") || cleanText.contains("summary") || cleanText.contains("progress")) {
      return AiParseResult(
        action: AiAction.queryStatus,
        value: null,
        response: "[dynamic_summary]",
      );
    }

    if (cleanText.contains("water") || cleanText.contains("hydrate") || cleanText.contains("drink")) {
      return AiParseResult(
        action: AiAction.queryHydration,
        value: null,
        response: "[dynamic_hydration]",
      );
    }

    if (cleanText.contains("sleep") || cleanText.contains("rest") || cleanText.contains("bedtime")) {
      return AiParseResult(
        action: AiAction.querySleep,
        value: null,
        response: "[dynamic_sleep]",
      );
    }

    if (cleanText.contains("habit") || cleanText.contains("routine") || cleanText.contains("todo")) {
      return AiParseResult(
        action: AiAction.queryHabits,
        value: null,
        response: "[dynamic_habits]",
      );
    }

    // Fallback general guidance conversational queries
    if (cleanText.contains("hello") || cleanText.contains("hi") || cleanText.contains("hey")) {
      return AiParseResult(
        action: AiAction.none,
        value: null,
        response: "Hello! I am Aurora, your personal AI health companion. How can I help you improve your wellness today?",
      );
    }

    if (cleanText.contains("thank") || cleanText.contains("awesome") || cleanText.contains("cool") || cleanText.contains("great")) {
      return AiParseResult(
        action: AiAction.none,
        value: null,
        response: "You're very welcome! I'm here to support you in building a healthier, happier lifestyle.",
      );
    }

    // Default general response
    return AiParseResult(
      action: AiAction.none,
      value: null,
      response: "I'm keeping track of your health habits. You can log water (e.g., 'I drank 500ml'), log sleep ('I slept 8 hours'), create habits ('create habit to Meditate'), or ask me 'How am I doing today?'",
    );
  }

  // Generates dynamic response based on active states in HealthProvider
  String generateDynamicResponse({
    required AiAction queryAction,
    required List<HydrationLog> hydration,
    required List<SleepLog> sleep,
    required List<Habit> habits,
    required List<NutritionLog> nutrition,
    int dailyWaterGoal = 2000,
  }) {
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    // Hydration calc
    final todayWater = hydration
        .where((e) => e.timestamp.year == today.year && e.timestamp.month == today.month && e.timestamp.day == today.day)
        .fold(0, (sum, item) => sum + item.amountMl);

    // Sleep calc
    final avgSleep = sleep.isEmpty
        ? 7.5
        : sleep.fold(0.0, (sum, item) => sum + item.durationHours) / sleep.length;
    final lastSleep = sleep.isEmpty ? 0.0 : sleep.last.durationHours;

    // Habits calc
    final todayHabits = habits.where((h) => h.isActive).toList();
    final completedHabits = todayHabits.where((h) => h.history[todayStr] == 'completed').length;

    switch (queryAction) {
      case AiAction.queryStatus:
        var msg = "Here is your progress overview: ";
        if (todayWater >= dailyWaterGoal) {
          msg += "You met your hydration target! 💧 ";
        } else {
          msg += "You still need ${dailyWaterGoal - todayWater}ml of water to hit your goal. ";
        }
        
        if (lastSleep > 0) {
          if (lastSleep < avgSleep - 0.5) {
            msg += "You slept ${lastSleep.toStringAsFixed(1)} hours, which is less than your ${avgSleep.toStringAsFixed(1)}h average. Take it easy today! 😴 ";
          } else {
            msg += "You logged a solid ${lastSleep.toStringAsFixed(1)} hours of sleep. ";
          }
        } else {
          msg += "Don't forget to log your sleep. ";
        }

        if (todayHabits.isNotEmpty) {
          msg += "You completed $completedHabits out of ${todayHabits.length} habits today. ";
        }
        return msg;

      case AiAction.queryHydration:
        if (todayWater == 0) {
          return "You haven't logged any water today. Your daily goal is ${dailyWaterGoal}ml. Try logging your first glass!";
        } else if (todayWater < dailyWaterGoal) {
          final remaining = dailyWaterGoal - todayWater;
          return "You have consumed $todayWater ml of water today. You are $remaining ml away from your daily goal. Hydrate up!";
        } else {
          return "Brilliant job! You've reached your daily hydration goal of $todayWater ml ($todayWater/$dailyWaterGoal). You are fully hydrated!";
        }

      case AiAction.querySleep:
        if (sleep.isEmpty) {
          return "I don't have any sleep logs in my database yet. Tell me 'I slept 7 hours' or use the Sleep tab to log last night's rest.";
        }
        final consistency = _calculateSleepConsistency(sleep);
        return "Your average sleep duration is ${avgSleep.toStringAsFixed(1)} hours. Your sleep consistency score is $consistency%. "
            "${lastSleep > 0 ? 'Last night, you slept ${lastSleep.toStringAsFixed(1)} hours.' : ''} Try to keep a regular bedtime to boost your sleep score.";

      case AiAction.queryHabits:
        if (todayHabits.isEmpty) {
          return "You don't have any active habits set up. Try telling me 'create habit to meditate' or use the Habits tab to choose from recommended routines.";
        }
        final pending = todayHabits.length - completedHabits;
        if (pending == 0) {
          return "Congratulations! You've completed all ${todayHabits.length} of your habits for today. Outstanding consistency!";
        } else {
          return "You've completed $completedHabits/${todayHabits.length} habits today. You have $pending remaining. Consistency builds character!";
        }

      default:
        return "I am monitoring your logs closely. Let me know what data to update.";
    }
  }

  int _calculateSleepConsistency(List<SleepLog> logs) {
    if (logs.length < 2) return 85; // baseline default
    // Calculate variance in duration
    double sum = 0;
    double avg = logs.fold(0.0, (s, e) => s + e.durationHours) / logs.length;
    for (var log in logs) {
      sum += pow(log.durationHours - avg, 2);
    }
    double variance = sum / logs.length;
    // 0 variance = 100% consistency, variance of 4 hours or more = low consistency
    int score = (100 - (variance * 15)).round();
    return score.clamp(30, 100);
  }
}

enum AiAction {
  none,
  addHydration,
  addSleep,
  createHabit,
  queryStatus,
  queryHydration,
  querySleep,
  queryHabits,
}

class AiParseResult {
  final AiAction action;
  final dynamic value;
  final String response;

  AiParseResult({
    required this.action,
    required this.value,
    required this.response,
  });
}
