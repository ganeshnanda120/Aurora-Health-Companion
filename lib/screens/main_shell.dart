import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/health_provider.dart';
import '../../widgets/avatar_widget.dart';
import 'dashboard/home_screen.dart';
import 'ai_companion/ai_companion_screen.dart';
import 'hydration/hydration_screen.dart';
import 'sleep/sleep_screen.dart';
import 'profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AiCompanionScreen(),
    HydrationScreen(),
    SleepScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);
    final profile = provider.profile;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: AuroraTheme.primary.withOpacity(0.2),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                color: AuroraTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
            }
            return const TextStyle(
              color: AuroraTheme.textSecondary,
              fontSize: 12,
            );
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: AuroraTheme.primary, size: 26);
            }
            return const IconThemeData(color: AuroraTheme.textSecondary, size: 24);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: AuroraTheme.cardBg,
          elevation: 8,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            const NavigationDestination(
              icon: Icon(Icons.blur_on_rounded),
              label: 'Aurora',
            ),
            const NavigationDestination(
              icon: Icon(Icons.local_drink_rounded),
              label: 'Hydration',
            ),
            const NavigationDestination(
              icon: Icon(Icons.nights_stay_rounded),
              label: 'Sleep',
            ),
            NavigationDestination(
              icon: AvatarWidget(
                avatarId: profile?.profilePic ?? 'avatar1',
                radius: 12,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
