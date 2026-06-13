import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/health_provider.dart';
import '../../models/sleep.dart';
import '../../widgets/avatar_widget.dart';
import '../habits/habits_screen.dart';
import '../nutrition/nutrition_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);
    final profile = provider.profile;

    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    // Hydration calculations
    final hydrationLogs = provider.hydrationLogs;
    final todayWater = hydrationLogs
        .where((e) => e.timestamp.year == today.year && e.timestamp.month == today.month && e.timestamp.day == today.day)
        .fold(0, (sum, item) => sum + item.amountMl);
    final waterGoal = 2000; // ml
    final waterPercent = (todayWater / waterGoal).clamp(0.0, 1.0);

    // Sleep calculations
    final sleepLogs = provider.sleepLogs;
    final lastSleep = sleepLogs.isEmpty ? 0.0 : sleepLogs.last.durationHours;
    final avgSleep = sleepLogs.isEmpty
        ? 7.5
        : sleepLogs.fold(0.0, (sum, item) => sum + item.durationHours) / sleepLogs.length;
    // Estimate consistency score from sleep logs variance
    final sleepConsistency = sleepLogs.length < 2 ? 85 : _calculateSleepConsistencyScore(sleepLogs);

    // Habits calculations
    final habits = provider.habits;
    final completedHabiting = habits.where((h) => h.isActive && h.history[todayStr] == 'completed').length;
    final totalHabiting = habits.where((h) => h.isActive).length;
    final habitPercent = totalHabiting == 0 ? 0.0 : (completedHabiting / totalHabiting);

    // Nutrition calculations
    final nutritionLogs = provider.nutritionLogs;
    final todayNutrition = nutritionLogs.where((e) =>
        e.timestamp.year == today.year &&
        e.timestamp.month == today.month &&
        e.timestamp.day == today.day
    );
    final loggedMeals = todayNutrition.map((e) => e.mealType).toSet().length;
    final totalCalories = todayNutrition.fold(0, (sum, item) => sum + item.calories);

    // Streaks
    final streaks = provider.getStreaks();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.auroraGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          AvatarWidget(
                            avatarId: profile?.profilePic ?? 'avatar1',
                            radius: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome back,",
                                  style: TextStyle(
                                    color: AuroraTheme.textSecondary,
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  profile?.name ?? "Explorer",
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AuroraTheme.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded, color: AuroraTheme.accentStreak, size: 22),
                          const SizedBox(width: 6),
                          Text(
                            "${streaks['longest'] ?? 0} Days",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 1. Daily Insight Card
                _buildInsightCard(context, provider.getTodayInsight()),
                const SizedBox(height: 24),

                // Grid of Modules
                Row(
                  children: [
                    // Hydration Card
                    Expanded(
                      child: _buildDashboardCard(
                        context: context,
                        title: "Hydration",
                        icon: Icons.local_drink_rounded,
                        color: AuroraTheme.accentHydration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$todayWater / ${waterGoal}ml",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: waterPercent,
                                backgroundColor: Colors.white.withOpacity(0.05),
                                color: AuroraTheme.accentHydration,
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${(waterGoal - todayWater).clamp(0, 9999)}ml remaining",
                              style: TextStyle(color: AuroraTheme.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Sleep Card
                    Expanded(
                      child: _buildDashboardCard(
                        context: context,
                        title: "Sleep",
                        icon: Icons.nights_stay_rounded,
                        color: AuroraTheme.accentSleep,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${lastSleep.toStringAsFixed(1)} Hrs",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Avg: ${avgSleep.toStringAsFixed(1)}h",
                              style: TextStyle(color: AuroraTheme.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.analytics_rounded, size: 14, color: AuroraTheme.accentSleep),
                                const SizedBox(width: 4),
                                Text(
                                  "Consistency: $sleepConsistency%",
                                  style: TextStyle(color: AuroraTheme.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    // Habits Card
                    Expanded(
                      child: _buildDashboardCard(
                        context: context,
                        title: "Habits",
                        icon: Icons.task_alt_rounded,
                        color: AuroraTheme.accentHabits,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HabitsScreen()),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$completedHabiting / $totalHabiting Completed",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: habitPercent,
                                backgroundColor: Colors.white.withOpacity(0.05),
                                color: AuroraTheme.accentHabits,
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Tap to manage habits",
                              style: TextStyle(color: AuroraTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Nutrition Card
                    Expanded(
                      child: _buildDashboardCard(
                        context: context,
                        title: "Nutrition",
                        icon: Icons.restaurant_rounded,
                        color: AuroraTheme.accentNutrition,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NutritionScreen()),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$totalCalories Kcal",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$loggedMeals meals logged",
                              style: TextStyle(color: AuroraTheme.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Tap to log nutrition",
                              style: TextStyle(color: AuroraTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Streak & Achievements Card
                _buildStreaksSection(context, streaks),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String text) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              AuroraTheme.primary.withOpacity(0.08),
              AuroraTheme.secondary.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AuroraTheme.primary.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AuroraTheme.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: AuroraTheme.primary, size: 16),
                ),
                const SizedBox(width: 8),
                const Text(
                  "AURORA INSIGHT",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AuroraTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: AuroraTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Card(
      color: AuroraTheme.cardBg.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AuroraTheme.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreaksSection(BuildContext context, Map<String, int> streaks) {
    final items = [
      _StreakItem(title: "Hydration", value: streaks['hydration'] ?? 0, color: AuroraTheme.accentHydration, icon: Icons.local_drink_rounded),
      _StreakItem(title: "Sleep", value: streaks['sleep'] ?? 0, color: AuroraTheme.accentSleep, icon: Icons.nights_stay_rounded),
      _StreakItem(title: "Habit", value: streaks['habit'] ?? 0, color: AuroraTheme.accentHabits, icon: Icons.task_alt_rounded),
      _StreakItem(title: "Nutrition", value: streaks['nutrition'] ?? 0, color: AuroraTheme.accentNutrition, icon: Icons.restaurant_rounded),
    ];

    return Card(
      color: AuroraTheme.cardBg.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.local_fire_department_rounded, color: AuroraTheme.accentStreak, size: 24),
                SizedBox(width: 8),
                Text(
                  "Active Streaks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AuroraTheme.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.map((item) {
                return Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Icon(item.icon, color: item.color, size: 20),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(item.title, style: TextStyle(color: AuroraTheme.textSecondary, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      "${item.value} days",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AuroraTheme.textPrimary),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSleepConsistencyScore(List<SleepLog> logs) {
    // Basic variance calculation
    double sum = 0;
    double avg = logs.fold(0.0, (s, e) => s + e.durationHours) / logs.length;
    for (var log in logs) {
      sum += (log.durationHours - avg) * (log.durationHours - avg);
    }
    double variance = sum / logs.length;
    int score = (100 - (variance * 15)).round();
    return score.clamp(30, 100);
  }
}

class _StreakItem {
  final String title;
  final int value;
  final Color color;
  final IconData icon;

  _StreakItem({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });
}
