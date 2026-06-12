import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aurora_health_companion/services/ai_service.dart';
import 'package:aurora_health_companion/services/storage_service.dart';
import 'package:aurora_health_companion/providers/health_provider.dart';
import 'package:aurora_health_companion/models/user_profile.dart';
import 'package:aurora_health_companion/core/name_formatter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AI Service Command Parsing Tests', () {
    late AiService aiService;

    setUp(() {
      aiService = AiService();
    });

    test('Should parse water hydration commands correctly', () {
      final res1 = aiService.parseCommand('I drank 500ml water');
      expect(res1.action, AiAction.addHydration);
      expect(res1.value, 500);

      final res2 = aiService.parseCommand('add 350ml');
      expect(res2.action, AiAction.addHydration);
      expect(res2.value, 350);
    });

    test('Should parse sleep logs commands correctly', () {
      final res = aiService.parseCommand('I slept 8.5 hours last night');
      expect(res.action, AiAction.addSleep);
      expect(res.value, 8.5);
    });

    test('Should parse habit creation commands correctly', () {
      final res = aiService.parseCommand('create habit to Stretch');
      expect(res.action, AiAction.createHabit);
      expect(res.value, 'Stretch');
    });

    test('Should fallback gracefully on general questions', () {
      final res = aiService.parseCommand('hello there');
      expect(res.action, AiAction.none);
      expect(res.response.contains('Aurora'), true);
    });
  });

  group('User Profile Model Tests', () {
    test('Should serialize and deserialize UserProfile accurately', () {
      final profile = UserProfile(
        name: 'Alex',
        age: 30,
        gender: 'Male',
        height: 180,
        weight: 80,
        wakeUpTime: '06:00',
        bedTime: '22:00',
        activityLevel: 'High',
        healthGoals: ['Sleep Better'],
        notificationPreferences: {'Sleep': true},
      );

      final json = profile.toJson();
      final decoded = UserProfile.fromJson(json);

      expect(decoded.name, 'Alex');
      expect(decoded.age, 30);
      expect(decoded.height, 180);
      expect(decoded.weight, 80);
      expect(decoded.activityLevel, 'High');
      expect(decoded.healthGoals.first, 'Sleep Better');
    });
  });

  group('Special Name Formatter Tests', () {
    test('Should format short names as Title Case', () {
      expect(SpecialNameFormatter.formatName('a'), 'A');
      expect(SpecialNameFormatter.formatName('ab'), 'Ab');
    });

    test('Should format names with only first letter capitalized (Title Case)', () {
      expect(SpecialNameFormatter.formatName('alex'), 'Alex');
      expect(SpecialNameFormatter.formatName('ganesh'), 'Ganesh');
      expect(SpecialNameFormatter.formatName('prasad'), 'Prasad');
    });

    test('Should format multi-word names independently', () {
      expect(SpecialNameFormatter.formatName('ganesh prasad'), 'Ganesh Prasad');
    });
  });

  group('HealthProvider State Management Tests', () {
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'user_email': 'demo@aurora.com',
        'is_onboarded': true,
      });
      final prefs = await SharedPreferences.getInstance();
      storage = StorageService(prefs);
    });

    test('Should initialize credentials and onboarding flags from SharedPreferences', () {
      final provider = HealthProvider(storage);
      expect(provider.isAuthenticated, true);
      expect(provider.userEmail, 'demo@aurora.com');
      expect(provider.isOnboarded, true);
    });

    test('Should process mock login attempts correctly', () async {
      final provider = HealthProvider(storage);
      
      // Invalid credentials
      final badLogin = await provider.login('wrong@email.com', '123');
      expect(badLogin, false);

      // Valid credentials
      final goodLogin = await provider.login('demo@aurora.com', '123456');
      expect(goodLogin, true);
      expect(provider.isAuthenticated, true);
    });
  });
}
