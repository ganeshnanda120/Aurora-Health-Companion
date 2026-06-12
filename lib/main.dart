import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/health_provider.dart';
import 'services/storage_service.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => HealthProvider(storageService),
      child: const AuroraApp(),
    ),
  );
}

class AuroraApp extends StatelessWidget {
  const AuroraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurora Health Companion',
      debugShowCheckedModeBanner: false,
      theme: AuroraTheme.darkTheme,
      home: const InitialRouteResolver(),
    );
  }
}

class InitialRouteResolver extends StatelessWidget {
  const InitialRouteResolver({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);

    if (!provider.isAuthenticated) {
      return const LandingScreen();
    } else if (!provider.isOnboarded) {
      return const OnboardingScreen();
    } else {
      return const MainShell();
    }
  }
}
